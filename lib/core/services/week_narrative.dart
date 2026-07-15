import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/narrative_memory_repository.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/behavior_engine.dart';
import '../../domain/engines/continuous_usage_engine.dart';
import '../../domain/engines/narrative_intelligence.dart';
import '../../domain/engines/narrative_memory_engine.dart';
import '../../domain/engines/personality_classifier.dart';
import '../../domain/engines/sleep_engine.dart';
import '../../domain/models/daily_stats.dart';
import '../../domain/models/personality_type.dart';
import '../../presentation/dashboard/dashboard_state.dart';

/// One synthesized [NarrativeWeek] + the windows that produced it. Other
/// surfaces (dashboard, replay, app shell) read from this so the app's mood
/// is consistent everywhere.
class WeekNarrative {
  final NarrativeWeek week;
  final List<DailyStats> last7Days;
  final List<DailyStats> previous7Days;
  final List<DailyStats> last28Days;
  final NarrativeMemory memory;
  const WeekNarrative({
    required this.week,
    required this.last7Days,
    required this.previous7Days,
    required this.last28Days,
    required this.memory,
  });

  WeekMood get mood => week.mood;
}

class _SynthesisParams {
  final DailyStats today;
  final List<DailyStats> last7Days;
  final List<DailyStats> previous7Days;
  final BehaviorReport behavior;
  final SleepReport sleep;
  final ContinuousUsageReport continuous;
  final PersonalityType personality;
  final List<DailyStats> last28Days;
  final List<NarrativeBeat> memoryBeats;

  const _SynthesisParams({
    required this.today,
    required this.last7Days,
    required this.previous7Days,
    required this.behavior,
    required this.sleep,
    required this.continuous,
    required this.personality,
    required this.last28Days,
    required this.memoryBeats,
  });
}

NarrativeWeek _synthesizeInIsolate(_SynthesisParams params) {
  return const NarrativeIntelligenceEngine().synthesize(
    today: params.today,
    last7Days: params.last7Days,
    previous7Days: params.previous7Days,
    behavior: params.behavior,
    sleep: params.sleep,
    continuous: params.continuous,
    personality: params.personality,
    last28Days: params.last28Days,
    memoryBeats: params.memoryBeats,
  );
}

/// Shared synthesis. Anyone who needs the mood, identity sentence, beats, or
/// the underlying windows can `ref.watch(weekNarrativeProvider)`.
final weekNarrativeProvider = FutureProvider<WeekNarrative>((ref) async {
  // Re-synthesize whenever a fresh ingest lands. Without this watch, this
  // provider caches the first synthesis forever and the Insights tab goes
  // stale until the user hot-reloads.
  ref.watch(lastIngestProvider);
  final usage = ref.watch(usageRepositoryProvider);
  final memRepo = ref.watch(narrativeMemoryRepositoryProvider);

  final last28 = await usage.rangeStats(28);
  final previous = last28.sublist(14, 21);
  final current = last28.sublist(21);
  final today = current.last;

  final behavior = const BehaviorEngine().analyze(
    today: today,
    last7Days: current,
    previous7Days: previous,
  );
  final sleep = const SleepEngine().analyze(last14Days: last28.sublist(14));
  final continuous = const ContinuousUsageEngine().analyze(days: current);
  final personality = const PersonalityClassifier().classify(current);

  // Persistent memory — load → evaluate → save. Every observation the
  // engine produces here is grounded in records, not regenerated patterns.
  final loaded = memRepo.load();
  final memUpdate = const NarrativeMemoryEngine().evaluate(
    today: today,
    last7Days: current,
    last28Days: last28,
    current: loaded,
  );
  await memRepo.save(memUpdate.next);

  final week = await compute(
    _synthesizeInIsolate,
    _SynthesisParams(
      today: today,
      last7Days: current,
      previous7Days: previous,
      behavior: behavior,
      sleep: sleep,
      continuous: continuous,
      personality: personality,
      last28Days: last28,
      memoryBeats: memUpdate.beats,
    ),
  );

  return WeekNarrative(
    week: week,
    last7Days: current,
    previous7Days: previous,
    last28Days: last28,
    memory: memUpdate.next,
  );
});

/// Convenience selector used by surfaces that only need the mood — never
/// awaits, returns null while loading or on error.
final weekMoodProvider = Provider<WeekMood?>((ref) {
  return ref.watch(weekNarrativeProvider).maybeWhen(
        data: (n) => n.mood,
        orElse: () => null,
      );
});
