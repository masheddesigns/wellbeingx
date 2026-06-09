import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_service.dart';

enum WxThemeVariant {
  cyber('Cyber', 'Mint pulse on near-black.', Color(0xFF05060A)),
  amoled('AMOLED', 'True black for OLED.', Color(0xFF000000)),
  minimal('Minimal', 'Slate over deep grey.', Color(0xFF12141A));

  final String label;
  final String description;
  final Color background;
  const WxThemeVariant(this.label, this.description, this.background);
}

const _kThemeVariantKey = 'wx_theme_variant';

class ThemeController extends Notifier<WxThemeVariant> {
  @override
  WxThemeVariant build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final code = prefs.getString(_kThemeVariantKey);
    if (code == null) return WxThemeVariant.cyber;
    return WxThemeVariant.values.firstWhere(
      (v) => v.name == code,
      orElse: () => WxThemeVariant.cyber,
    );
  }

  Future<void> set(WxThemeVariant v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeVariantKey, v.name);
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, WxThemeVariant>(ThemeController.new);
