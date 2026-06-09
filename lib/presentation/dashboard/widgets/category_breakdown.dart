import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../core/utils/duration_format.dart';
import '../../../domain/models/app_category.dart';
import '../../shared/widgets/glass_card.dart';

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key, required this.byCategory});
  final Map<AppCategory, Duration> byCategory;

  @override
  Widget build(BuildContext context) {
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<Duration>(
      Duration.zero,
      (a, b) => a + b.value,
    );
    if (total.inMinutes == 0) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              'CATEGORIES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: WxColors.textMuted,
                letterSpacing: 1.6,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'No usage yet today.',
              style: TextStyle(color: WxColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'CATEGORIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: WxColors.textMuted,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: <Widget>[
                  for (final e in entries)
                    Expanded(
                      flex: e.value.inSeconds,
                      child: Container(
                        color: WxColors.category[e.key.code],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: WxColors.category[e.key.code],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.key.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: WxColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    e.value.formatHm(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: WxColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${((e.value.inSeconds / total.inSeconds) * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: WxColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
