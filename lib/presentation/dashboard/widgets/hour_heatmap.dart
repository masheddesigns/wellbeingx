import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/duration_format.dart';
import '../../../domain/models/daily_stats.dart';
import '../../shared/widgets/glass_card.dart';

/// 7×24 grid heatmap. Brighter cells = more foreground time.
class HourHeatmap extends StatelessWidget {
  const HourHeatmap({super.key, required this.days});
  final List<DailyStats> days;

  @override
  Widget build(BuildContext context) {
    final maxMs = days
        .expand((d) => d.hourBuckets.values.map((v) => v.inMilliseconds))
        .fold<int>(0, (a, b) => b > a ? b : a);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'HEATMAP — LAST 7 DAYS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textMuted,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Text(
                'peak ${maxMs == 0 ? '—' : Duration(milliseconds: maxMs).formatHm()}',
                style: const TextStyle(fontSize: 11, color: WxColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 24 / 8,
            child: LayoutBuilder(
              builder: (ctx, c) {
                final cols = 24;
                final rows = days.length.clamp(1, 7);
                final gap = 2.0;
                final cellW =
                    (c.maxWidth - gap * (cols - 1)) / cols;
                final cellH =
                    (c.maxHeight - gap * (rows - 1)) / rows;
                return Column(
                  children: <Widget>[
                    for (int r = 0; r < rows; r++)
                      Padding(
                        padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : gap),
                        child: Row(
                          children: <Widget>[
                            for (int h = 0; h < cols; h++) ...<Widget>[
                              _Cell(
                                width: cellW,
                                height: cellH,
                                value: days[r].hourBuckets[h]?.inMilliseconds ?? 0,
                                max: maxMs,
                              ),
                              if (h != cols - 1) SizedBox(width: gap),
                            ],
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              for (int i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    WxDates.hourLabel(i * 6),
                    style: const TextStyle(
                      fontSize: 10,
                      color: WxColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.width,
    required this.height,
    required this.value,
    required this.max,
  });
  final double width;
  final double height;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    final t = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    final color = Color.lerp(
      WxColors.surface3.withValues(alpha: 0.4),
      WxColors.accent,
      t,
    )!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
