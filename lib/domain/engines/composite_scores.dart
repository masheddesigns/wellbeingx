import '../../core/utils/duration_format.dart';
import '../models/app_category.dart';
import '../models/composite_score.dart';
import '../models/daily_stats.dart';
import 'behavior_engine.dart';
import 'notification_intelligence.dart';

class CompositeScoresEngine {
  const CompositeScoresEngine();

  ScorePack compute({
    required DailyStats today,
    required List<DailyStats> last7Days,
    required List<DailyStats> previous7Days,
    required BehaviorReport behavior,
    required NotificationReport notif,
  }) {
    return ScorePack(
      digitalBalance: _digitalBalance(today, last7Days, previous7Days, behavior),
      attentionFragmentation:
          _attentionFragmentation(today, last7Days, previous7Days, behavior),
      notificationAnxiety:
          _notificationAnxiety(today, last7Days, previous7Days, notif),
      appDependency: _appDependency(today, last7Days, previous7Days),
      socialToxicity: _socialToxicity(today, last7Days, previous7Days),
    );
  }

  // ---------------- Digital Balance ----------------
  CompositeScore _digitalBalance(
    DailyStats today,
    List<DailyStats> last7,
    List<DailyStats> prev7,
    BehaviorReport b,
  ) {
    // Higher = healthier. Combines productive share, screen-time vs target,
    // sleep window respect, and overload (inverted).
    final productiveShare = b.productivityScore; // 0..100
    final overloadInverse = 100 - b.cognitiveOverloadScore; // 0..100
    final sleepInverse =
        (100 - (today.sleepMisuse.inMinutes * 1.5).clamp(0, 100)).round();
    final screenInverse = today.screenTime.inMinutes >= 480
        ? 0
        : ((1 - today.screenTime.inMinutes / 480.0) * 100).round();
    final score = (productiveShare * 0.35 +
            overloadInverse * 0.25 +
            sleepInverse * 0.15 +
            screenInverse * 0.25)
        .round();

    final prev = _avgScore(prev7, _balanceFor);
    final curr = _avgScore(last7, _balanceFor);
    return CompositeScore(
      code: 'digital_balance',
      label: 'Digital Balance',
      value: score.clamp(0, 100),
      delta: curr - prev,
      headline: score >= 70
          ? 'Strong balance. Phone serves you.'
          : score >= 50
              ? 'Steady. Small wins today.'
              : score >= 30
                  ? 'Tipping toward the screen.'
                  : 'Heavily phone-led day.',
      detail: 'Productive share, screen time, sleep respect & cognitive load.',
      band: _bandHigherIsBetter(score),
    );
  }

  int _balanceFor(DailyStats d) {
    final p = d.productiveTime.inMinutes;
    final dist = d.distractionTime.inMinutes;
    final share = (p + dist) == 0 ? 50 : ((p / (p + dist)) * 100).round();
    final screen = d.screenTime.inMinutes >= 480
        ? 0
        : ((1 - d.screenTime.inMinutes / 480.0) * 100).round();
    return ((share * 0.5) + (screen * 0.5)).round();
  }

  // ---------------- Attention Fragmentation ----------------
  CompositeScore _attentionFragmentation(
    DailyStats today,
    List<DailyStats> last7,
    List<DailyStats> prev7,
    BehaviorReport b,
  ) {
    // Higher = more fragmented (worse). Use rapid switching + idle unlocks
    // + distraction loop count + shortUnlocks/unlocks ratio.
    final ratio = today.unlocks == 0
        ? 0.0
        : (today.shortUnlocks / today.unlocks).clamp(0.0, 1.0);
    final score = (b.rapidSwitchingScore * 0.35 +
            b.idleUnlockScore * 0.30 +
            (b.distractionLoops * 5).clamp(0, 100) * 0.15 +
            ratio * 100 * 0.20)
        .round();
    final prev = _avgScore(prev7, _fragmentationFor);
    final curr = _avgScore(last7, _fragmentationFor);
    return CompositeScore(
      code: 'attention_fragmentation',
      label: 'Attention Fragmentation',
      value: score.clamp(0, 100),
      delta: curr - prev,
      headline: score >= 65
          ? 'Attention shattered. Many tiny opens.'
          : score >= 40
              ? 'Breaking up. Worth a focus block.'
              : score >= 20
                  ? 'Mostly held together.'
                  : 'Deep, contiguous attention.',
      detail:
          '${today.shortUnlocks} micro-unlocks · ${b.distractionLoops} loops · rapid-switch ${b.rapidSwitchingScore}',
      band: _bandLowerIsBetter(score),
    );
  }

  int _fragmentationFor(DailyStats d) {
    if (d.unlocks == 0) return 0;
    final ratio = (d.shortUnlocks / d.unlocks).clamp(0.0, 1.0);
    final mph = d.screenTime.inMinutes == 0
        ? 0
        : (d.unlocks / (d.screenTime.inMinutes / 60.0));
    final mphFactor = (mph / 60.0).clamp(0, 1.0);
    return ((ratio * 60) + (mphFactor * 40)).round();
  }

