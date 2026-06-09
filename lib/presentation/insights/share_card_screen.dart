import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/haptics.dart';
import '../../core/utils/duration_format.dart';
import '../dashboard/dashboard_state.dart';

/// Beautifully composed exportable card. The user takes a screenshot —
/// we don't need image-rendering plumbing yet, but the layout is
/// "screenshot-ready" 9:16-ish.
class ShareCardScreen extends ConsumerWidget {
  const ShareCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(dashboardProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      appBar: AppBar(
        title: const Text('Share card'),
      ),
      body: dash.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (snap) {
          final week = snap.last7Days.fold<Duration>(
              Duration.zero, (a, d) => a + d.screenTime);
          final focusMins = snap.summary.focusEfficiency * 100;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: _Card(
                        title: 'WELLBEINGX · ${DateTime.now().year}',
                        emoji: snap.personality.emoji,
                        personalityLabel: snap.personality.label,
                        screenTimeWeek: week,
                        productivity: snap.behavior.productivityScore,
                        balance: snap.scores.digitalBalance.value,
                        focusEfficiencyPct: focusMins.round(),
                        streak: snap.gami.currentStreak,
                        level: snap.gami.level,
                        topApp: snap.summary.topApps.isEmpty
                            ? null
                            : snap.summary.topApps.first.displayName,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Haptics.tap();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Take a screenshot to share — image export coming soon.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Screenshot mode'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.emoji,
    required this.personalityLabel,
    required this.screenTimeWeek,
    required this.productivity,
    required this.balance,
    required this.focusEfficiencyPct,
    required this.streak,
    required this.level,
    required this.topApp,
  });
  final String title;
  final String emoji;
  final String personalityLabel;
  final Duration screenTimeWeek;
  final int productivity;
  final int balance;
  final int focusEfficiencyPct;
  final int streak;
  final int level;
  final String? topApp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF12161F),
            Color(0xFF050608),
          ],
        ),
        border: Border.all(color: WxColors.accent.withValues(alpha: 0.25)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: WxColors.accent.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: WxColors.textMuted,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'YOU\'RE A',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: WxColors.textMuted,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            personalityLabel,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: WxColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                screenTimeWeek.formatHm(),
                style: WxTypography.mono(
                  size: 44,
                  weight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Text(
            'on the phone, last 7 days',
            style: TextStyle(
              fontSize: 12,
              color: WxColors.textSecondary,
            ),
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniMetric(
                  label: 'BALANCE',
                  value: '$balance',
                  color: WxColors.accent,
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  label: 'PRODUCTIVITY',
                  value: '$productivity',
                  color: WxColors.cyan,
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  label: 'STREAK',
                  value: '${streak}d',
                  color: WxColors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: WxColors.surface2.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WxColors.hairline),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.bolt_outlined,
                    color: WxColors.accent, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Level $level · WellbeingX',
                  style: const TextStyle(
                    fontSize: 11,
                    color: WxColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (topApp != null)
                  Text(
                    'top: $topApp',
                    style: const TextStyle(
                      fontSize: 11,
                      color: WxColors.textMuted,
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

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: WxTypography.mono(size: 18, color: color)),
      ],
    );
  }
}
