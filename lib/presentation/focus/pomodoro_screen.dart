import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/duration_format.dart';
import 'focus_controller.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(focusControllerProvider);
    final c = ref.read(focusControllerProvider.notifier);

    return Scaffold(
      backgroundColor: WxColors.void_,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (s.running) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('End session?'),
                  content: const Text(
                      'You have time remaining. End now and lose the streak credit?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Keep going'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        c.abandon();
                        if (context.canPop()) context.pop();
                      },
                      child: const Text('End session'),
                    ),
                  ],
                ),
              );
            } else {
              context.pop();
            }
          },
        ),
        title: Text(_phaseLabel(s.phase)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: WxColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${s.completedPomodoros} POMODORO${s.completedPomodoros == 1 ? '' : 'S'} TODAY',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.accent,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox.expand(
                      child: CustomPaint(
                        painter: _RingPainter(progress: s.progress),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          s.remaining.formatMs(),
                          style: WxTypography.mono(
                            size: 62,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'PLANNED ${s.planned.inMinutes} MIN',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: WxColors.textMuted,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!s.running) ...<Widget>[
                _DurationPicker(
                  current: s.planned,
                  onChange: c.setPlanned,
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: <Widget>[
                  if (s.running)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        onPressed: () => c.pause(),
                      ),
                    )
                  else
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(s.phase == FocusPhase.idle
                            ? 'Start focus'
                            : s.phase == FocusPhase.work
                                ? 'Resume'
                                : 'Start break'),
                        onPressed: () => c.start(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (s.phase != FocusPhase.idle)
                TextButton(
                  onPressed: c.abandon,
                  child: const Text('End and reset'),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _phaseLabel(FocusPhase p) {
    switch (p) {
      case FocusPhase.work:
        return 'Focus';
      case FocusPhase.shortBreak:
        return 'Short break';
      case FocusPhase.longBreak:
        return 'Long break';
      case FocusPhase.done:
        return 'Done';
      case FocusPhase.idle:
        return 'Pomodoro';
    }
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({required this.current, required this.onChange});
  final Duration current;
  final ValueChanged<Duration> onChange;

  static const List<int> _options = <int>[15, 25, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final m in _options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('${m}m'),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: current.inMinutes == m
                      ? WxColors.void_
                      : WxColors.textPrimary,
                ),
                selected: current.inMinutes == m,
                onSelected: (_) => onChange(Duration(minutes: m)),
                selectedColor: WxColors.accent,
                backgroundColor: WxColors.surface2,
                side: const BorderSide(color: WxColors.hairline),
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 14;
    final track = Paint()
      ..color = WxColors.surface3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    canvas.drawCircle(c, radius, track);

    final sweep = Paint()
      ..shader = const SweepGradient(
        colors: <Color>[WxColors.accent, WxColors.cyan, WxColors.accent],
      ).createShader(Rect.fromCircle(center: c, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    final sweepAngle = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      sweep,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
