import 'package:equatable/equatable.dart';

import '../models/app_category.dart';
import '../models/daily_stats.dart';

class NotifSourceStat extends Equatable {
  final String packageName;
  final String displayName;
  final AppCategory category;
  final int count;
  final int interruptionCost; // weighted impact

  const NotifSourceStat({
    required this.packageName,
    required this.displayName,
    required this.category,
    required this.count,
    required this.interruptionCost,
  });

  @override
  List<Object?> get props =>
      <Object?>[packageName, displayName, category, count, interruptionCost];
}

class NotificationReport extends Equatable {
  /// 0..100. Higher = more interruptive.
  final int pressureScore;

  /// Estimated minutes of refocus cost.
  final Duration refocusCost;

  /// Top sources, ordered by interruption impact.
  final List<NotifSourceStat> sources;

  /// Number of apps that look like spam (>30 notifications, distracting).
  final int spamApps;

  /// Suggested apps to mute. Up to 3 packages.
  final List<String> muteRecommendations;

  const NotificationReport({
    required this.pressureScore,
    required this.refocusCost,
    required this.sources,
    required this.spamApps,
    required this.muteRecommendations,
  });

  @override
  List<Object?> get props =>
      <Object?>[pressureScore, refocusCost, sources, spamApps, muteRecommendations];
}

class NotificationIntelligence {
  const NotificationIntelligence();

  NotificationReport analyze({
    required DailyStats today,
    required List<DailyStats> last7Days,
  }) {
    // Weight: distracting categories cost more refocus per notification.
    final sources = <NotifSourceStat>[];
    int totalCount = 0;
    int totalCost = 0;
    int spam = 0;

    for (final a in today.apps) {
      if (a.notifications == 0) continue;
      final weight = a.category.isDistracting
          ? 4
          : a.category == AppCategory.communication
              ? 2
              : 1;
      final cost = a.notifications * weight;
      totalCount += a.notifications;
      totalCost += cost;
      if (a.notifications >= 30 && a.category.isDistracting) spam++;
      sources.add(NotifSourceStat(
        packageName: a.packageName,
        displayName: a.displayName,
        category: a.category,
        count: a.notifications,
        interruptionCost: cost,
      ));
    }
    sources.sort((a, b) => b.interruptionCost.compareTo(a.interruptionCost));

    final pressure = ((totalCost / 4).clamp(0, 100)).round();
    final refocus = Duration(minutes: (totalCount * 1.5).clamp(0, 360).round());

    final mutes = sources
        .where((s) => s.count >= 20 && s.category.isDistracting)
        .take(3)
        .map((s) => s.packageName)
        .toList();

    return NotificationReport(
      pressureScore: pressure,
      refocusCost: refocus,
      sources: sources,
      spamApps: spam,
      muteRecommendations: mutes,
    );
  }
}
