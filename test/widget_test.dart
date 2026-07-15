import 'package:flutter_test/flutter_test.dart';

import 'package:wellbeingx/core/utils/date_utils.dart';
import 'package:wellbeingx/core/utils/duration_format.dart';
import 'package:wellbeingx/domain/engines/analytics_engine.dart';
import 'package:wellbeingx/domain/models/daily_stats.dart';

void main() {
  test('Duration formatting', () {
    expect(const Duration(minutes: 26).formatHm(), '26m');
    expect(const Duration(hours: 4, minutes: 26).formatHm(), '4h 26m');
    expect(const Duration(seconds: 45).formatHm(), '45s');
    expect(const Duration(hours: 2).formatHm(), '2h');
  });

  test('Analytics engine summarises empty input safely', () {
    final summary = const AnalyticsEngine().summarize(
      currentWeek: <DailyStats>[],
      previousWeek: <DailyStats>[],
    );
    expect(summary.weekTotal, Duration.zero);
    expect(summary.growthPct, 0);
    expect(summary.topApps, isEmpty);
  });

  test('Day epochs round-trip to the same local calendar day', () {
    final source = DateTime(2026, 7, 15, 14, 30);
    final restored = WxDates.fromDayEpoch(WxDates.dayEpoch(source));

    expect(restored, DateTime(2026, 7, 15));
  });
}
