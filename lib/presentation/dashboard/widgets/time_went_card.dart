import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/services/haptics.dart';
import '../../../core/utils/duration_format.dart';
import '../../../domain/models/daily_stats.dart';
import '../../shared/widgets/glass_card.dart';

/// Visually strong "where your time went" — a single glance: the worst
/// distractor, the productive winner, the categories painted as a flowing bar.
/// Replaces the old top-apps + categories + behavior cards (3 cards → 1).
class TimeWentCard extends StatefulWidget {
  const TimeWentCard({super.key, required this.today});
  final DailyStats today;

  @override
  State<TimeWentCard> createState() => _TimeWentCardState();
}

class _TimeWentCardState extends State<TimeWentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _grow;

  @override
  void initState() {
    super.initState();
    _grow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant TimeWentCard old) {
    super.didUpdateWidget(old);
    if (old.today.screenTime != widget.today.screenTime) {
      _grow.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = widget.today;
    if (today.screenTime.inMinutes == 0) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              'WHERE YOUR TIME WENT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: WxColors.textMuted,
                letterSpacing: 1.6,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'No usage tracked yet today.',
              style: TextStyle(color: WxColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final entries = today.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = today.screenTime;

    final apps = today.apps.toList()
      ..sort((a, b) => b.foreground.compareTo(a.foreground));
    final worstDistraction = apps.firstWhere(
      (a) => a.category.isDistracting,
      orElse: () => apps.first,
    );

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'WHERE YOUR TIME WENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: WxColors.textMuted,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // Single emotional headline about the dominant distractor.
          if (worstDistraction.category.isDistracting &&
              worstDistraction.foreground.inMinutes >= 10)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 18,
                    color: WxColors.textPrimary,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: worstDistraction.foreground.formatHm(),
                      style: TextStyle(
                        color: WxColors.category[worstDistraction.category.code],
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(text: ' disappeared into '),
                    TextSpan(
                      text: worstDistraction.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),

          // The flowing gradient bar — animated grow on first paint.
          AnimatedBuilder(
            animation: _grow,
            builder: (_, __) {
              final t = Curves.easeOutCubic.transform(_grow.value);
              return SizedBox(
                height: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: <Widget>[
                      for (final e in entries)
                        Expanded(
                          flex: ((e.value.inSeconds * t).round())
                              .clamp(1, 1 << 30),
                          child: Container(
                            color: WxColors.category[e.key.code] ??
                                WxColors.accent,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Top 3 categories as legend rows with their share.
          for (final e in entries.take(3))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
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
                  SizedBox(
                    width: 38,
                    child: Text(
                      '${((e.value.inSeconds / total.inSeconds) * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: WxTypography.mono(
                        size: 12,
                        color: WxColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),
          // Subtle CTA.
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Haptics.cardTap();
              context.push('/history');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: const <Widget>[
                  Text(
                    'See full history',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: WxColors.accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward,
                      color: WxColors.accent, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
