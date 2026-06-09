import 'package:equatable/equatable.dart';

enum NarrativeTone { calm, energetic, reflective, alert }

enum NarrativeKind {
  weeklyHeadline,
  weeklyBody,
  monthlyHeadline,
  monthlyBody,
  milestone,
  emotionalTrend,
  morningGreeting,
  eveningWindDown,
}

class Narrative extends Equatable {
  final NarrativeKind kind;
  final NarrativeTone tone;
  final String headline;
  final String body;
  final String? emoji;
  final String? cta;
  final String? route;

  const Narrative({
    required this.kind,
    required this.tone,
    required this.headline,
    required this.body,
    this.emoji,
    this.cta,
    this.route,
  });

  @override
  List<Object?> get props =>
      <Object?>[kind, tone, headline, body, emoji, cta, route];
}

class WeeklyRetrospective extends Equatable {
  final Narrative headline;
  final List<Narrative> chapters;
  final String mostProductiveDay;
  final String mostDistractingDay;
  final Duration totalScreen;
  final Duration totalFocus;
  final int productivityIndex; // 0..100
  final int focusConsistency; // 0..100

  const WeeklyRetrospective({
    required this.headline,
    required this.chapters,
    required this.mostProductiveDay,
    required this.mostDistractingDay,
    required this.totalScreen,
    required this.totalFocus,
    required this.productivityIndex,
    required this.focusConsistency,
  });

  @override
  List<Object?> get props => <Object?>[
        headline,
        chapters,
        mostProductiveDay,
        mostDistractingDay,
        totalScreen,
        totalFocus,
        productivityIndex,
        focusConsistency,
      ];
}
