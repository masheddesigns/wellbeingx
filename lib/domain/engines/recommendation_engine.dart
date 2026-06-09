import '../../core/utils/duration_format.dart';
import '../models/daily_stats.dart';
import '../models/recommendation.dart';
import 'behavior_engine.dart';

/// Generates a small, ranked list of "what should the user do next?".
/// Should never produce more than 4–5 items — too many becomes noise.
class RecommendationEngine {
  const RecommendationEngine();

  List<Recommendation> generate({
    required DailyStats today,
    required List<DailyStats> last7Days,
    required BehaviorReport behavior,
  }) {
    final out = <Recommendation>[];
    final now = DateTime.now();

    // 1) Right-now: cognitive overload is high → push a focus session.
    if (behavior.cognitiveOverloadScore >= 65) {
      out.add(Recommendation(
        kind: RecommendationKind.focusSession,
        priority: RecommendationPriority.high,
        title: 'Reset with a 25m focus block',
        body:
            "Cognitive load is at ${behavior.cognitiveOverloadScore}/100. A short Pomodoro will collapse the noise.",
        cta: 'Start Pomodoro',
        route: '/pomodoro',
      ));
    }

    // 2) Late-night spiral.
    if (now.hour >= 22 || now.hour < 5) {
      if (today.distractionTime.inMinutes >= 30 ||
          today.sleepMisuse.inMinutes >= 20) {
        out.add(Recommendation(
          kind: RecommendationKind.sleepMode,
          priority: RecommendationPriority.urgent,
          title: 'Switch to sleep mode',
          body:
              'It\'s late. ${today.distractionTime.formatHm()} on distractions today already — block them until morning.',
          cta: 'Block until 06:00',
          route: '/stay-away',
          payload: <String, Object?>{
            'mode': 'hard',
            'untilHour': 6,
          },
        ));
      }
    }

    // 3) Peak-distraction window — schedule a block during your repeat-offender hour.
    final peakHour = _peakDistractionHour(last7Days);
    if (peakHour != null &&
        (now.hour < peakHour || (peakHour - now.hour).abs() <= 2)) {
      final topDistracting = today.apps
          .where((a) => a.category.isDistracting)
          .take(2)
          .map((a) => a.displayName)
          .toList();
      if (topDistracting.isNotEmpty) {
        out.add(Recommendation(
          kind: RecommendationKind.scheduleBlock,
          priority: RecommendationPriority.medium,
          title: 'Schedule a block at $peakHour:00',
          body:
              "${topDistracting.join(' and ')} dominate your ${peakHour}–${(peakHour + 1) % 24}h window. Lock the door before you walk through it.",
          cta: 'Pick apps',
          route: '/stay-away',
        ));
      }
    }

    // 4) Doomscroll caught in the act.
    if (behavior.doomscrolls.isNotEmpty) {
      final worst = behavior.doomscrolls.first;
      out.add(Recommendation(
        kind: RecommendationKind.takeBreak,
        priority: RecommendationPriority.high,
        title: 'Doomscroll caught',
        body:
            '${worst.displayName} ate ${worst.duration.formatHm()} in a single sitting today. Step away for 10 minutes.',
        cta: 'Block 30m',
        route: '/stay-away',
        payload: <String, Object?>{
          'package': worst.packageName,
          'mode': 'hard',
          'durationMin': 30,
        },
      ));
    }

    // 5) Notification flood.
    if (today.notifications >= 100) {
      out.add(Recommendation(
        kind: RecommendationKind.reduceNotifications,
        priority: RecommendationPriority.medium,
        title: 'Notification detox',
        body:
            '${today.notifications} interruptions today. Trim the loudest 3 sources and watch your focus return.',
        cta: 'See sources',
        route: '/notification-intel',
      ));
    }

    // 6) Weekend reset.
    if (now.weekday == DateTime.sunday &&
        behavior.weekendSplit.weekendDeltaPct >= 30) {
      out.add(Recommendation(
        kind: RecommendationKind.weekendReset,
        priority: RecommendationPriority.low,
        title: 'Weekend creep',
        body:
            'Your weekends run ${behavior.weekendSplit.weekendDeltaPct}% heavier than weekdays. Plan one screen-free block tomorrow.',
        cta: 'Set a focus block',
        route: '/focus-setup',
      ));
    }

    // 7) Mindful morning.
    if (now.hour >= 6 && now.hour < 10 && today.unlocks <= 2) {
      out.add(const Recommendation(
        kind: RecommendationKind.morningRitual,
        priority: RecommendationPriority.low,
        title: 'You\'re winning the morning',
        body: 'Quiet start. Lock it in with a 25-min focus block before email.',
        cta: 'Start',
        route: '/pomodoro',
      ));
    }

    // 8) Ghost Week pitch — big distraction trend over a week with no Ghost mode used.
    if (behavior.weekTrendDeltaMinutes > 60 * 5) {
      out.add(const Recommendation(
        kind: RecommendationKind.ghostWeek,
        priority: RecommendationPriority.medium,
        title: 'Try a Ghost Week',
        body:
            'You\'re trending up by 5+ hours week-on-week. Disappear from your own stats for 7 days — the reveal will hit harder.',
        cta: 'Start Ghost Week',
        route: '/settings',
      ));
    }

    // Sort by priority and trim.
    out.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return out.take(4).toList();
  }

  int? _peakDistractionHour(List<DailyStats> days) {
    if (days.isEmpty) return null;
    final byHour = <int, int>{};
    for (final d in days) {
      for (final a in d.apps.where((a) => a.category.isDistracting)) {
        final share = d.screenTime.inMinutes == 0
            ? 0.0
            : a.foreground.inMinutes / d.screenTime.inMinutes;
        d.hourBuckets.forEach((h, dur) {
          final mins = (dur.inMinutes * share).round();
          if (mins == 0) return;
          byHour.update(h, (v) => v + mins, ifAbsent: () => mins);
        });
      }
    }
    if (byHour.isEmpty) return null;
    return byHour.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
