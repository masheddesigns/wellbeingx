import '../../core/utils/date_utils.dart';
import '../../core/utils/duration_format.dart';
import '../models/daily_stats.dart';
import '../models/gamification.dart';
import '../models/insight.dart';
import 'analytics_engine.dart';

/// Generates a ranked list of human-readable insights.
class InsightEngine {
  const InsightEngine();

  List<Insight> generate({
    required DailyStats today,
    required List<DailyStats> last7Days,
    required AnalyticsSummary summary,
    required GamificationState gami,
    List<String> unusedAppNames = const <String>[],
  }) {
    final out = <Insight>[];

    // 1) Unlocks
    if (today.unlocks > 0) {
      final severity = today.unlocks >= 120
          ? InsightSeverity.warning
          : today.unlocks >= 80
              ? InsightSeverity.neutral
              : InsightSeverity.positive;
      out.add(Insight(
        kind: InsightKind.unlockCount,
        severity: severity,
        headline: 'You unlocked your phone ${today.unlocks} times today.',
        body: today.unlocks >= 120
            ? "That's roughly once every ${(_minutesAwakeApprox() / today.unlocks).round()} waking minutes."
            : 'Average so far: ${(today.unlocks / (DateTime.now().hour + 1)).toStringAsFixed(1)} per hour awake.',
      ));
    }

    // 2) Social media time
    final social = today.socialTime;
    if (social.inMinutes > 0) {
      final sev = social.inMinutes >= 180
          ? InsightSeverity.critical
          : social.inMinutes >= 90
              ? InsightSeverity.warning
              : InsightSeverity.neutral;
      out.add(Insight(
        kind: InsightKind.socialMediaTime,
        severity: sev,
        headline: 'You spent ${social.formatHm()} on social media.',
        body: 'Across the week that projects to ${(social * 7).formatHm()}.',
      ));
    }

    // 3) Productivity drop driver
    final dist = today.apps.where((a) => a.category.isDistracting).toList();
    if (dist.isNotEmpty && dist.first.foreground.inMinutes >= 15) {
      out.add(Insight(
        kind: InsightKind.productivityDrop,
        severity: InsightSeverity.warning,
        headline: '${dist.first.displayName} caused the biggest productivity drop today.',
        body: '${dist.first.foreground.formatHm()} across ${pluralize(dist.first.opens, 'open')}.',
        cta: 'Stay Away',
        route: '/stay-away',
      ));
    }

    // 4) Potential savings
    if (summary.projectedSavings.inMinutes >= 30) {
      out.add(Insight(
        kind: InsightKind.potentialSavings,
        severity: InsightSeverity.positive,
        headline:
            'You could save ${summary.projectedSavings.formatHm()} this week by halving short-form content.',
        body: 'Top distractions: ${summary.topApps.where((a) => a.category.isDistracting).take(3).map((a) => a.displayName).join(', ')}.',
        cta: 'Plan a focus block',
        route: '/focus-setup',
      ));
    }

    // 5) Peak distracting window
    final peak = _peakDistractionWindow(last7Days);
    if (peak != null) {
      out.add(Insight(
        kind: InsightKind.peakDistractionWindow,
        severity: InsightSeverity.warning,
        headline:
            'Your most distracting period is between ${WxDates.hourLabel(peak.$1)} and ${WxDates.hourLabel((peak.$2 + 1) % 24)}.',
        body: 'Across the last 7 days, distraction apps spike there.',
      ));
    }

    // 6) Unused apps
    if (unusedAppNames.isNotEmpty) {
      out.add(Insight(
        kind: InsightKind.unusedApps,
        severity: InsightSeverity.neutral,
        headline: '${unusedAppNames.length} apps were never used this month.',
        body: unusedAppNames.take(5).join(', ') +
            (unusedAppNames.length > 5 ? ' and more.' : '.'),
        cta: 'View list',
        route: '/insights',
      ));
    }

    // 7) Short unlocks (micro sessions)
    if (today.shortUnlocks >= 20) {
      out.add(Insight(
        kind: InsightKind.shortUnlockSpiral,
        severity: InsightSeverity.warning,
        headline:
            '${today.shortUnlocks} micro-unlocks (under 30s) — classic compulsive checking.',
        body: 'Try a 25-minute focus session to break the loop.',
        cta: 'Start Pomodoro',
        route: '/pomodoro',
      ));
    }

    // 8) Sleep-time misuse
    if (today.sleepMisuse.inMinutes >= 20) {
      out.add(Insight(
        kind: InsightKind.sleepMisuse,
        severity: InsightSeverity.critical,
        headline:
            '${today.sleepMisuse.formatHm()} of phone use during 11pm–6am.',
        body: 'Late-night screen time is the #1 enemy of deep sleep.',
      ));
    }

    // 9) Notification flood
    final notifs = today.notifications;
    if (notifs >= 80) {
      out.add(Insight(
        kind: InsightKind.notificationFlood,
        severity: InsightSeverity.warning,
        headline: '$notifs notifications today.',
        body: 'Notification pressure score: ${(notifs / 10).round()} / 100.',
      ));
    }

    // 10) Streak
    if (gami.currentStreak >= 2) {
      out.add(Insight(
        kind: InsightKind.streak,
        severity: InsightSeverity.positive,
        headline: '${gami.currentStreak}-day focus streak.',
        body: "Longest ever: ${gami.longestStreak}. Don't break the chain.",
      ));
    }

    // 11) Focus efficiency
    if (summary.focusEfficiency > 0) {
      final pct = (summary.focusEfficiency * 100).round();
      out.add(Insight(
        kind: InsightKind.focusEfficiency,
        severity: pct >= 30
            ? InsightSeverity.positive
            : pct >= 15
                ? InsightSeverity.neutral
                : InsightSeverity.warning,
        headline: 'Focus efficiency: $pct%.',
        body: 'Share of active screen time spent in deep work this week.',
      ));
    }

    return out;
  }

  /// Average waking minutes used to contextualize unlock counts (16h * 60).
  int _minutesAwakeApprox() => 16 * 60;

  /// Find the most distracting 1-hour window across the last [N] days.
  /// Returns (startHour, endHour) inclusive of the same hour.
  (int, int)? _peakDistractionWindow(List<DailyStats> days) {
    if (days.isEmpty) return null;
    final byHour = <int, int>{};
    for (final d in days) {
      for (final a in d.apps.where((a) => a.category.isDistracting)) {
        // Slice that app's foreground proportionally per hour using day buckets.
        final scale = d.screenTime.inMinutes == 0
            ? 0.0
            : a.foreground.inMinutes / d.screenTime.inMinutes;
        d.hourBuckets.forEach((h, dur) {
          final mins = (dur.inMinutes * scale).round();
          if (mins == 0) return;
          byHour.update(h, (v) => v + mins, ifAbsent: () => mins);
        });
      }
    }
    if (byHour.isEmpty) return null;
    final peak =
        byHour.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return (peak, peak);
  }
}
