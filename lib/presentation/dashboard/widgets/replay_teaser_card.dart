import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/services/haptics.dart';
import '../../../domain/models/daily_stats.dart';

/// First-class entry point to the Daily Replay ritual. Shown on the Home tab
/// when the day has enough material to be worth replaying. Tapping pushes the
/// cinematic full-bleed screen.
class ReplayTeaserCard extends StatefulWidget {
  const ReplayTeaserCard({super.key, required this.today});
  final DailyStats today;

  @override
  State<ReplayTeaserCard> createState() => _ReplayTeaserCardState();
}

class _ReplayTeaserCardState extends State<ReplayTeaserCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String get _heroTag {
    final mins = widget.today.screenTime.inMinutes;
    if (mins < 60) return '${mins}m';
    final h = mins ~/ 60;
    final r = mins.remainder(60);
    return r == 0 ? '${h}h' : '${h}h ${r}m';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Haptics.cardTap();
          context.push('/replay');
        },
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) {
            final t = _pulse.value;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    WxColors.surface2.withValues(alpha: 0.95),
                    WxColors.surface1.withValues(alpha: 0.90),
                  ],
                ),
                border: Border.all(
                  color: WxColors.cyan.withValues(alpha: 0.22),
                  width: 0.7,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: WxColors.cyan
                        .withValues(alpha: 0.10 + 0.05 * math.sin(t * 2 * math.pi)),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  _PlayOrb(progress: t),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'YOUR DAY · 60 SECONDS',
                          style: TextStyle(
                            fontSize: 10,
                            color: WxColors.cyan,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Watch the replay',
                          style: WxTypography.mono(
                            size: 22,
                            weight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_heroTag of life so far — chaptered, scored, shareable.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: WxColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: WxColors.textMuted, size: 22),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlayOrb extends StatelessWidget {
  const _PlayOrb({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(
        painter: _OrbPainter(t: progress),
        child: const Center(
          child: Icon(Icons.play_arrow_rounded,
              color: WxColors.void_, size: 28),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({required this.t});
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    final glow = Paint()
      ..color = WxColors.cyan
          .withValues(alpha: 0.4 + 0.2 * math.sin(t * 2 * math.pi))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(c, r - 4, glow);

    final body = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[WxColors.accent, WxColors.cyan],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r - 6, body);

    // Orbiting dot.
    final theta = t * 2 * math.pi;
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(
      Offset(
        c.dx + (r - 2) * math.cos(theta),
        c.dy + (r - 2) * math.sin(theta),
      ),
      2.2,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) => old.t != t;
}
