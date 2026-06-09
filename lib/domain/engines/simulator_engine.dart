import '../../core/utils/duration_format.dart';
import '../models/daily_stats.dart';

/// "What if I cut Instagram by 30 minutes a day?" — turns a delta on a single
/// app into a year-scale projection.
class SimulationResult {
  final String packageName;
  final String displayName;
  final Duration dailyDelta; // negative = reduction
  final Duration weeklySaved;
  final Duration yearSaved;
  final int booksReadable; // crude unit conversion: 8h/book
  final int workoutsPossible; // 30min units
  final String headline;

  const SimulationResult({
    required this.packageName,
    required this.displayName,
    required this.dailyDelta,
    required this.weeklySaved,
    required this.yearSaved,
    required this.booksReadable,
    required this.workoutsPossible,
    required this.headline,
  });
}

class SimulatorEngine {
  const SimulatorEngine();

  SimulationResult simulate({
    required AppUsage app,
    required Duration dailyDelta, // typically negative for reductions
  }) {
    final saved = -dailyDelta; // positive number for saved time
    final weekly = saved * 7;
    final yearly = saved * 365;
    final books = (yearly.inHours / 8).floor().clamp(0, 1 << 31);
    final workouts = (yearly.inMinutes / 30).floor().clamp(0, 1 << 31);
    final headline = saved.inMinutes <= 0
        ? "That's no reduction at all."
        : 'Saving ${saved.formatHm()} a day from ${app.displayName}'
            ' = ${yearly.formatHm()} a year.';
    return SimulationResult(
      packageName: app.packageName,
      displayName: app.displayName,
      dailyDelta: dailyDelta,
      weeklySaved: weekly,
      yearSaved: yearly,
      booksReadable: books,
      workoutsPossible: workouts,
      headline: headline,
    );
  }
}
