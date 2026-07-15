import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../models/daily_stats.dart';

class SleepReport extends Equatable {
  /// Median minutes between probable sleep onset and first sustained morning
  /// pickup. This is inferred from inactivity, not treated as a literal sleep
  /// measurement.
  final Duration medianSleepGap;

  /// Median time-of-day for probable disengagement before sleep.
  final TimeOfDayMin medianBedtime;

  /// Median time-of-day for first sustained morning interaction.
  final TimeOfDayMin medianFirstPickup;

  /// 0..100. Variance in bedtime across days. Lower variance = higher
  /// score = more consistent.
  final int bedtimeConsistency;

  /// Total minutes spent on the phone between 22:00 and 05:00 across the window.
  final Duration nightUsage;

  /// Sequence of last-usage minutes-of-day for the trend chart.
  final List<int?> lastUsageHistory;

  /// Sequence of first-unlock minutes-of-day for the trend chart.
  final List<int?> firstPickupHistory;

  /// Number of nights where the inactivity signal was strong enough to infer
  /// sleep. When low, copy should say the window is unclear.
  final int stableWindowCount;

  /// Number of nights with meaningful post-onset use before morning pickup.
  final int fragmentedNightCount;

  const SleepReport({
    required this.medianSleepGap,
    required this.medianBedtime,
    required this.medianFirstPickup,
    required this.bedtimeConsistency,
    required this.nightUsage,
    required this.lastUsageHistory,
    required this.firstPickupHistory,
    required this.stableWindowCount,
    required this.fragmentedNightCount,
  });

  @override
  List<Object?> get props => <Object?>[
    medianSleepGap,
    medianBedtime,
    medianFirstPickup,
    bedtimeConsistency,
    nightUsage,
    lastUsageHistory,
    firstPickupHistory,
    stableWindowCount,
    fragmentedNightCount,
  ];
}

class TimeOfDayMin {
  final int? minuteOfDay; // null if no data
  const TimeOfDayMin(this.minuteOfDay);

  String format() {
    final m = minuteOfDay;
    if (m == null) return '—';
    final h = (m ~/ 60) % 24;
    final mm = m % 60;
    final hr12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final ampm = h < 12 ? 'AM' : 'PM';
    final mmStr = mm.toString().padLeft(2, '0');
    return '$hr12:$mmStr $ampm';
  }
}

class SleepEngine {
  const SleepEngine();

  SleepReport analyze({required List<DailyStats> last14Days}) {
    final lastUsage = <int?>[]; // probable sleep onset minute of day
    final firstPickups = <int?>[];
    final sleepGapsMs = <int>[];
    int nightMs = 0;
    var stableWindows = 0;
    var fragmentedNights = 0;

    for (int i = 0; i < last14Days.length; i++) {
      final d = last14Days[i];
      final next = i < last14Days.length - 1 ? last14Days[i + 1] : null;
      final night = next == null ? null : _inferNight(d, next);

      lastUsage.add(night?.sleepOnsetMinute);
      firstPickups.add(night?.firstPickupMinute);
      if (night?.stableWindow == true) stableWindows++;
      if (night?.fragmented == true) fragmentedNights++;

      if (night != null && night.stableWindow) {
        sleepGapsMs.add(night.sleepGap.inMilliseconds);
      }

      // Night usage approximation from hour buckets 22..23, 0..4.
      d.hourBuckets.forEach((h, dur) {
        if (h >= 22 || h < 5) nightMs += dur.inMilliseconds;
      });
    }

    final medianGap = _medianMs(sleepGapsMs);
    final bedtime = TimeOfDayMin(_medianMinute(lastUsage));
    final firstUp = TimeOfDayMin(_medianMinute(firstPickups));

    // Consistency = inverse of variance, mapped to 0..100.
    final bedtimes = lastUsage
        .whereType<int>()
        .map((m) => _bedtimeMin(m))
        .toList();
    final consistency = _consistencyScore(bedtimes);

    return SleepReport(
      medianSleepGap: Duration(milliseconds: medianGap ?? 0),
      medianBedtime: bedtime,
      medianFirstPickup: firstUp,
      bedtimeConsistency: consistency,
      nightUsage: Duration(milliseconds: nightMs),
      lastUsageHistory: lastUsage,
      firstPickupHistory: firstPickups,
      stableWindowCount: stableWindows,
      fragmentedNightCount: fragmentedNights,
    );
  }

