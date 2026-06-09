import '../../core/utils/duration_format.dart';
import '../models/composite_score.dart';
import '../models/daily_stats.dart';
import '../models/narrative.dart';
import '../models/personality_type.dart';
import 'behavior_engine.dart';

/// Turns numbers into human, emotionally aware sentences.
/// No randomness in the maths — but small, deterministic variation in tone
/// keeps the copy from feeling robotic.
class NarrativeEngine {
  const NarrativeEngine();

  /// One-line greeting that feels personal. Used on the dashboard header.
  Narrative dailyOpener({
    required DailyStats today,
    required BehaviorReport behavior,
    required PersonalityType personality,
  }) {
    final hour = DateTime.now().hour;
    if (hour < 5) {
      return _n(
        NarrativeKind.morningGreeting,
        NarrativeTone.calm,
        'Late night.',
        'The screen is loudest now. Be careful with the next ten minutes.',
        '🌌',
      );
    }
    if (hour < 11 && today.unlocks <= 3) {
      return _n(
        NarrativeKind.morningGreeting,
        NarrativeTone.calm,
        'You\'re winning the morning.',
        'Few unlocks so far — protect this state with one focus block.',
        '🌅',
        cta: 'Start a focus block',
        route: '/focus-setup',
      );
    }
    if (hour >= 22) {
      return _n(
        NarrativeKind.eveningWindDown,
        NarrativeTone.reflective,
        'The day is winding down.',
        today.distractionTime.inMinutes >= 60
            ? 'Distractions caught ${today.distractionTime.formatHm()} today. Sleep is louder than the feed.'
            : 'You held the line today. Let the phone rest before you do.',
        '🌙',
      );
    }
    if (behavior.cognitiveOverloadScore >= 70) {
      return _n(
        NarrativeKind.morningGreeting,
        NarrativeTone.alert,
        'Mental load is high.',
        'Your phone has been loud. Step away for fifteen minutes — even a walk.',
        '🌫️',
      );
    }
    if (behavior.productivityScore >= 70) {
      return _n(
        NarrativeKind.morningGreeting,
        NarrativeTone.energetic,
        'You\'re in shape today.',
        'Productive share is up. Keep the rhythm — book the next focus block now.',
        '⚡',
        cta: 'Pomodoro',
        route: '/focus-setup',
      );
    }
    return _n(
      NarrativeKind.morningGreeting,
      NarrativeTone.calm,
      _personalitySalute(personality),
      _bodyForToday(today, behavior),
      personality.emoji,
    );
  }

