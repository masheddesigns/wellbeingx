import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeingx/domain/engines/sleep_engine.dart';
import 'package:wellbeingx/domain/models/daily_stats.dart';

void main() {
  DailyStats day(
    int day, {
    Map<int, Duration> hours = const <int, Duration>{},
    int? firstUnlockMinute,
    int? lastUnlockMinute,
  }) {
    final date = DateTime(2026, 1, day);
    int? at(int? minute) => minute == null
        ? null
        : date.add(Duration(minutes: minute)).millisecondsSinceEpoch;
    return DailyStats.empty(date).copyForTest(
      hourBuckets: hours,
      firstUnlockMs: at(firstUnlockMinute),
      lastUnlockMs: at(lastUnlockMinute),
    );
  }

  test('ignores tiny after-midnight peeks when inferring sleep onset', () {
    final report = const SleepEngine().analyze(
      last14Days: <DailyStats>[
        day(1),
        day(
          2,
          hours: <int, Duration>{
            1: const Duration(minutes: 24),
            2: const Duration(seconds: 8),
            6: const Duration(minutes: 8),
          },
          firstUnlockMinute: 6 * 60 + 41,
        ),
      ],
    );

    expect(report.medianBedtime.format(), '1:45 AM');
    expect(report.medianFirstPickup.format(), '6:15 AM');
    expect(report.stableWindowCount, 1);
  });

  test('does not treat an early alarm unlock as true morning pickup', () {
    final report = const SleepEngine().analyze(
      last14Days: <DailyStats>[
        day(
          1,
          hours: <int, Duration>{23: const Duration(minutes: 12)},
          lastUnlockMinute: 23 * 60 + 20,
        ),
        day(
          2,
          hours: <int, Duration>{8: const Duration(minutes: 6)},
          firstUnlockMinute: 4 * 60 + 50,
        ),
      ],
    );

    expect(report.medianBedtime.format(), '11:45 PM');
    expect(report.medianFirstPickup.format(), '8:15 AM');
    expect(report.medianSleepGap.inMinutes, 510);
  });
}

extension on DailyStats {
  DailyStats copyForTest({
    required Map<int, Duration> hourBuckets,
    int? firstUnlockMs,
    int? lastUnlockMs,
  }) {
    return DailyStats(
      day: day,
      screenTime: hourBuckets.values.fold<Duration>(
        Duration.zero,
        (sum, value) => sum + value,
      ),
      unlocks: unlocks,
      pickups: pickups,
      shortUnlocks: shortUnlocks,
      sleepMisuse: sleepMisuse,
      apps: apps,
      hourBuckets: hourBuckets,
      byCategory: byCategory,
      notifications: notifications,
      firstUnlockMs: firstUnlockMs,
      lastUnlockMs: lastUnlockMs,
      longestSession: longestSession,
      longestScreenOff: longestScreenOff,
      bingeCount: bingeCount,
      firstAppPkg: firstAppPkg,
      lastAppPkg: lastAppPkg,
    );
  }
}
