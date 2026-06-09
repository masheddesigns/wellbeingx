import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/services/adaptive_palette.dart';
import '../../../core/utils/duration_format.dart';
import '../../../domain/engines/headline_engine.dart';
import '../../../domain/models/daily_stats.dart';

/// The redesigned hero. The whole homepage rests on this one card.
/// Two visual states fade between each other: the **emotional** state at the
/// top (headline + body) and the **numeric** state (animated minute count
/// counting up from 0 to today's value). A breathing ring traces today's
/// fraction of a 16h "awake budget" so the number feels alive.
class AnimatedHero extends StatefulWidget {
  const AnimatedHero({
    super.key,
    required this.today,
    required this.yesterday,
    required this.palette,
  });

  final DailyStats today;
  final DailyStats yesterday;
  final AdaptivePalette palette;

  @override
  State<AnimatedHero> createState() => _AnimatedHeroState();
}

class _AnimatedHeroState extends State<AnimatedHero>
    with TickerProviderStateMixin {
  late final AnimationController _count;
  late final AnimationController _breath;
  late final AnimationController _tick; // 1s heartbeat
  Timer? _clockTicker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _count = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _tick = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.92,
      upperBound: 1.0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _count.forward();
    });
    _clockTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _tick.forward(from: 0.92);
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedHero old) {
    super.didUpdateWidget(old);
    if (old.today.screenTime != widget.today.screenTime) {
      _count.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _clockTicker?.cancel();
    _count.dispose();
    _breath.dispose();
    _tick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headline = const HeadlineEngine()
        .forToday(today: widget.today, yesterday: widget.yesterday);
    final mood = _moodColor(headline.mood);
    final mins = widget.today.screenTime.inMinutes;
    final budget = 16 * 60; // assumed waking minutes
    final progress = (mins / budget).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(WxColors.surface1, mood, 0.10)!,
            const Color(0xFF050608),
          ],
        ),
        border: Border.all(color: mood.withValues(alpha: 0.18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: mood.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Eyebrow + mood pill, with a per-second live-pulse dot.
          Row(
            children: <Widget>[
              AnimatedBuilder(
                animation: _tick,
                builder: (_, __) {
                  return Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: mood.withValues(alpha: _tick.value),
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: mood.withValues(alpha: 0.4 * _tick.value),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                _eyebrow(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: mood,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _liveClock(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: WxColors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              _Pill(label: _moodLabel(headline.mood), color: mood),
            ],
          ),
          const SizedBox(height: 18),

          // Headline.
          Text(
            headline.headline,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: WxColors.textPrimary,
              height: 1.1,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            headline.body,
            style: const TextStyle(
              fontSize: 14,
              color: WxColors.textSecondary,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 22),

          // Breathing ring + counting number.
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _breath,
                    builder: (_, __) => CustomPaint(
                      size: const Size.square(240),
                      painter: _BreathingRingPainter(
                        progress: progress,
                        breath: _breath.value,
                        accent: mood,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _count,
                    builder: (_, __) {
                      final t = Curves.easeOutCubic.transform(_count.value);
                      final shown = (mins * t).round();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _format(shown),
                            style: WxTypography.mono(
                              size: 56,
                              weight: FontWeight.w800,
                              color: WxColors.textPrimary,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'on screen today',
                            style: TextStyle(
                              fontSize: 11,
                              color: WxColors.textMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Comparison strip (yesterday vs today).
          _Comparison(today: widget.today, yesterday: widget.yesterday),
        ],
      ),
    );
  }

  String _eyebrow() {
    final h = _now.hour;
    if (h < 5) return 'LATE NIGHT';
    if (h < 12) return 'THIS MORNING';
    if (h < 17) return 'THIS AFTERNOON';
    if (h < 22) return 'THIS EVENING';
    return 'TONIGHT';
  }

  String _liveClock() {
    final h = _now.hour == 0
        ? 12
        : (_now.hour > 12 ? _now.hour - 12 : _now.hour);
    final m = _now.minute.toString().padLeft(2, '0');
    final ampm = _now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  String _format(int mins) {
    if (mins < 60) return '${mins}m';
    final h = mins ~/ 60;
    final m = mins.remainder(60);
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _moodLabel(HeadlineMood m) {
    switch (m) {
      case HeadlineMood.focused:
        return 'FOCUSED';
      case HeadlineMood.calm:
        return 'CALM';
      case HeadlineMood.slipping:
        return 'SLIPPING';
      case HeadlineMood.lost:
        return 'OVERLOAD';
      case HeadlineMood.neutral:
        return 'STEADY';
    }
  }

  Color _moodColor(HeadlineMood m) {
    switch (m) {
      case HeadlineMood.focused:
        return WxColors.accent;
      case HeadlineMood.calm:
        return WxColors.cyan;
      case HeadlineMood.slipping:
        return WxColors.amber;
      case HeadlineMood.lost:
        return WxColors.crimson;
      case HeadlineMood.neutral:
        return WxColors.violet;
    }
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.today, required this.yesterday});
  final DailyStats today;
  final DailyStats yesterday;

  @override
  Widget build(BuildContext context) {
    final delta = today.screenTime - yesterday.screenTime;
    final isLighter = delta.isNegative;
    final hasBaseline = yesterday.screenTime.inMinutes > 0;
    final color = !hasBaseline
        ? WxColors.textMuted
        : isLighter
            ? WxColors.accent
            : WxColors.crimson;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: WxColors.surface2.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WxColors.hairline),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            !hasBaseline
                ? Icons.bedtime_outlined
                : isLighter
                    ? Icons.trending_down_rounded
                    : Icons.trending_up_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              !hasBaseline
                  ? 'Building your baseline.'
                  : isLighter
                      ? '${(-delta).formatHm()} less than yesterday'
                      : '${delta.formatHm()} more than yesterday',
              style: TextStyle(
                fontSize: 12.5,
                color: WxColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (hasBaseline)
            Text(
              yesterday.screenTime.formatHm(),
              style: WxTypography.mono(
                size: 12,
                color: WxColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

class _BreathingRingPainter extends CustomPainter {
  _BreathingRingPainter({
    required this.progress,
    required this.breath,
    required this.accent,
  });
  final double progress; // 0..1 of awake budget
  final double breath; // 0..1
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 14;

    // Outer breathing glow.
    final glow = Paint()
      ..color = accent.withValues(alpha: 0.10 + breath * 0.10)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 28 + breath * 12);
    canvas.drawCircle(c, r + 4, glow);

    // Track.
    final track = Paint()
      ..color = WxColors.surface3.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    canvas.drawCircle(c, r, track);

    // Progress arc.
    if (progress > 0) {
      final p = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: <Color>[
            accent.withValues(alpha: 0.4),
            accent,
            accent.withValues(alpha: 0.4),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        progress * 2 * math.pi,
        false,
        p,
      );
    }

    // Tip dot.
    if (progress > 0) {
      final angle = -math.pi / 2 + progress * 2 * math.pi;
      final dot = Offset(
        c.dx + r * math.cos(angle),
        c.dy + r * math.sin(angle),
      );
      final dotPaint = Paint()..color = accent;
      canvas.drawCircle(dot, 5, dotPaint);
      final halo = Paint()
        ..color = accent.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(dot, 8, halo);
    }
  }

  @override
  bool shouldRepaint(covariant _BreathingRingPainter old) =>
      old.progress != progress || old.breath != breath || old.accent != accent;
}
