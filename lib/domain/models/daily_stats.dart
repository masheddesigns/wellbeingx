import 'package:equatable/equatable.dart';

import 'app_category.dart';

class AppUsage extends Equatable {
  final String packageName;
  final String displayName;
  final AppCategory category;
  final Duration foreground;
  final int opens;
  final int notifications;

  const AppUsage({
    required this.packageName,
    required this.displayName,
    required this.category,
    required this.foreground,
    required this.opens,
    required this.notifications,
  });

  @override
  List<Object?> get props => <Object?>[
        packageName,
        displayName,
        category,
        foreground,
        opens,
        notifications,
      ];
}

class DailyStats extends Equatable {
  final DateTime day;
  final Duration screenTime;
  final int unlocks;
  final int pickups;
  final int shortUnlocks;
  final Duration sleepMisuse;
  final List<AppUsage> apps;
  final Map<int, Duration> hourBuckets; // 0..23
  final Map<AppCategory, Duration> byCategory;
  final int notifications;
  // Behavioral history fields (v3).
  final int? firstUnlockMs;
  final int? lastUnlockMs;
  final Duration longestSession;
  final Duration longestScreenOff;
  final int bingeCount;
  final String? firstAppPkg;
  final String? lastAppPkg;

  const DailyStats({
    required this.day,
    required this.screenTime,
    required this.unlocks,
    required this.pickups,
    required this.shortUnlocks,
    required this.sleepMisuse,
    required this.apps,
    required this.hourBuckets,
    required this.byCategory,
    required this.notifications,
    this.firstUnlockMs,
    this.lastUnlockMs,
    this.longestSession = Duration.zero,
    this.longestScreenOff = Duration.zero,
    this.bingeCount = 0,
    this.firstAppPkg,
    this.lastAppPkg,
  });

  factory DailyStats.empty(DateTime day) => DailyStats(
        day: day,
        screenTime: Duration.zero,
        unlocks: 0,
        pickups: 0,
        shortUnlocks: 0,
        sleepMisuse: Duration.zero,
        apps: const <AppUsage>[],
        hourBuckets: const <int, Duration>{},
        byCategory: const <AppCategory, Duration>{},
        notifications: 0,
      );

  Duration get socialTime => byCategory[AppCategory.social] ?? Duration.zero;
  Duration get entertainmentTime =>
      byCategory[AppCategory.entertainment] ?? Duration.zero;
  Duration get productiveTime =>
      (byCategory[AppCategory.productivity] ?? Duration.zero) +
      (byCategory[AppCategory.education] ?? Duration.zero);
  Duration get distractionTime =>
      socialTime + entertainmentTime +
      (byCategory[AppCategory.gaming] ?? Duration.zero);

  /// Peak hour by foreground time (or null if no usage).
  int? get peakHour {
    if (hourBuckets.isEmpty) return null;
    return hourBuckets.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  AppUsage? get topApp => apps.isEmpty ? null : apps.first;

  @override
  List<Object?> get props => <Object?>[
        day,
        screenTime,
        unlocks,
        pickups,
        shortUnlocks,
        sleepMisuse,
        apps,
        hourBuckets,
        byCategory,
        notifications,
      ];
}
