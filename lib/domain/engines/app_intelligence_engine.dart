import '../../core/utils/duration_format.dart';
import '../models/app_category.dart';
import '../models/app_intelligence.dart';
import '../models/daily_stats.dart';

class AppIntelligenceEngine {
  const AppIntelligenceEngine();

  AppIntelligenceReport analyze({
    required String packageName,
    required String displayName,
    required AppCategory category,
    required List<DailyStats> last7Days,
    required List<DailyStats> previous7Days,
  }) {
    Duration last = Duration.zero;
    Duration prev = Duration.zero;
    int sessions = 0;
    int notifs = 0;
    final hourly = List<int>.filled(24, 0);
    Duration totalScreenLast = Duration.zero;
    int nightMinutes = 0;

    AppUsage? findUsage(DailyStats day) =>
        day.apps.cast<AppUsage?>().firstWhere(
              (a) => a?.packageName == packageName,
              orElse: () => null,
            );

    for (final d in last7Days) {
      totalScreenLast += d.screenTime;
      final a = findUsage(d);
      if (a == null) continue;
      last += a.foreground;
      sessions += a.opens;
      notifs += a.notifications;

      // Distribute the app's foreground share across the day's hour buckets.
      if (d.screenTime.inMinutes > 0) {
        final share = a.foreground.inMinutes / d.screenTime.inMinutes;
        d.hourBuckets.forEach((h, dur) {
          final m = (dur.inMinutes * share).round();
          hourly[h] += m;
          if (h >= 22 || h < 5) nightMinutes += m;
        });
      }
    }
    for (final d in previous7Days) {
      final a = findUsage(d);
      if (a != null) prev += a.foreground;
    }

    final avgSession = sessions == 0
        ? Duration.zero
        : Duration(milliseconds: last.inMilliseconds ~/ sessions);

    // ---- Scores ----
    final dependency = _dependency(last, totalScreenLast, sessions);
    final productivityImpact = _productivityImpact(category, last, totalScreenLast);
    final interruption = _interruption(notifs, category);
    final focusDisruption =
        _focusDisruption(category, sessions, avgSession);
    final binge = _binge(avgSession, last);
    final night = _nightIntensity(nightMinutes, last);
    final emotional = _emotional(category, sessions, avgSession, night);

    final role = _classifyRole(
      category: category,
      sessions: sessions,
      avgSession: avgSession,
      totalLast: last,
      nightMinutes: nightMinutes,
      productivityImpact: productivityImpact,
    );

    final insights = _insightsFor(
      displayName: displayName,
      category: category,
      role: role,
      totalLast: last,
      totalPrev: prev,
      sessions: sessions,
      avgSession: avgSession,
      hourly: hourly,
      nightMinutes: nightMinutes,
      dependency: dependency,
      productivityImpact: productivityImpact,
      interruption: interruption,
    );

    return AppIntelligenceReport(
      packageName: packageName,
      displayName: displayName,
      category: category,
      role: role,
      dependencyScore: dependency,
      productivityImpact: productivityImpact,
      interruptionIndex: interruption,
      focusDisruption: focusDisruption,
      bingeTendency: binge,
      nightIntensity: night,
      emotionalUsage: emotional,
      totalLast7: last,
      totalPrev7: prev,
      sessionsLast7: sessions,
      avgSession: avgSession,
      unlockOpenCount: 0, // would need raw event data; deferred
      notificationCount7: notifs,
      hourlyMinutes: hourly,
      insights: insights,
    );
  }

  // ---------------- Scoring ----------------

  int _dependency(Duration last, Duration totalScreen, int sessions) {
    if (totalScreen.inMinutes == 0) return 0;
    final share = (last.inMinutes / totalScreen.inMinutes).clamp(0.0, 1.0);
    final freq = sessions.clamp(0, 200) / 200.0;
    final raw = share * 70 + freq * 30;
    return raw.clamp(0, 100).round();
  }

  /// -100 (strongly distracting) to +100 (strongly productive).
  int _productivityImpact(AppCategory cat, Duration last, Duration total) {
    if (total.inMinutes == 0) return 0;
    final share = last.inMinutes / total.inMinutes;
    final sign = cat.isProductive
        ? 1
        : cat.isDistracting
            ? -1
            : 0;
    return (sign * share * 200).clamp(-100, 100).round();
  }

  int _interruption(int notifs, AppCategory cat) {
    final weight = cat.isDistracting
        ? 4
        : cat == AppCategory.communication
            ? 3
            : 1;
    return (notifs * weight / 4).clamp(0, 100).round();
  }

  int _focusDisruption(AppCategory cat, int sessions, Duration avgSession) {
    // Many short opens of distracting apps = high disruption.
    if (sessions == 0) return 0;
    final shortOpens = avgSession.inSeconds < 30
        ? 1.0
        : avgSession.inSeconds < 120
            ? 0.6
            : 0.2;
    final weight = cat.isDistracting ? 1.0 : 0.4;
    return ((sessions * shortOpens * weight) / 1.5).clamp(0, 100).round();
  }

  int _binge(Duration avgSession, Duration total) {
    // Long average session + significant total = binge tendency.
    final avgScore = (avgSession.inMinutes / 30).clamp(0, 1.0) * 60;
    final volScore = (total.inMinutes / (60 * 7)).clamp(0, 1.0) * 40;
    return (avgScore + volScore).clamp(0, 100).round();
  }

