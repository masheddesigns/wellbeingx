import 'package:equatable/equatable.dart';

import '../models/daily_stats.dart';

/// Output of [BehaviorEngine.analyze].
class BehaviorReport extends Equatable {
  /// Long, infinite-feed-style sessions (>20 min on a distracting app, single open).
  final List<DoomscrollSession> doomscrolls;

  /// 0..100. Rapid-switching during a window indicates fragmented attention.
  final int rapidSwitchingScore;

  /// 0..100. High = you unlocked but didn't do much before locking again.
  final int idleUnlockScore;

  /// 0..100. Cognitive overload = many notifications + fragmented attention + sleep misuse.
  final int cognitiveOverloadScore;

  /// Estimated minutes of "recovery time" used to refocus after distractions.
  final Duration focusRecoveryTime;

  /// Distraction-loop count: closed-distraction → reopened within 60s.
  final int distractionLoops;

  /// 0..100. Productivity-vs-destruction balance.
  final int productivityScore;

  /// Weekday vs weekend totals.
  final WeekendSplit weekendSplit;

  /// Long-term direction (this week vs last week, in minutes).
  final int weekTrendDeltaMinutes;

  /// Hour-of-day productivity profile (24 values, 0..1).
  final List<double> hourlyProductivity;

  const BehaviorReport({
    required this.doomscrolls,
    required this.rapidSwitchingScore,
    required this.idleUnlockScore,
    required this.cognitiveOverloadScore,
    required this.focusRecoveryTime,
    required this.distractionLoops,
    required this.productivityScore,
    required this.weekendSplit,
    required this.weekTrendDeltaMinutes,
    required this.hourlyProductivity,
  });

  @override
  List<Object?> get props => <Object?>[
        doomscrolls,
        rapidSwitchingScore,
        idleUnlockScore,
        cognitiveOverloadScore,
        focusRecoveryTime,
        distractionLoops,
        productivityScore,
        weekendSplit,
        weekTrendDeltaMinutes,
        hourlyProductivity,
      ];
}

class DoomscrollSession extends Equatable {
  final String packageName;
  final String displayName;
  final Duration duration;
  final int hour;

  const DoomscrollSession({
    required this.packageName,
    required this.displayName,
    required this.duration,
    required this.hour,
  });

  @override
  List<Object?> get props => <Object?>[packageName, displayName, duration, hour];
}

class WeekendSplit extends Equatable {
  final Duration weekday;
  final Duration weekend;
  final Duration weekdayDailyAvg;
  final Duration weekendDailyAvg;

  const WeekendSplit({
    required this.weekday,
    required this.weekend,
    required this.weekdayDailyAvg,
    required this.weekendDailyAvg,
  });

  /// Positive = weekend is heavier; negative = weekday is heavier.
  int get weekendDeltaPct {
    if (weekdayDailyAvg.inMinutes == 0) return 0;
    return ((weekendDailyAvg.inMinutes - weekdayDailyAvg.inMinutes) * 100) ~/
        weekdayDailyAvg.inMinutes;
  }

  @override
  List<Object?> get props =>
      <Object?>[weekday, weekend, weekdayDailyAvg, weekendDailyAvg];
}

class BehaviorEngine {
  const BehaviorEngine();

  BehaviorReport analyze({
    required DailyStats today,
    required List<DailyStats> last7Days,
    required List<DailyStats> previous7Days,
  }) {
    final doomscrolls = _detectDoomscrolls(today);
    final rapidSwitch = _rapidSwitchingScore(today);
    final idleUnlock = _idleUnlockScore(today);
    final loops = _distractionLoops(today);
    final overload = _cognitiveOverload(today, rapidSwitch, idleUnlock);
    final recovery = _focusRecoveryTime(today, loops);
    final productivity = _productivityScore(today);
    final split = _weekendSplit(last7Days);
    final hourly = _hourlyProductivity(last7Days);
    final thisWeekMin = last7Days.fold<int>(
      0,
      (a, d) => a + d.screenTime.inMinutes,
    );
    final prevWeekMin = previous7Days.fold<int>(
      0,
      (a, d) => a + d.screenTime.inMinutes,
    );
    return BehaviorReport(
      doomscrolls: doomscrolls,
      rapidSwitchingScore: rapidSwitch,
      idleUnlockScore: idleUnlock,
      cognitiveOverloadScore: overload,
      focusRecoveryTime: recovery,
      distractionLoops: loops,
      productivityScore: productivity,
      weekendSplit: split,
      weekTrendDeltaMinutes: thisWeekMin - prevWeekMin,
      hourlyProductivity: hourly,
    );
  }

  // ---------- detectors ----------

  List<DoomscrollSession> _detectDoomscrolls(DailyStats day) {
    // Heuristic: distracting app, foreground >= 20 minutes, average per-open >= 8 minutes.
    final out = <DoomscrollSession>[];
    for (final app in day.apps) {
      if (!app.category.isDistracting) continue;
      final perOpen = app.opens == 0
          ? Duration.zero
          : Duration(milliseconds: app.foreground.inMilliseconds ~/ app.opens);
      if (app.foreground.inMinutes >= 20 && perOpen.inMinutes >= 8) {
        // Hour = the hour bucket where this app contributed most (approximation).
        final hour = day.peakHour ?? 21;
        out.add(DoomscrollSession(
          packageName: app.packageName,
          displayName: app.displayName,
          duration: app.foreground,
          hour: hour,
        ));
      }
    }
    return out;
  }

