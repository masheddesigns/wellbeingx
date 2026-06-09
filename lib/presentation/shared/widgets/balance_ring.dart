import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/utils/duration_format.dart';

/// Two-arc ring: productive minutes vs distracting minutes. The unfilled
/// remainder represents neutral / utility time. Designed for the dashboard
/// to give a single emotional read of the day.
class BalanceRing extends StatelessWidget {
  const BalanceRing({
    super.key,
    required this.productive,
    required this.distracting,
    required this.total,
    this.size = 140,
  });

  final Duration productive;
  final Duration distracting;
  final Duration total;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pMin = productive.inMinutes;
    final dMin = distracting.inMinutes;
    final tMin = total.inMinutes == 0 ? 1 : total.inMinutes;
    final pFrac = (pMin / tMin).clamp(0.0, 1.0);
    final dFrac = (dMin / tMin).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.expand(
            child: CustomPaint(
              painter: _BalanceRingPainter(
                productive: pFrac,
                distracting: dFrac,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                pMin + dMin == 0
                    ? '—'
                    : '${((pMin / (pMin + dMin)) * 100).round()}%',
                style: WxTypography.mono(
                  size: 22,
                  weight: FontWeight.w700,
                  color: pMin >= dMin ? WxColors.accent : WxColors.crimson,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'PRODUCTIVE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textMuted,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${productive.formatHm()} · ${distracting.formatHm()}',
                style: const TextStyle(
                  fontSize: 9.5,
                  color: WxColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceRingPainter extends CustomPainter {
  _BalanceRingPainter({required this.productive, required this.distracting});
  final double productive;
  final double distracting;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 8;
    final track = Paint()
      ..color = WxColors.surface3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, track);

    final rect = Rect.fromCircle(center: c, radius: r);

    // Productive arc — accent.
    if (productive > 0) {
      final p = Paint()
        ..color = WxColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, productive * 2 * math.pi, false, p);
    }

    // Distracting arc — crimson, anchored at the other side.
    if (distracting > 0) {
      final p = Paint()
        ..color = WxColors.crimson
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, math.pi / 2, distracting * 2 * math.pi, false, p);
    }
  }

  @override
  bool shouldRepaint(covariant _BalanceRingPainter old) =>
      old.productive != productive || old.distracting != distracting;
}
