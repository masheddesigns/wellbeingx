import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/utils/duration_format.dart';
import '../../../domain/models/daily_stats.dart';

class ScreenTimeHero extends StatelessWidget {
  const ScreenTimeHero({
    super.key,
    required this.today,
    required this.previousDay,
  });
  final DailyStats today;
  final DailyStats previousDay;

  @override
  Widget build(BuildContext context) {
    final delta = today.screenTime - previousDay.screenTime;
    final improved = delta.isNegative;
    final caption = previousDay.screenTime.inMinutes == 0
        ? 'No baseline yet — keep tracking.'
        : improved
            ? '${(-delta).formatHm()} less than yesterday'
            : '${delta.formatHm()} more than yesterday';
    final percent = previousDay.screenTime.inMinutes == 0
        ? 0
        : ((delta.inMinutes / math.max(previousDay.screenTime.inMinutes, 1)) *
                100)
            .round();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF12161F),
            Color(0xFF0B0E14),
          ],
        ),
        border: Border.all(color: WxColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textMuted,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: improved
                      ? WxColors.accent.withValues(alpha: 0.12)
                      : WxColors.crimson.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      improved ? Icons.trending_down : Icons.trending_up,
                      size: 12,
                      color: improved ? WxColors.accent : WxColors.crimson,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      previousDay.screenTime.inMinutes == 0
                          ? 'NEW'
                          : '${percent.abs()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: improved ? WxColors.accent : WxColors.crimson,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                today.screenTime.inHours > 0
                    ? '${today.screenTime.inHours}'
                    : '${today.screenTime.inMinutes}',
                style: WxTypography.mono(
                  size: 64,
                  weight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  today.screenTime.inHours > 0 ? 'h' : 'min',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: WxColors.textSecondary,
                  ),
                ),
              ),
              if (today.screenTime.inHours > 0) ...<Widget>[
                const SizedBox(width: 12),
                Text(
                  '${today.screenTime.inMinutes.remainder(60)}',
                  style: WxTypography.mono(size: 40, color: WxColors.textSecondary),
                ),
                const SizedBox(width: 4),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'min',
                    style: TextStyle(
                      fontSize: 14,
                      color: WxColors.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 13,
              color: WxColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              _MetaTile(
                label: 'Unlocks',
                value: '${today.unlocks}',
              ),
              const SizedBox(width: 12),
              _MetaTile(
                label: 'Pickups',
                value: '${today.pickups}',
              ),
              const SizedBox(width: 12),
              _MetaTile(
                label: 'Quick checks',
                value: '${today.shortUnlocks}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: WxColors.surface2.withValues(alpha: 0.55),
          border: Border.all(color: WxColors.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: WxColors.textMuted,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: WxTypography.mono(size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
