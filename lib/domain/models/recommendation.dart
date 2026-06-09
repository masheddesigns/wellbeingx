import 'package:equatable/equatable.dart';

enum RecommendationKind {
  focusSession,
  scheduleBlock,
  sleepMode,
  takeBreak,
  reduceNotifications,
  ghostWeek,
  weekendReset,
  morningRitual,
}

enum RecommendationPriority { low, medium, high, urgent }

class Recommendation extends Equatable {
  final RecommendationKind kind;
  final RecommendationPriority priority;
  final String title;
  final String body;
  final String? cta;
  final String? route;
  final Map<String, Object?> payload;

  const Recommendation({
    required this.kind,
    required this.priority,
    required this.title,
    required this.body,
    this.cta,
    this.route,
    this.payload = const <String, Object?>{},
  });

  @override
  List<Object?> get props =>
      <Object?>[kind, priority, title, body, cta, route, payload];
}
