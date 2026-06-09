import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

class WxTheme {
  WxTheme._();

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: WxColors.void_,
    canvasColor: WxColors.void_,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(
          allowEnterRouteSnapshotting: false,
        ),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: const ColorScheme.dark(
      surface: WxColors.surface0,
      onSurface: WxColors.textPrimary,
      primary: WxColors.accent,
      onPrimary: WxColors.void_,
      secondary: WxColors.cyan,
      onSecondary: WxColors.void_,
      error: WxColors.danger,
      onError: WxColors.textPrimary,
      surfaceContainerHighest: WxColors.surface2,
    ),
    textTheme: WxTypography.textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: WxColors.void_,
      foregroundColor: WxColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: WxTypography.textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: WxColors.surface1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: WxColors.hairline, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: WxColors.divider,
      thickness: 0.5,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: WxColors.textPrimary, size: 22),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: WxColors.accent,
      linearTrackColor: WxColors.surface3,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: WxColors.accent,
        foregroundColor: WxColors.void_,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: WxTypography.textTheme.titleMedium?.copyWith(
          color: WxColors.void_,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: WxColors.textPrimary,
        side: const BorderSide(color: WxColors.hairline),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: WxTypography.textTheme.titleMedium,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: WxColors.accent,
        textStyle: WxTypography.textTheme.titleSmall,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: WxColors.surface0,
      selectedItemColor: WxColors.accent,
      unselectedItemColor: WxColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showUnselectedLabels: true,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: WxColors.surface2,
      contentTextStyle: WxTypography.textTheme.bodyMedium,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: WxColors.surface1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: WxColors.accent,
      inactiveTrackColor: WxColors.surface3,
      thumbColor: WxColors.accent,
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) return WxColors.accentDeep;
        return WxColors.surface3;
      }),
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) return WxColors.accent;
        return WxColors.textMuted;
      }),
    ),
  );
}
