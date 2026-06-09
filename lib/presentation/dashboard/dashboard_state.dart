import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/adaptive_palette.dart';
import '../../core/services/diagnostics.dart';
import '../../core/services/native_bridge.dart';
import '../../data/repositories/focus_repository.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/analytics_engine.dart';
import '../../domain/engines/behavior_engine.dart';
import '../../domain/engines/composite_scores.dart';
import '../../domain/engines/insight_engine.dart';
import '../../domain/engines/narrative_engine.dart';
import '../../domain/engines/notification_intelligence.dart';
import '../../domain/engines/personality_classifier.dart';
import '../../domain/engines/recommendation_engine.dart';
import '../../domain/models/composite_score.dart';
import '../../domain/models/daily_stats.dart';
import '../../domain/models/gamification.dart';
import '../../domain/models/insight.dart';
import '../../domain/models/narrative.dart';
import '../../domain/models/personality_type.dart';
import '../../domain/models/recommendation.dart';

class DashboardSnapshot extends Equatable {
  final DailyStats today;
  final List<DailyStats> last7Days;
  final List<DailyStats> previous7Days;
  final AnalyticsSummary summary;
  final BehaviorReport behavior;
  final ScorePack scores;
  final GamificationState gami;
  final List<Insight> insights;
  final List<Recommendation> recommendations;
  final List<String> unusedAppNames;
  final Narrative opener;
  final List<Narrative> milestones;
  final PersonalityType personality;
  final AdaptivePalette palette;
  final bool ingesting;

  const DashboardSnapshot({
    required this.today,
    required this.last7Days,
    required this.previous7Days,
    required this.summary,
    required this.behavior,
    required this.scores,
    required this.gami,
    required this.insights,
    required this.recommendations,
    required this.unusedAppNames,
    required this.opener,
    required this.milestones,
    required this.personality,
    required this.palette,
    required this.ingesting,
  });

  @override
  List<Object?> get props => <Object?>[
        today,
        last7Days,
        previous7Days,
        summary,
        behavior,
        scores,
        gami,
        insights,
        recommendations,
        unusedAppNames,
        opener,
        milestones,
        personality,
        palette,
        ingesting,
      ];
}

final ingestingProvider = StateProvider<bool>((_) => false);

/// Last successful ingest timestamp (epoch ms). 0 = never.
final lastIngestProvider = StateProvider<int>((_) => 0);

final dashboardProvider = FutureProvider<DashboardSnapshot>((ref) async {
  final usage = ref.watch(usageRepositoryProvider);
  final gamiRepo = ref.watch(gamificationRepositoryProvider);
  final focusRepo = ref.watch(focusRepositoryProvider);

  final last14 = await usage.rangeStats(14);
  final previous = last14.sublist(0, 7);
  final current = last14.sublist(7);
  final today = current.last;
  final unused = await usage.unusedApps();
  final gami = await gamiRepo.read();
  final weeklyFocus = await focusRepo.totalCompletedThisWeek();
  final summary = const AnalyticsEngine().summarize(
    currentWeek: current,
    previousWeek: previous,
    deepWorkThisWeek: weeklyFocus,
  );
  final behavior = const BehaviorEngine().analyze(
    today: today,
    last7Days: current,
    previous7Days: previous,
  );
  final notif = const NotificationIntelligence().analyze(
    today: today,
    last7Days: current,
  );
  final scores = const CompositeScoresEngine().compute(
    today: today,
    last7Days: current,
    previous7Days: previous,
    behavior: behavior,
    notif: notif,
  );
  final personality = const PersonalityClassifier().classify(current);
  final opener = const NarrativeEngine().dailyOpener(
    today: today,
    behavior: behavior,
    personality: personality,
  );
  final milestones = const NarrativeEngine().milestones(
    currentStreak: gami.currentStreak,
    longestStreak: gami.longestStreak,
    weeklyFocus: weeklyFocus,
    prevWeeklyFocus: Duration.zero,
    scores: scores,
  );
  final insights = const InsightEngine().generate(
    today: today,
    last7Days: current,
    summary: summary,
    gami: gami,
    unusedAppNames: unused.map((m) => m.displayName).toList(),
  );
  final recommendations = const RecommendationEngine().generate(
    today: today,
    last7Days: current,
    behavior: behavior,
  );

  // Adaptive palette follows the worst-band score so the UI mood matches state.
  final worstBand = _worstBand(scores.all);
  final palette = AdaptivePalette.forBand(worstBand);

  return DashboardSnapshot(
    today: today,
    last7Days: current,
    previous7Days: previous,
    summary: summary,
    behavior: behavior,
    scores: scores,
    gami: gami,
    insights: insights,
    recommendations: recommendations,
    unusedAppNames: unused.map((m) => m.displayName).toList(),
    opener: opener,
    milestones: milestones,
    personality: personality,
    palette: palette,
    ingesting: ref.watch(ingestingProvider),
  );
});

ScoreBand _worstBand(List<CompositeScore> scores) {
  ScoreBand worst = ScoreBand.calm;
  for (final s in scores) {
    if (s.band.index > worst.index) worst = s.band;
  }
  return worst;
}

Future<void> runBackgroundIngest(WidgetRef ref) async {
  if (ref.read(ingestingProvider)) return;
  final usage = ref.read(usageRepositoryProvider);
  final native = ref.read(nativeBridgeProvider);

  bool hasUsage = false;
  try {
    hasUsage = await native.hasUsageAccess();
  } catch (e, st) {
    WxLog.error('ingest', 'hasUsageAccess threw', e, st);
  }
  if (!hasUsage) {
    WxLog.warn('ingest', 'usage access not granted, skipping');
    return;
  }

  ref.read(ingestingProvider.notifier).state = true;
  WxLog.info('ingest', 'started');
  try {
    await usage.ingest();
    ref.read(lastIngestProvider.notifier).state =
        DateTime.now().millisecondsSinceEpoch;
    WxLog.info('ingest', 'completed');
  } catch (e, st) {
    WxLog.error('ingest', 'failed', e, st);
  } finally {
    // ingestingProvider is watched by dashboardProvider, so flipping this
    // triggers a single rebuild. Avoid invalidating on top of it — that
    // produced two cascading rebuilds and could occur mid-navigation,
    // contributing to navigator key collisions.
    ref.read(ingestingProvider.notifier).state = false;
  }
}
