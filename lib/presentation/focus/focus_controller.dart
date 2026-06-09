import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/haptics.dart';
import '../../core/services/native_bridge.dart';
import '../../data/repositories/focus_repository.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../domain/models/pomodoro_preset.dart';

enum FocusPhase { idle, work, shortBreak, longBreak, done }

class FocusState {
  final FocusPhase phase;
  final Duration planned;
  final Duration remaining;
  final Duration shortBreakLength;
  final Duration longBreakLength;
  final int completedPomodoros;
  final bool running;
  final int? sessionId;
  final String mode;
  final String? tag;
  final int xpMultiplier;
  final int interruptions;
  final int? lastProductivityScore;

  const FocusState({
    required this.phase,
    required this.planned,
    required this.remaining,
    required this.shortBreakLength,
    required this.longBreakLength,
    required this.completedPomodoros,
    required this.running,
    required this.sessionId,
    required this.mode,
    required this.tag,
    required this.xpMultiplier,
    required this.interruptions,
    required this.lastProductivityScore,
  });

  factory FocusState.idle({PomodoroPreset? preset}) {
    final p = preset ?? kPresets.first;
    return FocusState(
      phase: FocusPhase.idle,
      planned: p.work,
      remaining: p.work,
      shortBreakLength: p.shortBreak,
      longBreakLength: p.longBreak,
      completedPomodoros: 0,
      running: false,
      sessionId: null,
      mode: p.mode,
      tag: null,
      xpMultiplier: p.xpMultiplier,
      interruptions: 0,
      lastProductivityScore: null,
    );
  }

  FocusState copyWith({
    FocusPhase? phase,
    Duration? planned,
    Duration? remaining,
    Duration? shortBreakLength,
    Duration? longBreakLength,
    int? completedPomodoros,
    bool? running,
    int? sessionId,
    bool clearSessionId = false,
    String? mode,
    String? tag,
    bool clearTag = false,
    int? xpMultiplier,
    int? interruptions,
    int? lastProductivityScore,
    bool clearScore = false,
  }) =>
      FocusState(
        phase: phase ?? this.phase,
        planned: planned ?? this.planned,
        remaining: remaining ?? this.remaining,
        shortBreakLength: shortBreakLength ?? this.shortBreakLength,
        longBreakLength: longBreakLength ?? this.longBreakLength,
        completedPomodoros: completedPomodoros ?? this.completedPomodoros,
        running: running ?? this.running,
        sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
        mode: mode ?? this.mode,
        tag: clearTag ? null : (tag ?? this.tag),
        xpMultiplier: xpMultiplier ?? this.xpMultiplier,
        interruptions: interruptions ?? this.interruptions,
        lastProductivityScore:
            clearScore ? null : (lastProductivityScore ?? this.lastProductivityScore),
      );

  double get progress {
    if (planned.inSeconds == 0) return 0;
    return 1 - (remaining.inSeconds / planned.inSeconds).clamp(0, 1);
  }
}

class FocusController extends Notifier<FocusState> {
  Timer? _ticker;

  @override
  FocusState build() {
    ref.onDispose(() => _ticker?.cancel());
    return FocusState.idle();
  }

  FocusRepository get _repo => ref.read(focusRepositoryProvider);
  GamificationRepository get _gami => ref.read(gamificationRepositoryProvider);
  NativeBridgeApi get _native => ref.read(nativeBridgeProvider);

  void selectPreset(PomodoroPreset preset, {String? tag}) {
    if (state.running) return;
    state = FocusState.idle(preset: preset).copyWith(
      tag: tag,
      clearTag: tag == null,
    );
  }

  void setPlanned(Duration d) {
    if (state.running) return;
    state = state.copyWith(planned: d, remaining: d);
  }

  void setTag(String? tag) {
    if (state.running) return;
    state = state.copyWith(tag: tag, clearTag: tag == null);
  }

