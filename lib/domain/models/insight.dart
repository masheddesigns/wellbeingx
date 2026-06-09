import 'package:equatable/equatable.dart';

enum InsightSeverity { positive, neutral, warning, critical }

enum InsightKind {
  unlockCount,
  socialMediaTime,
  productivityDrop,
  potentialSavings,
  peakDistractionWindow,
  unusedApps,
  shortUnlockSpiral,
  sleepMisuse,
  notificationFlood,
  streak,
  focusEfficiency,
}

class Insight extends Equatable {
  final InsightKind kind;
  final InsightSeverity severity;
  final String headline;
  final String body;
  final String? cta;
  final String? route;

  const Insight({
    required this.kind,
    required this.severity,
    required this.headline,
    required this.body,
    this.cta,
    this.route,
  });

  @override
  List<Object?> get props =>
      <Object?>[kind, severity, headline, body, cta, route];
}