  /// Counts the fraction of opens that are very short. Many short opens = rapid switching.
  int _rapidSwitchingScore(DailyStats day) {
    if (day.apps.isEmpty) return 0;
    final totalOpens = day.apps.fold<int>(0, (a, b) => a + b.opens);
    if (totalOpens == 0) return 0;
    // Average ms per open.
    final totalMs = day.screenTime.inMilliseconds;
    final avgPerOpen = totalMs ~/ totalOpens;
    // Below 30s/open = high switching; above 5min/open = low.
    if (avgPerOpen <= 30 * 1000) return 100;
    if (avgPerOpen >= 5 * 60 * 1000) return 0;
    final t = 1.0 - (avgPerOpen - 30 * 1000) / (5 * 60 * 1000 - 30 * 1000);
    return (t * 100).clamp(0, 100).round();
  }

  /// Many unlocks but tiny screen time = idle unlocking.
  int _idleUnlockScore(DailyStats day) {
    if (day.unlocks == 0) return 0;
    final mins = day.screenTime.inMinutes;
    if (mins == 0) return 100;
    final ratio = day.shortUnlocks / day.unlocks; // already-detected micro sessions
    final base = (ratio * 100).clamp(0, 100);
    // Combine with overall low engagement.
    final mph = day.unlocks / (day.screenTime.inMinutes == 0 ? 1 : day.screenTime.inMinutes / 60.0);
    final mphFactor = (mph / 60.0).clamp(0, 1.0);
    return (base * 0.7 + mphFactor * 100 * 0.3).round();
  }

  /// Distracting-app foreground that ends and restarts within 60s of close.
  int _distractionLoops(DailyStats day) {
    // We don't have raw events at read-time. Approximation: count distracting apps with
    // many opens for short total time, indicating they're being reopened repeatedly.
    int loops = 0;
    for (final a in day.apps.where((a) => a.category.isDistracting)) {
      if (a.opens >= 6 && a.foreground.inMinutes <= 30) {
        loops += a.opens - 5;
      }
    }
    return loops;
  }

  /// Mental clutter — combination of inputs.
  int _cognitiveOverload(DailyStats day, int rapid, int idle) {
    final notifPressure = (day.notifications / 2).clamp(0, 100); // 200+ ≈ max
    final sleep = (day.sleepMisuse.inMinutes / 60 * 25).clamp(0, 25);
    final raw =
        notifPressure * 0.30 + rapid * 0.25 + idle * 0.20 + sleep * 0.10 +
            ((day.screenTime.inMinutes / 480) * 100).clamp(0, 15) * 1.0;
    return raw.clamp(0, 100).round();
  }

  /// Rule of thumb: each context switch eats ~23 min of refocus. We bound it to a daily cap.
  Duration _focusRecoveryTime(DailyStats day, int loops) {
    final switches = (day.shortUnlocks ~/ 3) + loops;
    final mins = (switches * 23).clamp(0, 360);
    return Duration(minutes: mins);
  }

  /// Productivity score = productive minutes / (productive + distracting), scaled.
  int _productivityScore(DailyStats day) {
    final productive = day.productiveTime.inMinutes;
    final distracting = day.distractionTime.inMinutes;
    final total = productive + distracting;
    if (total == 0) return 50; // neutral
    return ((productive / total) * 100).round();
  }

  WeekendSplit _weekendSplit(List<DailyStats> days) {
    Duration weekday = Duration.zero;
    Duration weekend = Duration.zero;
    int wdN = 0, weN = 0;
    for (final d in days) {
      // 6 = Saturday, 7 = Sunday in DateTime.weekday.
      if (d.day.weekday >= DateTime.saturday) {
        weekend += d.screenTime;
        weN++;
      } else {
        weekday += d.screenTime;
        wdN++;
      }
    }
    return WeekendSplit(
      weekday: weekday,
      weekend: weekend,
      weekdayDailyAvg: wdN == 0
          ? Duration.zero
          : Duration(microseconds: weekday.inMicroseconds ~/ wdN),
      weekendDailyAvg: weN == 0
          ? Duration.zero
          : Duration(microseconds: weekend.inMicroseconds ~/ weN),
    );
  }

  /// 24 entries: each is a 0..1 score where 1 = mostly productive at that hour.
  List<double> _hourlyProductivity(List<DailyStats> days) {
    final hourTotal = List<int>.filled(24, 0); // total ms in the hour
    final hourProd = List<int>.filled(24, 0); // productive ms in the hour (estimate)
    for (final d in days) {
      final productiveShare = d.screenTime.inMinutes == 0
          ? 0.0
          : d.productiveTime.inMinutes / d.screenTime.inMinutes;
      d.hourBuckets.forEach((h, dur) {
        hourTotal[h] += dur.inMilliseconds;
        hourProd[h] += (dur.inMilliseconds * productiveShare).round();
      });
    }
    return List<double>.generate(24, (h) {
      if (hourTotal[h] == 0) return 0.0;
      return (hourProd[h] / hourTotal[h]).clamp(0.0, 1.0);
    });
  }
}