  _NightInference? _inferNight(DailyStats evening, DailyStats morning) {
    final events = <_NightPoint>[];

    void addPoint({
      required int hour,
      required Duration duration,
      required int dayOffset,
    }) {
      final mins = duration.inMinutes;
      if (mins < 2) return; // micro residue / notification peeks
      final meaningful = mins >= 5;
      events.add(
        _NightPoint(
          minute: dayOffset * 1440 + hour * 60 + (meaningful ? 45 : 15),
          meaningful: meaningful,
        ),
      );
    }

    for (int h = 20; h <= 23; h++) {
      addPoint(
        hour: h,
        duration: evening.hourBuckets[h] ?? Duration.zero,
        dayOffset: 0,
      );
    }
    for (int h = 0; h <= 5; h++) {
      addPoint(
        hour: h,
        duration: morning.hourBuckets[h] ?? Duration.zero,
        dayOffset: 1,
      );
    }

    events.sort((a, b) => a.minute.compareTo(b.minute));
    final meaningful = events.where((e) => e.meaningful).toList();
    final pickup = _firstIntentionalMorningPickup(morning);

    if (meaningful.isEmpty) {
      final fallback = _fallbackOnsetFromUnlock(evening);
      if (fallback == null || pickup == null) return null;
      final gap = Duration(minutes: (1440 + pickup) - fallback);
      if (gap.inMinutes < 90 || gap.inHours > 14) return null;
      return _NightInference(
        sleepOnsetMinute: fallback,
        firstPickupMinute: pickup,
        sleepGap: gap,
        stableWindow: true,
        fragmented: false,
      );
    }

    for (int i = meaningful.length - 1; i >= 0; i--) {
      final candidate = meaningful[i];
      final nextMeaningful = _firstAfter(meaningful, candidate.minute);
      final inactivityEnd =
          nextMeaningful?.minute ??
          (pickup == null ? 1440 + 6 * 60 : 1440 + pickup);
      final inactivity = inactivityEnd - candidate.minute;
      if (inactivity < 90) continue;
      if (pickup == null) continue;
      final pickupAbs = 1440 + pickup;
      final gap = Duration(minutes: pickupAbs - candidate.minute);
      if (gap.inMinutes < 90 || gap.inHours > 14) continue;
      final disturbances = meaningful
          .where((e) => e.minute > candidate.minute && e.minute < pickupAbs)
          .length;
      return _NightInference(
        sleepOnsetMinute: candidate.minute % 1440,
        firstPickupMinute: pickup,
        sleepGap: gap,
        stableWindow: disturbances <= 1,
        fragmented: disturbances > 0,
      );
    }

    return null;
  }

  int? _fallbackOnsetFromUnlock(DailyStats evening) {
    final last = evening.lastUnlockMs;
    if (last == null) return null;
    final m = _minuteOfDay(last);
    if (m == null) return null;
    // Only trust unlock fallback in the evening sleep window. After midnight
    // belongs to the next day and is handled through hour buckets.
    if (m < 20 * 60) return null;
    return m;
  }

  int? _firstIntentionalMorningPickup(DailyStats morning) {
    final meaningfulHour = _firstMorningHour(morning, minimumMinutes: 2);
    final sustainedHour = _firstMorningHour(morning, minimumMinutes: 5);
    final firstUnlock = _minuteOfDay(morning.firstUnlockMs);

    if (sustainedHour != null) return sustainedHour * 60 + 15;
    if (meaningfulHour != null) return meaningfulHour * 60 + 15;
    if (firstUnlock == null) return null;

    // Treat very early unlocks as alarm/time checks unless supported by usage.
    if (firstUnlock < 5 * 60) return null;
    return firstUnlock;
  }

  int? _firstMorningHour(DailyStats d, {required int minimumMinutes}) {
    for (int h = 5; h <= 11; h++) {
      if ((d.hourBuckets[h] ?? Duration.zero).inMinutes >= minimumMinutes) {
        return h;
      }
    }
    return null;
  }

  _NightPoint? _firstAfter(List<_NightPoint> points, int minute) {
    for (final point in points) {
      if (point.minute > minute) return point;
    }
    return null;
  }

  int? _minuteOfDay(int? ms) {
    if (ms == null) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return dt.hour * 60 + dt.minute;
  }

  /// Convert minute-of-day to a "bedtime number" anchored around midnight so
  /// that 23:30 (1410) and 00:30 (30) read as adjacent values for consistency.
  int _bedtimeMin(int m) {
    // Shift so 12:00 noon is the anchor; 00:00 → 720, 23:30 → 690, 00:30 → 750.
    return (m + 720) % 1440;
  }

  int? _medianMs(List<int> xs) {
    if (xs.isEmpty) return null;
    final sorted = List<int>.from(xs)..sort();
    return sorted[sorted.length ~/ 2];
  }

  int? _medianMinute(List<int?> xs) {
    final clean = xs.whereType<int>().toList()..sort();
    if (clean.isEmpty) return null;
    return clean[clean.length ~/ 2];
  }

  int _consistencyScore(List<int> bedtimes) {
    if (bedtimes.length < 3) return 0;
    final avg = bedtimes.reduce((a, b) => a + b) / bedtimes.length;
    double sumSq = 0;
    for (final b in bedtimes) {
      sumSq += (b - avg) * (b - avg);
    }
    final variance = sumSq / bedtimes.length;
    final stdDev = math.sqrt(variance);
    // 0 stdDev → 100. Above 90 minutes → 0.
    final v = (1 - (stdDev / 90.0)).clamp(0.0, 1.0);
    return (v * 100).round();
  }
}

class _NightPoint {
  final int minute; // may exceed 1440 for after-midnight events
  final bool meaningful;
  const _NightPoint({required this.minute, required this.meaningful});
}

class _NightInference {
  final int sleepOnsetMinute;
  final int firstPickupMinute;
  final Duration sleepGap;
  final bool stableWindow;
  final bool fragmented;
  const _NightInference({
    required this.sleepOnsetMinute,
    required this.firstPickupMinute,
    required this.sleepGap,
    required this.stableWindow,
    required this.fragmented,
  });
}
