import 'package:equatable/equatable.dart';

import '../models/daily_stats.dart';

class ContinuousUsageReport extends Equatable {
  /// Longest single foreground session across the window.
  final Duration longestSessionEver;

  /// Median longest-session-per-day.
  final Duration medianLongestSession;

  /// Total binge sessions (>30 min on a distracting app) across the window.
  final int totalBinges;

  /// Days that contained at least one binge.
  final int daysWithBinge;

  /// Best day this window for screen-off — longest gap between sessions.
  final Duration longestScreenOffEver;

  /// Per-day series for charting: longest session minutes.
  final List<int> longestSessionPerDay;
  final List<int> bingePerDay;
  final List<DailyStats> orderedDays;

  const ContinuousUsageReport({
    required this.longestSessionEver,
    required this.medianLongestSession,
    required this.totalBinges,
    required this.daysWithBinge,
    required this.longestScreenOffEver,
    required this.longestSessionPerDay,
    required this.bingePerDay,
    required this.orderedDays,
  });

  @override
  List<Object?> get props => <Object?>[
        longestSessionEver,
        medianLongestSession,
        totalBinges,
        daysWithBinge,
        longestScreenOffEver,
        longestSessionPerDay,
        bingePerDay,
        orderedDays,
      ];
}

class ContinuousUsageEngine {
  const ContinuousUsageEngine();

  ContinuousUsageReport analyze({required List<DailyStats> days}) {
    int longestEver = 0;
    int longestOffEver = 0;
    int totalBinges = 0;
    int daysWithBinge = 0;
    final perDay = <int>[];
    final bingeDay = <int>[];

    for (final d in days) {
      final ms = d.longestSession.inMilliseconds;
      if (ms > longestEver) longestEver = ms;
      perDay.add(ms ~/ 60000);

      final off = d.longestScreenOff.inMilliseconds;
      if (off > longestOffEver) longestOffEver = off;

      bingeDay.add(d.bingeCount);
      totalBinges += d.bingeCount;
      if (d.bingeCount > 0) daysWithBinge++;
    }

    final sortedSessions = List<int>.from(perDay)..sort();
    final median = sortedSessions.isEmpty
        ? 0
        : sortedSessions[sortedSessions.length ~/ 2] * 60000;

    return ContinuousUsageReport(
      longestSessionEver: Duration(milliseconds: longestEver),
      medianLongestSession: Duration(milliseconds: median),
      totalBinges: totalBinges,
      daysWithBinge: daysWithBinge,
      longestScreenOffEver: Duration(milliseconds: longestOffEver),
      longestSessionPerDay: perDay,
      bingePerDay: bingeDay,
      orderedDays: days,
    );
  }
}
