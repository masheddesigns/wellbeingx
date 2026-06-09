import 'dart:async';

import 'package:flutter/services.dart';

/// Premium-feel haptics. Each method is a *semantic* event — never a raw
/// HapticFeedback call from the call site. That keeps interaction feel
/// consistent across the app and easy to tune in one place.
class Haptics {
  Haptics._();

  /// Master switch. Wire to settings later.
  static bool enabled = true;

  // ---- Atomic primitives ----
  static Future<void> _selection() =>
      enabled ? HapticFeedback.selectionClick() : Future<void>.value();
  static Future<void> _light() =>
      enabled ? HapticFeedback.lightImpact() : Future<void>.value();
  static Future<void> _medium() =>
      enabled ? HapticFeedback.mediumImpact() : Future<void>.value();
  static Future<void> _heavy() =>
      enabled ? HapticFeedback.heavyImpact() : Future<void>.value();

  // ---- Generic taps (used everywhere) ----
  static Future<void> tap() => _selection();
  static Future<void> light() => _light();
  static Future<void> success() => _medium();
  static Future<void> heavy() => _heavy();

  // ---- Semantic events (preferred at call sites) ----

  /// Bottom-nav tab switch — quick, dry click.
  static Future<void> tabSwitch() => _selection();

  /// Card tap (insight, app row, recommendation).
  static Future<void> cardTap() => _selection();

  /// Toggle / switch / chip selection.
  static Future<void> toggle() => _light();

  /// Scroll snap on a horizontal carousel.
  static Future<void> scrollStop() => _selection();

  /// Pull-to-refresh trigger.
  static Future<void> pullRefresh() => _light();

  /// Long-press confirmation.
  static Future<void> longPress() => _medium();

  /// Focus session begins.
  static Future<void> focusStart() => _medium();

  /// Focus phase boundary (work→break, etc).
  static Future<void> focusPhase() => _light();

  /// Focus session completes successfully.
  static Future<void> focusComplete() async {
    await _medium();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _light();
  }

  /// Daily reward / coin claim.
  static Future<void> reward() async {
    await _light();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await _medium();
  }

  /// Achievement unlock.
  static Future<void> achievement() async {
    await _heavy();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await _medium();
  }

  /// Streak milestone (7d, 30d, etc).
  static Future<void> streakMilestone() async {
    await _medium();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _medium();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _heavy();
  }

  /// Replay play / pause control.
  static Future<void> replayControl() => _selection();

  /// Timeline scrubber position change.
  static Future<void> scrub() => _selection();

  /// Critical insight reveal (e.g. doomscroll detected).
  static Future<void> criticalReveal() async {
    await _heavy();
  }

  /// Ghost Week reveal moment.
  static Future<void> ghostReveal() async {
    await _heavy();
    await Future<void>.delayed(const Duration(milliseconds: 220));
    await _medium();
    await Future<void>.delayed(const Duration(milliseconds: 220));
    await _light();
  }

  /// Warning / failed action.
  static Future<void> warning() => _heavy();
}
