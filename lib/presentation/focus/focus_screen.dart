import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/focus_repository.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(focusHistoryProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Focus',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pomodoros, deep work, Stay-Away. Your tools to take time back.',
              style: TextStyle(color: WxColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _FocusModeCard(
              title: 'Start a focus block',
              subtitle: 'Pick a preset, tag your intent, ride the ring.',
              accent: WxColors.accent,
              icon: Icons.timer_outlined,
              onTap: () => context.push('/focus-setup'),
            ),
            const SizedBox(height: 12),
            _FocusModeCard(
              title: 'Stay-Away',
              subtitle: 'Block specific apps with soft, hard, or extreme rules.',
              accent: WxColors.crimson,
              icon: Icons.do_not_disturb_on_outlined,
              onTap: () => context.push('/stay-away'),
            ),
            const SizedBox(height: 12),
            _FocusModeCard(
              title: 'Focus analytics',
              subtitle: 'Best days, longest sessions, most productive hours.',
              accent: WxColors.cyan,
              icon: Icons.insights_outlined,
              onTap: () => context.push('/focus-analytics'),
            ),
            const SizedBox(height: 12),
            _FocusModeCard(
              title: 'Mood log',
              subtitle: 'Tag how you feel — see how usage moves with mood.',
              accent: WxColors.violet,
              icon: Icons.mood_outlined,
              onTap: () => context.push('/mood'),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'RECENT SESSIONS'),
            history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e',
                  style: const TextStyle(color: WxColors.crimson)),
              data: (rows) {
                if (rows.isEmpty) {
                  return const GlassCard(
                    child: Text(
                      'No sessions yet. Start a Pomodoro and the chain begins.',
                      style: TextStyle(color: WxColors.textSecondary),
                    ),
                  );
                }
                return Column(
                  children: <Widget>[
                    for (final s in rows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                s.completed
                                    ? Icons.check_circle
                                    : Icons.cancel_outlined,
                                color: s.completed
                                    ? WxColors.accent
                                    : WxColors.textMuted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      DateFormat('EEE d MMM · HH:mm').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            s.startedMs),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: WxColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${s.mode} · ${Duration(milliseconds: s.actualMs).formatHm()} of ${Duration(milliseconds: s.plannedMs).formatHm()}'
                                      '${s.interruptions > 0 ? ' · ${s.interruptions} interruptions' : ''}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: WxColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (s.xpAwarded > 0)
                                Text(
                                  '+${s.xpAwarded}xp',
                                  style: WxTypography.mono(
                                    size: 12,
                                    color: WxColors.accent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusModeCard extends StatelessWidget {
  const _FocusModeCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderColor: accent.withValues(alpha: 0.18),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: WxColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: WxColors.textMuted),
        ],
      ),
    );
  }
}
