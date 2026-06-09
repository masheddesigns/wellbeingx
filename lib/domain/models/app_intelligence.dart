import 'package:equatable/equatable.dart';

import 'app_category.dart';

enum AppRole {
  work('Work', 'Tools you use to make things happen.', '🛠️'),
  utility('Utility', 'Quick, purposeful — in and out.', '🧭'),
  habit('Habit', 'A routine you reach for daily.', '🔁'),
  escape('Escape', 'Where you go when the day is heavy.', '🌫️'),
  dopamine('Dopamine', 'Short-form, fast feedback, addictive.', '🎰'),
  unknown('Other', 'Not enough use to characterise.', '·');

  final String label;
  final String description;
  final String emoji;
  const AppRole(this.label, this.description, this.emoji);
}

class AppIntelligenceReport extends Equatable {
  final String packageName;
  final String displayName;
  final AppCategory category;
  final AppRole role;

  // 0..100 scores
  final int dependencyScore;
  final int productivityImpact; // negative dist, positive prod (-100..100)
  final int interruptionIndex;
  final int focusDisruption;
  final int bingeTendency;
  final int nightIntensity;
  final int emotionalUsage;

  // Stats
  final Duration totalLast7;
  final Duration totalPrev7;
  final int sessionsLast7;
  final Duration avgSession;
  final int unlockOpenCount; // how often this app is the FIRST thing after unlock
  final int notificationCount7;
  final List<int> hourlyMinutes; // 0..23, summed across last 7 days

  // Stories
  final List<String> insights;

  const AppIntelligenceReport({
    required this.packageName,
    required this.displayName,
    required this.category,
    required this.role,
    required this.dependencyScore,
    required this.productivityImpact,
    required this.interruptionIndex,
    required this.focusDisruption,
    required this.bingeTendency,
    required this.nightIntensity,
    required this.emotionalUsage,
    required this.totalLast7,
    required this.totalPrev7,
    required this.sessionsLast7,
    required this.avgSession,
    required this.unlockOpenCount,
    required this.notificationCount7,
    required this.hourlyMinutes,
    required this.insights,
  });

  /// Positive = up vs last week (worse for distractions, better for productivity).
  int get weekTrendPct {
    if (totalPrev7.inMinutes == 0) return 0;
    return ((totalLast7.inMinutes - totalPrev7.inMinutes) * 100) ~/
        totalPrev7.inMinutes;
  }

  @override
  List<Object?> get props => <Object?>[
        packageName,
        displayName,
        category,
        role,
        dependencyScore,
        productivityImpact,
        interruptionIndex,
        focusDisruption,
        bingeTendency,
        nightIntensity,
        emotionalUsage,
        totalLast7,
        totalPrev7,
        sessionsLast7,
        avgSession,
        unlockOpenCount,
        notificationCount7,
        hourlyMinutes,
        insights,
      ];
}
