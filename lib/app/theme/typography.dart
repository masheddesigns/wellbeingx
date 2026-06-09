import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Inter for UI, JetBrains Mono for numbers — quiet, precise.
class WxTypography {
  WxTypography._();

  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
      color: WxColors.textPrimary,
      height: 1.0,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      color: WxColors.textPrimary,
      height: 1.05,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: WxColors.textPrimary,
      height: 1.1,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: WxColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: WxColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: WxColors.textPrimary,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: WxColors.textPrimary,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: WxColors.textPrimary,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: WxColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: WxColors.textPrimary,
      height: 1.45,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: WxColors.textSecondary,
      height: 1.45,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: WxColors.textMuted,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: WxColors.textPrimary,
      letterSpacing: 0.3,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: WxColors.textSecondary,
      letterSpacing: 0.2,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
      color: WxColors.textMuted,
      letterSpacing: 1.4,
    ),
  );

  /// Mono numbers for stats. Use for big counters.
  static TextStyle mono({
    double size = 32,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color ?? WxColors.textPrimary,
      letterSpacing: letterSpacing ?? -0.5,
      height: 1.0,
    );
  }
}
