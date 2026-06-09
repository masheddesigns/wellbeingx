import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/services/haptics.dart';
import '../../../core/utils/duration_format.dart';
import '../../../domain/models/daily_stats.dart';

/// "Time Recovery" — a deliberately punchy, addictive card that reframes
/// today's distraction time as a yearly opportunity cost in human units.
class RecoveryCard extends StatelessWidget {
  const RecoveryCard({super.key, required this.last7Days});
  final List<DailyStats> last7Days;

  @override
  Widget build(BuildContext context) {
    if (last7Days.isEmpty) return const SizedBox.shrink();

    final weekDistract = last7Days.fold<Duration>(
      Duration.zero,
      (a, d) => a + d.distractionTime,
    );
    final dailyAvg = Duration(
      microseconds: weekDistract.inMicroseconds ~/ last7Days.length,
    );
    if (dailyAvg.inMinutes < 15) {
      // Don't surface the card at all when there's little to recover.
      return const SizedBox.shrink();
    }

    // If they cut their distraction time in half:
    final cutDailyMin = (dailyAvg.inMinutes * 0.5).round();
    final yearSaved = Duration(minutes: cutDailyMin * 365);
    final books = (yearSaved.inHours / 8).floor();
    final movies = (yearSaved.inHours / 2).floor();
    final workouts = (yearSaved.inMinutes / 30).floor();

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF1A1610),
            Color(0xFF080706),
          ],
        ),
        border: Border.all(color: WxColors.amber.withValues(alpha: 0.3)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: WxColors.amber.withValues(alpha: 0.06),
            blurRadius: 32,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'TIME RECOVERY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: WxColors.amber,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              const Icon(Icons.auto_awesome,
                  color: WxColors.amber, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 18,
                color: WxColors.textPrimary,
                height: 1.35,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              children: <InlineSpan>[
                const TextSpan(text: 'If you cut distractions by half,\nyou\'d reclaim '),
                TextSpan(
                  text: yearSaved.formatHm(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: WxColors.amber,
                  ),
                ),
                const TextSpan(text: ' a year.'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              Expanded(
                child: _Unit(label: 'BOOKS', value: '$books', emoji: '📚'),
              ),
              Expanded(
                child: _Unit(label: 'MOVIES', value: '$movies', emoji: '🎬'),
              ),
              Expanded(
                child:
                    _Unit(label: 'WORKOUTS', value: '$workouts', emoji: '🏋️'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Haptics.cardTap();
              context.push('/simulator');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: const <Widget>[
                  Text(
                    'Run the numbers on any app',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: WxColors.amber,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward,
                      color: WxColors.amber, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Unit extends StatelessWidget {
  const _Unit({required this.label, required this.value, required this.emoji});
  final String label;
  final String value;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        Text(value, style: WxTypography.mono(size: 22, color: WxColors.amber)),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: WxColors.textMuted,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}
