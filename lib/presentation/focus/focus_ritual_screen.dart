import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/haptics.dart';
import 'focus_controller.dart';

/// 12-second breathing/intent ritual played before the timer starts.
/// 4-7-8 breathing with subtle haptics aligned to phases.
class FocusRitualScreen extends ConsumerStatefulWidget {
  const FocusRitualScreen({super.key});
  @override
  ConsumerState<FocusRitualScreen> createState() => _FocusRitualScreenState();
}

class _FocusRitualScreenState extends ConsumerState<FocusRitualScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breath;
  Timer? _phaseTicker;
  int _phase = 0; // 0=in 1=hold 2=out

  static const _phases = <({String label, int seconds, double scale})>[
    (label: 'Breathe in', seconds: 4, scale: 1.4),
    (label: 'Hold', seconds: 4, scale: 1.4),
    (label: 'Release', seconds: 6, scale: 0.85),
  ];

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: Duration(seconds: _phases[0].seconds),
      lowerBound: 0.85,
      upperBound: _phases[0].scale,
    );
    _breath.forward();
    _scheduleNextPhase();
  }

  void _scheduleNextPhase() {
    _phaseTicker?.cancel();
    _phaseTicker = Timer(
      Duration(seconds: _phases[_phase].seconds),
      () {
        Haptics.light();
        if (!mounted) return;
        setState(() {
          _phase = (_phase + 1) % _phases.length;
        });
        final p = _phases[_phase];
        _breath.duration = Duration(seconds: p.seconds);
        if (_phase == 0) {
          _breath.forward(from: 0.85);
        } else if (_phase == 1) {
          // hold — keep at upper.
        } else {
          _breath.reverse(from: p.scale);
        }
        _scheduleNextPhase();
      },
    );
  }

  @override
  void dispose() {
    _phaseTicker?.cancel();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(focusControllerProvider);
    final phase = _phases[_phase];
    return Scaffold(
      backgroundColor: WxColors.void_,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Haptics.tap();
                  // Navigate first; defer state mutation to next frame so the
                  // navigator's page-list update can't race with a Riverpod
                  // rebuild caused by FocusController.start().
                  context.pushReplacement('/pomodoro');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(focusControllerProvider.notifier).start();
                  });
                },
                child: const Text('Skip'),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _breath,
                    builder: (_, __) => Transform.scale(
                      scale: _breath.value,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: <Color>[
                              Color(0x4D7CF6C2),
                              Color(0x117CF6C2),
                              Color(0x00000000),
                            ],
                            stops: <double>[0.0, 0.6, 1.0],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: WxColors.accent.withValues(
                                alpha: 0.1 + (_breath.value - 0.85) * 0.4,
                              ),
                              border: Border.all(
                                color: WxColors.accent
                                    .withValues(alpha: 0.55),
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    child: Text(
                      phase.label,
                      key: ValueKey<String>(phase.label),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.tag == null
                        ? 'Pick your intent. Then begin.'
                        : 'Locked into "${s.tag}"',
                    style: const TextStyle(
                      fontSize: 13,
                      color: WxColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _DotsRow(active: _phase),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${s.planned.inMinutes}m · ${s.mode.toUpperCase()}'
                      '${s.xpMultiplier > 1 ? ' · ${s.xpMultiplier}× XP' : ''}',
                      style: WxTypography.mono(
                        size: 13,
                        color: WxColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Begin'),
                        onPressed: () {
                          Haptics.success();
                          context.pushReplacement('/pomodoro');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(focusControllerProvider.notifier).start();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsRow extends StatelessWidget {
  const _DotsRow({required this.active});
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < 3; i++)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == active
                  ? WxColors.accent
                  : WxColors.surface3,
            ),
          ),
      ],
    );
  }
}

