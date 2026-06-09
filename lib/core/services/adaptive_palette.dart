import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../domain/models/composite_score.dart';

/// Subtle accent + glow shift based on the user's current mental state.
/// Calm = mint, energetic = mint+cyan, alert = amber, critical = rose.
/// We never repaint the whole UI — only the hero-card gradient endpoints.
class AdaptivePalette {
  final Color heroFrom;
  final Color heroTo;
  final Color glow;
  final Color hint;
  final String mood;

  const AdaptivePalette({
    required this.heroFrom,
    required this.heroTo,
    required this.glow,
    required this.hint,
    required this.mood,
  });

  static AdaptivePalette neutral() => const AdaptivePalette(
        heroFrom: Color(0xFF12161F),
        heroTo: Color(0xFF0B0E14),
        glow: WxColors.accent,
        hint: WxColors.textSecondary,
        mood: 'steady',
      );

  factory AdaptivePalette.forBand(ScoreBand band) {
    switch (band) {
      case ScoreBand.calm:
        return const AdaptivePalette(
          heroFrom: Color(0xFF0F1A18),
          heroTo: Color(0xFF080A0E),
          glow: WxColors.accent,
          hint: WxColors.accent,
          mood: 'calm',
        );
      case ScoreBand.steady:
        return const AdaptivePalette(
          heroFrom: Color(0xFF0E1620),
          heroTo: Color(0xFF080A0E),
          glow: WxColors.cyan,
          hint: WxColors.cyan,
          mood: 'steady',
        );
      case ScoreBand.alert:
        return const AdaptivePalette(
          heroFrom: Color(0xFF1F1812),
          heroTo: Color(0xFF0A0807),
          glow: WxColors.amber,
          hint: WxColors.amber,
          mood: 'alert',
        );
      case ScoreBand.critical:
        return const AdaptivePalette(
          heroFrom: Color(0xFF1F0F14),
          heroTo: Color(0xFF09060A),
          glow: WxColors.crimson,
          hint: WxColors.crimson,
          mood: 'overload',
        );
    }
  }
}

final adaptivePaletteProvider =
    StateProvider<AdaptivePalette>((ref) => AdaptivePalette.neutral());
