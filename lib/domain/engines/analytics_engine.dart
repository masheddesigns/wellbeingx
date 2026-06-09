import 'package:equatable/equatable.dart';

import '../models/app_category.dart';
import '../models/daily_stats.dart';

class AnalyticsSummary extends Equatable {
  final Duration weekTotal;
  final Duration prevWeekTotal;
  final Duration weekDailyAvg;
  final Map<AppCategory, Duration> weekByCategory;
  final List<AppUsage> topApps;
  final double focusEfficiency; // 0..1
  final int growthPct; // % vs previous week (negative = reduction)
  final Duration projectedSavings; // achievable weekly savings if 50% cut on top distractions
  final Duration lifeLost; // alias of total over the input window

  const AnalyticsSummary({
    required this.weekTotal,
    required this.prevWeekTotal,
    required this.weekDailyAvg,
    required this.weekByCategory,
    required this.topApps,
    required this.focusEfficiency,
    required this.growthPct,
    required this.projectedSavings,
    required this.lifeLost,
  });

  @override
  List<Object?> get props => <Object?>[
        weekTotal,
        prevWeekTotal,
        weekDailyAvg,
        weekByCategory,
        topApps,
        focusEfficiency,
        growthPct,
        projectedSavings,
        lifeLost,
      ];
}

class AnalyticsEngine {
  const AnalyticsEngine();

  AnalyticsSummary summarize({
    required List<DailyStats> currentWeek,
    required List<DailyStats> previousWeek,
    Duration deepWorkThisWeek = Duration.zero,
  }) {
    final weekTotal = _sumScreen(currentWeek);
    final prev = _sumScreen(previousWeek);
    final daily = currentWeek.isEmpty
        ? Duration.zero
        : Duration(microseconds: weekTotal.inMicroseconds ~/ currentWeek.length);

    final byCat = <AppCategory, Duration>{};
    final byApp = <String, AppUsage>{};
    for (final d in currentWeek) {
      d.byCategory.forEach((k, v) {
        byCat.update(k, (curr) => curr + v, ifAbsent: () => v);
      });
      for (final a in d.apps) {
        final existing = byApp[a.packageName];
        byApp[a.packageName] = AppUsage(
          packageName: a.packageName,
          displayName: a.displayName,
          category: a.category,
          foreground: (existing?.foreground ?? Duration.zero) + a.foreground,
          opens: (existing?.opens ?? 0) + a.opens,
          notifications: (existing?.notifications ?? 0) + a.notifications,
        );
      }
    }
    final top = byApp.values.toList()
      ..sort((a, b) => b.foreground.compareTo(a.foreground));

    int growthPct = 0;
    if (prev.inSeconds > 0) {
      growthPct = ((weekTotal.inSeconds - prev.inSeconds) * 100) ~/ prev.inSeconds;
    }

    final distraction = top
        .where((a) => a.category.isDistracting)
        .take(3)
        .fold<Duration>(Duration.zero, (a, b) => a + b.foreground);
    final savings =
        Duration(microseconds: distraction.inMicroseconds ~/ 2);

    final activeForeground = currentWeek.fold<Duration>(
      Duration.zero,
      (a, d) => a + d.screenTime,
    );
    final totalActive = activeForeground.inMinutes + deepWorkThisWeek.inMinutes;
    final efficiency = totalActive == 0
        ? 0.0
        : deepWorkThisWeek.inMinutes / totalActive;

    return AnalyticsSummary(
      weekTotal: weekTotal,
      prevWeekTotal: prev,
      weekDailyAvg: daily,
      weekByCategory: byCat,
      topApps: top.take(8).toList(),
      focusEfficiency: efficiency.clamp(0, 1),
      growthPct: growthPct,
      projectedSavings: savings,
      lifeLost: weekTotal,
    );
  }

  Duration _sumScreen(List<DailyStats> days) =>
      days.fold<Duration>(Duration.zero, (a, b) => a + b.screenTime);
}
