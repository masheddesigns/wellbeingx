import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/focus_repository.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../domain/models/gamification.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';

final _focusWeekProvider = FutureProvider<Duration>((ref) async {
  return ref.watch(focusRepositoryProvider).totalCompletedThisWeek();
});

final _focusCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(focusRepositoryProvider).countCompleted();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gami = ref.watch(gamificationStateProvider);
    final focusWeek = ref.watch(_focusWeekProvider);
    final focusCount = ref.watch(_focusCountProvider);

    return Scaffold(
      backgroundColor: WxColors.void_,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: <Widget>[
            const Text(
              'You',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: WxColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            gami.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (g) => _ProfileHero(state: g),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('FOCUS THIS WEEK',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: WxColors.textMuted,
                              letterSpacing: 1.4,
                            )),
                        const SizedBox(height: 8),
                        Text(
                          (focusWeek.asData?.value ?? Duration.zero).formatHm(),
                          style: WxTypography.mono(size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('SESSIONS DONE',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: WxColors.textMuted,
                              letterSpacing: 1.4,
                            )),
                        const SizedBox(height: 8),
                        Text(
                          '${focusCount.asData?.value ?? 0}',
                          style: WxTypography.mono(size: 22, color: WxColors.cyan),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            gami.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (g) => _LeagueCard(state: g),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'GROW THE FOCUS PET'),
            const _FocusPetCard(),
            const SizedBox(height: 16),
            const SectionHeader(title: 'YOUR JOURNEY'),
            GlassCard(
              onTap: () => context.push('/achievements'),
              child: Row(
                children: const <Widget>[
                  Icon(Icons.emoji_events_outlined, color: WxColors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Achievements',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WxColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: WxColors.textMuted, size: 14),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              onTap: () => context.push('/personality'),
              child: Row(
                children: const <Widget>[
                  Icon(Icons.psychology_outlined, color: WxColors.violet),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Digital personality',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WxColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: WxColors.textMuted, size: 14),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              onTap: () => context.push('/insights'),
              child: Row(
                children: const <Widget>[
                  Icon(Icons.auto_awesome_outlined, color: WxColors.accent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All insights',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WxColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: WxColors.textMuted, size: 14),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              onTap: () => context.push('/settings'),
              child: Row(
                children: const <Widget>[
                  Icon(Icons.settings_outlined, color: WxColors.textPrimary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WxColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: WxColors.textMuted, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.state});
  final GamificationState state;

  @override
  Widget build(BuildContext context) {
    final (progress, next) = state.levelProgress;
    final pct = next == 0 ? 0 : progress / next;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF13241F),
            Color(0xFF0B0E14),
          ],
        ),
        border: Border.all(color: WxColors.accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'LEVEL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textMuted,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.level}',
                style: WxTypography.mono(size: 48, color: WxColors.accent),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text('🔥', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text('${state.currentStreak}',
                          style: WxTypography.mono(size: 22, color: WxColors.amber)),
                    ],
                  ),
                  const Text(
                    'day streak',
                    style: TextStyle(fontSize: 11, color: WxColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct.clamp(0.05, 1.0).toDouble(),
              backgroundColor: WxColors.surface3,
              minHeight: 8,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(WxColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$progress / $next XP to level ${state.level + 1}',
            style: const TextStyle(fontSize: 12, color: WxColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              _InlineStat(label: 'XP', value: '${state.xp}'),
              const SizedBox(width: 24),
              _InlineStat(label: 'Coins', value: '${state.coins}'),
              const SizedBox(width: 24),
              _InlineStat(label: 'Best', value: '${state.longestStreak}d'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: WxColors.textMuted,
              letterSpacing: 1.4,
            )),
        const SizedBox(height: 4),
        Text(value, style: WxTypography.mono(size: 18)),
      ],
    );
  }
}

class _LeagueCard extends StatelessWidget {
  const _LeagueCard({required this.state});
  final GamificationState state;

  @override
  Widget build(BuildContext context) {
    final league = FocusLeague.fromXp(state.xp);
    final next = league.next;
    final progress = next == null
        ? 1.0
        : ((state.xp - league.xpRequired) /
                (next.xpRequired - league.xpRequired))
            .clamp(0.0, 1.0);
    return GlassCard(
      borderColor: WxColors.violet.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(league.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${league.label} League',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      league.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: WxColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.04, 1.0),
              minHeight: 6,
              backgroundColor: WxColors.surface3,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(WxColors.violet),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            next == null
                ? 'Top league reached.'
                : '${next.xpRequired - state.xp} XP to ${next.label}',
            style: const TextStyle(
              fontSize: 11,
              color: WxColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusPetCard extends ConsumerWidget {
  const _FocusPetCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(_focusWeekProvider);
    final mins = (week.asData?.value ?? Duration.zero).inMinutes;
    final stage = mins >= 600
        ? _PetStage('🦋', 'Butterfly')
        : mins >= 300
            ? _PetStage('🐦', 'Wakeful Bird')
            : mins >= 120
                ? _PetStage('🐣', 'Hatchling')
                : mins >= 30
                    ? _PetStage('🥚', 'Egg')
                    : _PetStage('🌱', 'Seedling');
    final next = mins < 30
        ? 30
        : mins < 120
            ? 120
            : mins < 300
                ? 300
                : mins < 600
                    ? 600
                    : 600;
    final pct = next == 0 ? 0.0 : (mins / next).clamp(0.0, 1.0);
    return GlassCard(
      child: Row(
        children: <Widget>[
          Text(stage.emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  stage.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mins == 0
                      ? 'Start a focus session to plant the seed.'
                      : 'Grows with each focus session.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: WxColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: WxColors.surface3,
                    minHeight: 4,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(WxColors.accentDeep),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$mins / $next focus minutes this week',
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

class _PetStage {
  final String emoji;
  final String label;
  _PetStage(this.emoji, this.label);
}
