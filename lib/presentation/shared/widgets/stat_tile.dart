import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';

/// Big-number stat with a small label and optional caption.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.caption,
    this.accent = WxColors.accent,
    this.alignment = CrossAxisAlignment.start,
  });

  final String value;
  final String label;
  final String? caption;
  final Color accent;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: WxColors.textMuted,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: WxTypography.mono(size: 30, color: accent),
        ),
        if (caption != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            caption!,
            style: const TextStyle(
              fontSize: 12,
              color: WxColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Inline chip with label/value, used in stat rows.
class InlineStat extends StatelessWidget {
  const InlineStat({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: WxColors.textMuted)),
        const SizedBox(width: 6),
        Text(value,
            style: WxTypography.mono(size: 13, color: WxColors.textPrimary)),
      ],
    );
  }
}
