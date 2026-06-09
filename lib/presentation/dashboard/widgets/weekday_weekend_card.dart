import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/utils/duration_format.dart';
import '../../../domain/engines/behavior_engine.dart';
import '../../shared/widgets/glass_card.dart';

class WeekdayWeekendCard extends StatelessWidget {
  const WeekdayWeekendCard({super.key, required this.split});
  final WeekendSplit split;

  @override
  Widget build(BuildContext context) {
    final wd = split.weekdayDailyAvg.inMinutes.toDouble();
    final we = split.weekendDailyAvg.inMinutes.toDouble();
    final maxV = wd > we ? wd : we;
    if (maxV == 0) {
      return const SizedBox.shrink();
    }
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'WEEKDAY VS WEEKEND',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textMuted,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              if (split.weekendDeltaPct != 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: split.weekendDeltaPct > 0
                        ? WxColors.crimson.withValues(alpha: 0.12)
                        : WxColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${split.weekendDeltaPct > 0 ? '+' : ''}${split.weekendDeltaPct}%',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: split.weekendDeltaPct > 0
                          ? WxColors.crimson
                          : WxColors.accent,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _BarRow(
            label: 'Weekday',
            value: split.weekdayDailyAvg,
            ratio: maxV == 0 ? 0 : wd / maxV,
            color: WxColors.cyan,
          ),
          const SizedBox(height: 10),
          _BarRow(
            label: 'Weekend',
            value: split.weekendDailyAvg,
            ratio: maxV == 0 ? 0 : we / maxV,
            color: WxColors.violet,
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.ratio,
    required this.color,
  });
  final String label;
  final Duration value;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: WxColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value.formatHm(),
              style: WxTypography.mono(size: 13, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.04, 1.0),
            minHeight: 6,
            backgroundColor: WxColors.surface3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
