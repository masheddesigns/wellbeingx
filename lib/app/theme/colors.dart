import 'package:flutter/material.dart';

/// WellbeingX palette — minimal, cyber, calm. Dark-first.
class WxColors {
  WxColors._();

  // Surface depths (dark-first).
  static const Color void_ = Color(0xFF05060A);
  static const Color surface0 = Color(0xFF0A0C12);
  static const Color surface1 = Color(0xFF11141C);
  static const Color surface2 = Color(0xFF1A1E29);
  static const Color surface3 = Color(0xFF242938);
  static const Color hairline = Color(0x14FFFFFF);
  static const Color divider = Color(0x0AFFFFFF);

  // Text.
  static const Color textPrimary = Color(0xFFF5F7FB);
  static const Color textSecondary = Color(0xFFA9B0BF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textGhost = Color(0xFF3D424D);

  // Accents — quiet electric.
  static const Color accent = Color(0xFF7CF6C2); // mint pulse
  static const Color accentDeep = Color(0xFF2EE6A6);
  static const Color cyan = Color(0xFF6FD9FF);
  static const Color violet = Color(0xFFB28DFF);
  static const Color amber = Color(0xFFFFC36A);
  static const Color rose = Color(0xFFFF8AA0);
  static const Color crimson = Color(0xFFFF5C7A);

  // Semantic.
  static const Color success = accent;
  static const Color warning = amber;
  static const Color danger = crimson;
  static const Color focus = cyan;

  // Category palette.
  static const Map<String, Color> category = <String, Color>{
    'social': Color(0xFFFF8AA0),
    'entertainment': Color(0xFFB28DFF),
    'gaming': Color(0xFFFFC36A),
    'communication': Color(0xFF6FD9FF),
    'productivity': Color(0xFF7CF6C2),
    'education': Color(0xFFA0E7B0),
    'utility': Color(0xFF8E97A8),
    'other': Color(0xFF6B7280),
  };
}