  Future<void> start() async {
    if (state.running) return;
    Haptics.focusStart();
    final phase = state.phase == FocusPhase.idle ? FocusPhase.work : state.phase;
    final id = phase == FocusPhase.work
        ? await _repo.startSession(
            planned: state.planned,
            mode: state.mode,
            tag: state.tag,
          )
        : null;
    state = state.copyWith(
      phase: phase,
      running: true,
      sessionId: id ?? state.sessionId,
      clearScore: true,
    );
    try {
      await _native.startFocus(
        durationMs: state.planned.inMilliseconds,
        mode: state.mode,
      );
    } catch (_) {}
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!state.running) return;
    final next = state.remaining - const Duration(seconds: 1);
    if (next.inSeconds <= 0) {
      _completePhase();
    } else {
      state = state.copyWith(remaining: next);
    }
  }

  Future<void> pause({bool counted = true}) async {
    if (!state.running) return;
    Haptics.light();
    _ticker?.cancel();
    state = state.copyWith(
      running: false,
      interruptions: counted ? state.interruptions + 1 : state.interruptions,
    );
    try {
      await _native.stopFocus();
    } catch (_) {}
  }

  Future<void> abandon() async {
    _ticker?.cancel();
    final id = state.sessionId;
    if (id != null) {
      final actual = state.planned - state.remaining;
      await _repo.completeSession(
        id,
        actual: actual,
        completed: false,
        interruptions: state.interruptions + 1,
      );
    }
    try {
      await _native.stopFocus();
    } catch (_) {}
    state = FocusState.idle();
  }

  /// Per-session productivity score: 0..100.
  /// Completion: 60pts. Penalize interruptions. Bonus for length & multiplier.
  static int scoreSession({
    required Duration planned,
    required Duration actual,
    required int interruptions,
    required bool completed,
    required int xpMultiplier,
  }) {
    if (!completed) {
      final attemptedRatio = planned.inMinutes == 0
          ? 0.0
          : (actual.inMinutes / planned.inMinutes).clamp(0.0, 1.0);
      return (attemptedRatio * 30).round();
    }
    int score = 60;
    score -= (interruptions * 8).clamp(0, 40);
    if (planned.inMinutes >= 60) score += 15;
    if (planned.inMinutes >= 120) score += 10;
    score += (xpMultiplier - 1) * 5;
    return score.clamp(0, 100);
  }

  Future<void> _completePhase() async {
    _ticker?.cancel();
    if (state.phase == FocusPhase.work) {
      Haptics.focusComplete();
      final id = state.sessionId;
      final score = scoreSession(
        planned: state.planned,
        actual: state.planned,
        interruptions: state.interruptions,
        completed: true,
        xpMultiplier: state.xpMultiplier,
      );
      final xp = ((state.planned.inMinutes * 1.5) * state.xpMultiplier *
              (score / 100.0))
          .round()
          .clamp(5, 1000);
      final coins = ((state.planned.inMinutes / 5) * state.xpMultiplier).round();
      if (id != null) {
        await _repo.completeSession(
          id,
          actual: state.planned,
          completed: true,
          interruptions: state.interruptions,
          xpAwarded: xp,
          coinsAwarded: coins,
          productivityScore: score,
        );
        await _gami.awardXp(xp);
        await _gami.awardCoins(coins);
        await _gami.tickStreak(qualified: true);
        if (await _gami.unlock('first_focus')) {
          Haptics.achievement();
        }
        await _gami.bumpMission('mission_pomodoro');
        if (state.planned.inMinutes >= 120) {
          if (await _gami.unlock('deep_work_2h')) {
            Haptics.achievement();
          }
        }
        if (state.tag != null) {
          await _gami.bumpMission('session_tagger');
        }
        // Hidden: Before Sunrise.
        if (DateTime.now().hour < 7) {
          if (await _gami.unlock('before_sunrise')) {
            Haptics.achievement();
          }
        }
      }
      // Defer to next microtask so we never invalidate while the navigator is
      // mid-frame (the timer tick can land on any frame).
      Future<void>.microtask(() {
        ref.invalidate(focusHistoryProvider);
        ref.invalidate(gamificationStateProvider);
      });
      final completed = state.completedPomodoros + 1;
      final isLong = completed % 4 == 0;
      state = state.copyWith(
        phase: isLong ? FocusPhase.longBreak : FocusPhase.shortBreak,
        running: false,
        completedPomodoros: completed,
        clearSessionId: true,
        planned: isLong ? state.longBreakLength : state.shortBreakLength,
        remaining: isLong ? state.longBreakLength : state.shortBreakLength,
        interruptions: 0,
        lastProductivityScore: score,
      );
    } else if (state.phase == FocusPhase.shortBreak ||
        state.phase == FocusPhase.longBreak) {
      state = state.copyWith(
        phase: FocusPhase.work,
        running: false,
        planned: const Duration(minutes: 25),
        remaining: const Duration(minutes: 25),
      );
    } else {
      state = FocusState.idle();
    }
    try {
      await _native.stopFocus();
    } catch (_) {}
  }
}

final focusControllerProvider =
    NotifierProvider<FocusController, FocusState>(FocusController.new);

@visibleForTesting
class FocusBootstrap {
  FocusBootstrap._();
}