  // ---------------- Notification Anxiety ----------------
  CompositeScore _notificationAnxiety(
    DailyStats today,
    List<DailyStats> last7,
    List<DailyStats> prev7,
    NotificationReport n,
  ) {
    // Higher = more anxious. Pressure + spam apps + clustering during work hours.
    final clustered = _workHoursClustering(today);
    final score = (n.pressureScore * 0.55 +
            (n.spamApps * 12).clamp(0, 100) * 0.20 +
            clustered * 0.25)
        .round();
    final prev = _avgScore(prev7, _anxietyFor);
    final curr = _avgScore(last7, _anxietyFor);
    return CompositeScore(
      code: 'notification_anxiety',
      label: 'Notification Anxiety',
      value: score.clamp(0, 100),
      delta: curr - prev,
      headline: score >= 65
          ? 'You\'re reacting to the phone, not leading it.'
          : score >= 40
              ? 'Loud signal. A few mutes would help.'
              : 'Quiet enough to hear yourself think.',
      detail:
          '${today.notifications} notifs · ${n.spamApps} spam sources · refocus cost ~${n.refocusCost.formatHm()}',
      band: _bandLowerIsBetter(score),
    );
  }

  int _anxietyFor(DailyStats d) {
    final notifs = d.notifications;
    return (notifs / 4).clamp(0, 100).round();
  }

  /// Notifications during 9am-6pm divided by total — high clustering during
  /// work hours = maximum disruptive pressure.
  int _workHoursClustering(DailyStats d) {
    if (d.notifications == 0) return 0;
    // We don't have hour-resolution notif data; approximate from hour buckets
    // weighted by how many notifs typically come per fg minute in that hour.
    int workMs = 0;
    int totalMs = 0;
    d.hourBuckets.forEach((h, dur) {
      totalMs += dur.inMilliseconds;
      if (h >= 9 && h <= 18) workMs += dur.inMilliseconds;
    });
    if (totalMs == 0) return 0;
    return ((workMs / totalMs) * 100).round();
  }

  // ---------------- App Dependency ----------------
  CompositeScore _appDependency(
    DailyStats today,
    List<DailyStats> last7,
    List<DailyStats> prev7,
  ) {
    // Higher = more concentrated on one app. Top app share + opens per day.
    if (today.apps.isEmpty) {
      return const CompositeScore(
        code: 'app_dependency',
        label: 'App Dependency',
        value: 0,
        delta: 0,
        headline: 'Nothing recorded yet.',
        detail: 'Tracking will paint a clearer picture.',
        band: ScoreBand.calm,
      );
    }
    final top = today.apps.first;
    final share = today.screenTime.inMinutes == 0
        ? 0
        : ((top.foreground.inMinutes / today.screenTime.inMinutes) * 100)
            .round();
    final score = ((share * 0.7) + (top.opens.clamp(0, 100) * 0.3)).round();
    final prev = _avgScore(prev7, _dependencyFor);
    final curr = _avgScore(last7, _dependencyFor);
    return CompositeScore(
      code: 'app_dependency',
      label: 'App Dependency',
      value: score.clamp(0, 100),
      delta: curr - prev,
      headline: score >= 60
          ? '${top.displayName} owns most of your screen.'
          : score >= 40
              ? '${top.displayName} is heavy, but not dominant.'
              : 'Diversified attention across apps.',
      detail:
          '${top.displayName}: ${top.foreground.formatHm()} · $share% of today',
      band: _bandLowerIsBetter(score),
    );
  }

  int _dependencyFor(DailyStats d) {
    if (d.apps.isEmpty || d.screenTime.inMinutes == 0) return 0;
    return ((d.apps.first.foreground.inMinutes / d.screenTime.inMinutes) * 100)
        .round();
  }

  // ---------------- Social Toxicity ----------------
  CompositeScore _socialToxicity(
    DailyStats today,
    List<DailyStats> last7,
    List<DailyStats> prev7,
  ) {
    // Higher = social media has more grip. Social time + late-night social use.
    final socialMin = today.socialTime.inMinutes;
    int lateNightSocial = 0;
    final socialApps = today.apps
        .where((a) => a.category == AppCategory.social)
        .toList();
    if (socialApps.isNotEmpty && today.screenTime.inMinutes > 0) {
      final socialShare = today.socialTime.inMinutes / today.screenTime.inMinutes;
      today.hourBuckets.forEach((h, dur) {
        if (h >= 22 || h < 2) {
          lateNightSocial += (dur.inMinutes * socialShare).round();
        }
      });
    }
    final score = ((socialMin / 4).clamp(0, 60) +
            (lateNightSocial * 1.5).clamp(0, 40))
        .round();
    final prev = _avgScore(prev7, _socialFor);
    final curr = _avgScore(last7, _socialFor);
    return CompositeScore(
      code: 'social_toxicity',
      label: 'Social Toxicity Index',
      value: score.clamp(0, 100),
      delta: curr - prev,
      headline: score >= 65
          ? 'Social feeds are running your day.'
          : score >= 35
              ? 'Some grip — bedtime is the riskiest window.'
              : 'Healthy distance from the feed.',
      detail:
          '${today.socialTime.formatHm()} on social · $lateNightSocial min late-night',
      band: _bandLowerIsBetter(score),
    );
  }

  int _socialFor(DailyStats d) =>
      (d.socialTime.inMinutes / 4).clamp(0, 100).round();

  // ---------------- helpers ----------------
  int _avgScore(List<DailyStats> days, int Function(DailyStats) fn) {
    if (days.isEmpty) return 0;
    int sum = 0;
    for (final d in days) {
      sum += fn(d);
    }
    return sum ~/ days.length;
  }

  ScoreBand _bandHigherIsBetter(int v) {
    if (v >= 70) return ScoreBand.calm;
    if (v >= 50) return ScoreBand.steady;
    if (v >= 30) return ScoreBand.alert;
    return ScoreBand.critical;
  }

  ScoreBand _bandLowerIsBetter(int v) {
    if (v <= 25) return ScoreBand.calm;
    if (v <= 45) return ScoreBand.steady;
    if (v <= 65) return ScoreBand.alert;
    return ScoreBand.critical;
  }
}