  /// Weekly retrospective — the marquee narrative of the app.
  WeeklyRetrospective weeklyRetrospective({
    required List<DailyStats> last7Days,
    required List<DailyStats> previous7Days,
    required BehaviorReport behavior,
    required ScorePack scores,
    required Duration weeklyFocusTime,
    required PersonalityType personality,
  }) {
    final weekTotal = last7Days.fold<Duration>(
      Duration.zero,
      (a, d) => a + d.screenTime,
    );
    final prevTotal = previous7Days.fold<Duration>(
      Duration.zero,
      (a, d) => a + d.screenTime,
    );
    final delta = weekTotal - prevTotal;
    final dayLabels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    DailyStats? best;
    DailyStats? worst;
    for (final d in last7Days) {
      final productive = d.productiveTime.inMinutes;
      if (productive > 0) {
        if (best == null ||
            productive > best.productiveTime.inMinutes) best = d;
      }
      if (worst == null ||
          d.distractionTime.inMinutes > worst.distractionTime.inMinutes) {
        worst = d;
      }
    }
    final productivityIndex = behavior.productivityScore;
    final focusConsistency = _focusConsistency(last7Days, weeklyFocusTime);

    final headline = _weeklyHeadline(
      delta: delta,
      productivity: productivityIndex,
      overload: behavior.cognitiveOverloadScore,
      personality: personality,
    );

    final chapters = <Narrative>[
      _n(
        NarrativeKind.weeklyBody,
        NarrativeTone.reflective,
        'The week in time',
        prevTotal.inMinutes == 0
            ? 'You spent ${weekTotal.formatHm()} on your phone over 7 days.'
            : delta.isNegative
                ? 'You spent ${weekTotal.formatHm()} — ${(-delta).formatHm()} less than last week.'
                : 'You spent ${weekTotal.formatHm()} — ${delta.formatHm()} more than last week.',
        '⏳',
      ),
      if (best != null)
        _n(
          NarrativeKind.weeklyBody,
          NarrativeTone.energetic,
          '${dayLabels[(best.day.weekday - 1).clamp(0, 6)]} was your strongest day',
          '${best.productiveTime.formatHm()} of productive time, ${best.distractionTime.formatHm()} on distractions.',
          '🌟',
        ),
      if (worst != null && worst.distractionTime.inMinutes >= 60)
        _n(
          NarrativeKind.weeklyBody,
          NarrativeTone.alert,
          '${dayLabels[(worst.day.weekday - 1).clamp(0, 6)]} was the noisiest',
          '${worst.distractionTime.formatHm()} on distracting apps. ${_topAppLine(worst)}',
          '🔥',
        ),
      _n(
        NarrativeKind.weeklyBody,
        scores.digitalBalance.value >= 60
            ? NarrativeTone.energetic
            : NarrativeTone.alert,
        'Digital balance: ${scores.digitalBalance.value}/100',
        scores.digitalBalance.headline,
        scores.digitalBalance.value >= 60 ? '✨' : '🌑',
      ),
      _n(
        NarrativeKind.weeklyBody,
        scores.attentionFragmentation.value <= 35
            ? NarrativeTone.energetic
            : NarrativeTone.alert,
        'Attention shape',
        scores.attentionFragmentation.headline,
        '🧠',
      ),
      if (weeklyFocusTime.inMinutes >= 30)
        _n(
          NarrativeKind.weeklyBody,
          NarrativeTone.energetic,
          'Focus held',
          'You spent ${weeklyFocusTime.formatHm()} in deliberate focus this week. Consistency: $focusConsistency%.',
          '🎯',
        ),
      if (behavior.weekendSplit.weekendDeltaPct.abs() >= 20)
        _n(
          NarrativeKind.weeklyBody,
          NarrativeTone.reflective,
          behavior.weekendSplit.weekendDeltaPct > 0
              ? 'Weekends ran heavier'
              : 'Weekdays ran heavier',
          '${behavior.weekendSplit.weekendDeltaPct.abs()}% gap between weekday and weekend phone use.',
          behavior.weekendSplit.weekendDeltaPct > 0 ? '🛋️' : '💼',
        ),
      _trendChapter(behavior, last7Days),
    ];

    return WeeklyRetrospective(
      headline: headline,
      chapters: chapters,
      mostProductiveDay:
          best == null ? '—' : dayLabels[(best.day.weekday - 1).clamp(0, 6)],
      mostDistractingDay:
          worst == null ? '—' : dayLabels[(worst.day.weekday - 1).clamp(0, 6)],
      totalScreen: weekTotal,
      totalFocus: weeklyFocusTime,
      productivityIndex: productivityIndex,
      focusConsistency: focusConsistency,
    );
  }

  Narrative _trendChapter(BehaviorReport b, List<DailyStats> last7) {
    final morning = last7
        .map((d) => d.hourBuckets.entries
            .where((e) => e.key >= 6 && e.key <= 11)
            .fold<int>(0, (a, e) => a + e.value.inMinutes))
        .fold<int>(0, (a, b) => a + b);
    final evening = last7
        .map((d) => d.hourBuckets.entries
            .where((e) => e.key >= 19 && e.key <= 23)
            .fold<int>(0, (a, e) => a + e.value.inMinutes))
        .fold<int>(0, (a, b) => a + b);
    if (evening > morning * 1.5) {
      return _n(
        NarrativeKind.emotionalTrend,
        NarrativeTone.reflective,
        'Evenings carry the screen',
        'Most of your phone time landed after 7pm. Mornings stayed quiet.',
        '🌒',
      );
    }
    if (morning > evening * 1.5) {
      return _n(
        NarrativeKind.emotionalTrend,
        NarrativeTone.energetic,
        'Mornings did the work',
        'You leaned into the phone early — evenings stayed lighter.',
        '☀️',
      );
    }
    return _n(
      NarrativeKind.emotionalTrend,
      NarrativeTone.calm,
      'Time spread evenly',
      'No single window of the day dominated phone use.',
      '⚖️',
    );
  }

  Narrative _weeklyHeadline({
    required Duration delta,
    required int productivity,
    required int overload,
    required PersonalityType personality,
  }) {
    if (delta.isNegative && delta.inMinutes <= -60) {
      return _n(
        NarrativeKind.weeklyHeadline,
        NarrativeTone.energetic,
        'Lighter week.',
        'You pulled ${(-delta).formatHm()} away from the phone vs last week.',
        '🌿',
      );
    }
    if (delta.inMinutes >= 60) {
      return _n(
        NarrativeKind.weeklyHeadline,
        NarrativeTone.alert,
        'The phone got more of you.',
        'Up ${delta.formatHm()} vs last week — worth understanding why.',
        '🌋',
      );
    }
    if (productivity >= 65) {
      return _n(
        NarrativeKind.weeklyHeadline,
        NarrativeTone.energetic,
        'A focused week.',
        'You routed your time toward what mattered.',
        '🎯',
      );
    }
    if (overload >= 65) {
      return _n(
        NarrativeKind.weeklyHeadline,
        NarrativeTone.alert,
        'A noisy week.',
        'Notifications and switches stayed loud. Quieter weeks are within reach.',
        '🔊',
      );
    }
    return _n(
      NarrativeKind.weeklyHeadline,
      NarrativeTone.calm,
      'A measured week.',
      'No drama. Steady-state with room to push higher.',
      personality.emoji,
    );
  }

