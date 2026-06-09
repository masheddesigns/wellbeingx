import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/utils/duration_format.dart';
import '../../../domain/engines/behavior_engine.dart';
import '../../shared/widgets/glass_card.dart';

/// Three-up: productivity score, cognitive overload, focus recovery time.
class BehaviorStrip extends StatelessWidget {
  const BehaviorStrip({super.key, required this.report});
  final BehaviorReport report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _Tile(
            label: 'PRODUCTIVITY',
            value: '${report.productivityScore}',
            suffix: '/100',
            accent: report.productivityScore >= 60
                ? WxColors.accent
                : report.productivityScore >= 40
                    ? WxColors.amber
                    : WxColors.crimson,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Tile(
            label: 'OVERLOAD',
            value: '${report.cognitiveOverloadScore}',
            suffix: '/100',
            accent: report.cognitiveOverloadScore >= 65
                ? WxColors.crimson
                : report.cognitiveOverloadScore >= 35
                    ? WxColors.amber
                    : WxColors.accent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Tile(
            label: 'REFOCUS',
            value: report.focusRecoveryTime.formatHm(),
            accent: WxColors.cyan,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    this.suffix,
    required this.accent,
  });
  final String label;
  final String value;
  final String? suffix;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: accent.withValues(alpha: 0.22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(value, style: WxTypography.mono(size: 22)),
              if (suffix != null) ...<Widget>[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    suffix!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: WxColors.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