  int _nightIntensity(int nightMinutes, Duration total) {
    if (total.inMinutes == 0) return 0;
    return ((nightMinutes / total.inMinutes) * 100).clamp(0, 100).round();
  }

  int _emotional(AppCategory cat, int sessions, Duration avg, int night) {
    // Heuristic: distracting-cat + many short opens + nighttime use = high emo signal.
    final base = cat.isDistracting ? 40 : (cat == AppCategory.social ? 50 : 10);
    final freqAdj = (sessions.clamp(0, 60) / 60.0) * 30;
    final shortAdj = avg.inSeconds < 90 ? 15 : 0;
    final nightAdj = (night.toDouble() / 100) * 15;
    return (base + freqAdj + shortAdj + nightAdj).clamp(0, 100).round();
  }

  AppRole _classifyRole({
    required AppCategory category,
    required int sessions,
    required Duration avgSession,
    required Duration totalLast,
    required int nightMinutes,
    required int productivityImpact,
  }) {
    if (totalLast.inMinutes < 5) return AppRole.unknown;
    if (productivityImpact >= 30) return AppRole.work;
    if (category == AppCategory.utility ||
        category == AppCategory.communication) {
      if (avgSession.inMinutes <= 3) return AppRole.utility;
      return AppRole.habit;
    }
    if (category == AppCategory.social || category == AppCategory.entertainment) {
      if (avgSession.inMinutes >= 10 ||
          totalLast.inMinutes >= 60 * 7) {
        return AppRole.dopamine;
      }
      if (nightMinutes >= 30) return AppRole.escape;
      return AppRole.dopamine;
    }
    if (category == AppCategory.gaming) return AppRole.escape;
    if (sessions >= 50) return AppRole.habit;
    return AppRole.utility;
  }

  // ---------------- Insights (specific, human) ----------------

  List<String> _insightsFor({
    required String displayName,
    required AppCategory category,
    required AppRole role,
    required Duration totalLast,
    required Duration totalPrev,
    required int sessions,
    required Duration avgSession,
    required List<int> hourly,
    required int nightMinutes,
    required int dependency,
    required int productivityImpact,
    required int interruption,
  }) {
    final out = <String>[];

    // Trend.
    if (totalPrev.inMinutes > 0) {
      final delta = totalLast.inMinutes - totalPrev.inMinutes;
      if (delta.abs() >= 30) {
        final pct = (delta * 100 ~/ totalPrev.inMinutes).abs();
        out.add(delta < 0
            ? 'You spent $pct% less time on $displayName this week.'
            : 'You spent $pct% more time on $displayName this week.');
      }
    }

    // Peak window.
    if (totalLast.inMinutes > 0) {
      int peakHour = 0;
      int peakMin = 0;
      for (int h = 0; h < 24; h++) {
        if (hourly[h] > peakMin) {
          peakMin = hourly[h];
          peakHour = h;
        }
      }
      if (peakMin >= 5) {
        final window = _windowLabel(peakHour);
        out.add(
            'Most of your $displayName time happens in $window.');
      }
    }

    // Late-night share.
    if (totalLast.inMinutes > 0) {
      final pct = (nightMinutes * 100) ~/ totalLast.inMinutes;
      if (pct >= 30) {
        out.add('$pct% of your $displayName time is between 10pm and 5am.');
      }
    }

    // Session length insight.
    if (sessions >= 5) {
      if (avgSession.inSeconds < 30) {
        out.add(
            'You open $displayName a lot but only briefly — avg ${avgSession.inSeconds}s. Compulsive checking pattern.');
      } else if (avgSession.inMinutes >= 15 && category.isDistracting) {
        out.add(
            'Sessions average ${avgSession.formatHm()}. ${displayName} pulls you in for long stretches.');
      }
    }

    // Role-flavored summary.
    switch (role) {
      case AppRole.dopamine:
        out.add(
            'Classified as a Dopamine app — high reward, low intent. Worth a Stay-Away rule.');
        break;
      case AppRole.escape:
        out.add(
            'Classified as an Escape app — you reach for it when the day is heavy.');
        break;
      case AppRole.work:
        out.add(
            'Classified as a Work app — most of this time is going somewhere productive.');
        break;
      case AppRole.habit:
        out.add(
            'Classified as a Habit — you reach for it on autopilot.');
        break;
      case AppRole.utility:
        out.add(
            'Classified as a Utility — quick in, quick out.');
        break;
      case AppRole.unknown:
        break;
    }

    // Dependency callout.
    if (dependency >= 60) {
      out.add(
          '$displayName claims $dependency% of your attention budget. High dependency.');
    }

    return out.take(5).toList();
  }

  String _windowLabel(int hour) {
    if (hour >= 5 && hour < 9) return 'early morning (5–9am)';
    if (hour >= 9 && hour < 12) return 'late morning (9am–12pm)';
    if (hour >= 12 && hour < 14) return 'lunch hour';
    if (hour >= 14 && hour < 18) return 'afternoon';
    if (hour >= 18 && hour < 22) return 'evening';
    return 'late night';
  }
}