  String _personalitySalute(PersonalityType p) {
    switch (p) {
      case PersonalityType.nightOwl:
        return 'Hey, night owl.';
      case PersonalityType.doomScroller:
        return 'Watch the spiral today.';
      case PersonalityType.focusedMonk:
        return 'Quiet attention on tap.';
      case PersonalityType.hustler:
        return 'Hustler mode.';
      case PersonalityType.socialButterfly:
        return 'Many threads to weave.';
      case PersonalityType.balanced:
        return 'A measured day.';
    }
  }

  String _bodyForToday(DailyStats today, BehaviorReport b) {
    if (today.screenTime.inMinutes < 30) {
      return 'Phone\'s barely in your hand today. Keep it that way.';
    }
    if (b.distractionLoops >= 3) {
      return '${b.distractionLoops} reopen loops detected — try a 25m block to reset.';
    }
    if (b.productivityScore >= 60) {
      return '${today.productiveTime.formatHm()} on productive apps so far.';
    }
    return '${today.screenTime.formatHm()} on the phone today.';
  }

  String _topAppLine(DailyStats d) {
    final top = d.apps
        .where((a) => a.category.isDistracting)
        .toList()
      ..sort((a, b) => b.foreground.compareTo(a.foreground));
    if (top.isEmpty) return '';
    final t = top.first;
    return '${t.displayName} took ${t.foreground.formatHm()}.';
  }

  int _focusConsistency(List<DailyStats> last7, Duration weeklyFocus) {
    if (weeklyFocus.inMinutes == 0) return 0;
    // Variance of focus time across days. Even = consistent.
    // For now we approximate using productive time in apps.
    final ms = last7.map((d) => d.productiveTime.inMinutes).toList();
    if (ms.isEmpty) return 0;
    final avg = ms.reduce((a, b) => a + b) / ms.length;
    if (avg == 0) return 0;
    double sumSq = 0;
    for (final v in ms) {
      sumSq += (v - avg) * (v - avg);
    }
    final variance = sumSq / ms.length;
    final cv = (avg == 0) ? 1.0 : (variance.toDouble() / (avg * avg));
    final consistency = (1 - cv.clamp(0, 1)) * 100;
    return consistency.clamp(0, 100).round();
  }

  Narrative _n(
    NarrativeKind kind,
    NarrativeTone tone,
    String head,
    String body,
    String? emoji, {
    String? cta,
    String? route,
  }) {
    return Narrative(
      kind: kind,
      tone: tone,
      headline: head,
      body: body,
      emoji: emoji,
      cta: cta,
      route: route,
    );
  }

  /// Auto-detected milestones — hand them to a celebration card.
  List<Narrative> milestones({
    required int currentStreak,
    required int longestStreak,
    required Duration weeklyFocus,
    required Duration prevWeeklyFocus,
    required ScorePack scores,
  }) {
    final out = <Narrative>[];
    if (currentStreak == 7) {
      out.add(_n(NarrativeKind.milestone, NarrativeTone.energetic,
          'A full week of focus.', 'Seven days, no chain breaks.', '🔥'));
    }
    if (currentStreak == 30) {
      out.add(_n(NarrativeKind.milestone, NarrativeTone.energetic,
          'Thirty days. Rare air.', 'You\'re showing up against most odds.', '💎'));
    }
    if (currentStreak > 0 &&
        currentStreak == longestStreak &&
        currentStreak >= 5) {
      out.add(_n(NarrativeKind.milestone, NarrativeTone.energetic,
          'New personal best.', 'A $currentStreak-day streak — your longest yet.', '🚀'));
    }
    if (weeklyFocus.inMinutes >= 600 &&
        weeklyFocus.inMinutes >
            prevWeeklyFocus.inMinutes * 1.3) {
      out.add(_n(
          NarrativeKind.milestone,
          NarrativeTone.energetic,
          'Focus surged this week.',
          '${weeklyFocus.formatHm()} — way up from last week.',
          '⚡'));
    }
    if (scores.digitalBalance.value >= 80) {
      out.add(_n(NarrativeKind.milestone, NarrativeTone.calm,
          'Balanced state achieved.', 'Digital balance ≥ 80. Hard to get.', '🪷'));
    }
    return out;
  }
}
