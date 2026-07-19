import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../core/services/haptics.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/services/permission_service.dart';
import '../../data/repositories/daily_rewards.dart';
import '../../domain/models/daily_stats.dart';
import '../shared/widgets/glass_card.dart';
import 'dashboard_state.dart';
import 'widgets/animated_hero.dart';
import 'widgets/narrative_opener.dart';
import 'widgets/recovery_card.dart';
import 'widgets/replay_teaser_card.dart';
import 'widgets/streak_strip.dart';
import 'widgets/time_went_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Permission refresh + first ingest happen at the shell level (see
    // [_AppShellState]) and app boot. Keep this screen's first frame focused on
    // rendering; background ingest is triggered elsewhere.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(permissionsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final perms = ref.watch(permissionsProvider);
    final install = ref.watch(installControllerProvider);
    final dash = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: WxColors.void_,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            Haptics.pullRefresh();
            ref.invalidate(dashboardProvider);
            await runBackgroundIngest(ref, force: true);
          },
          color: WxColors.accent,
          backgroundColor: WxColors.surface1,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              _GreetingHeader(
                streak: dash.asData?.value.gami.currentStreak ?? 0,
              ),
              const SizedBox(height: 16),
              if (!perms.usageAccess) const _UsageAccessNudge(),
              if (install.ghostMode &&
                  install.ghostUntil != null &&
                  install.ghostUntil!.isAfter(DateTime.now()))
                const _GhostBadge(),
              if (ref.watch(ingestingProvider)) const _IngestBadge(),
              dash.when(
                loading: () => const _LoadingSkeleton(),
                error: (e, _) => _ErrorState(message: e.toString()),
                data: (snap) => _DashboardBody(snap: snap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader({required this.streak});
  final int streak;

  String _agoLabel(int lastMs) {
    if (lastMs == 0) return 'never';
    final secs = (DateTime.now().millisecondsSinceEpoch - lastMs) ~/ 1000;
    if (secs < 60) return 'just now';
    if (secs < 3600) return '${secs ~/ 60}m ago';
    if (secs < 86400) return '${secs ~/ 3600}h ago';
    return '${secs ~/ 86400}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    final greeting = hour < 5
        ? 'Late night.'
        : hour < 12
        ? 'Good morning.'
        : hour < 17
        ? 'Good afternoon.'
        : hour < 22
        ? 'Good evening.'
        : 'Wind down.';
    final lastIngest = ref.watch(lastIngestProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streak > 0
                      ? 'Day $streak of staying intentional · synced ${_agoLabel(lastIngest)}'
                      : 'Make today the first day · synced ${_agoLabel(lastIngest)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: WxColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              Haptics.tap();
              runBackgroundIngest(ref, force: true);
            },
            icon: const Icon(Icons.refresh),
            color: WxColors.textMuted,
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
            color: WxColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _UsageAccessNudge extends ConsumerWidget {
  const _UsageAccessNudge();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        borderColor: WxColors.amber.withValues(alpha: 0.3),
        onTap: () => context.push('/permissions'),
        child: Row(
          children: <Widget>[
            const Icon(Icons.shield_outlined, color: WxColors.amber, size: 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Usage access required',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: WxColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Tap to grant — without it your stats stay empty.',
                    style: TextStyle(
                      fontSize: 12,
                      color: WxColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: WxColors.amber, size: 16),
          ],
        ),
      ),
    );
  }
}

class _IngestBadge extends StatelessWidget {
  const _IngestBadge();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        borderColor: WxColors.cyan.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: const <Widget>[
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: WxColors.cyan,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Reading your phone usage…',
                style: TextStyle(fontSize: 13, color: WxColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostBadge extends StatelessWidget {
  const _GhostBadge();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        borderColor: WxColors.violet.withValues(alpha: 0.4),
        child: Row(
          children: const <Widget>[
            Text('👻', style: TextStyle(fontSize: 18)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Ghost Week is on. We're observing silently — your reveal drops at the end.",
                style: TextStyle(fontSize: 13, color: WxColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.snap});
  final DashboardSnapshot snap;

  @override
  Widget build(BuildContext context) {
    final today = snap.today;
    final yesterday = snap.last7Days.length >= 2
        ? snap.last7Days[snap.last7Days.length - 2]
        : DailyStats.empty(today.day.subtract(const Duration(days: 1)));

    // Refined dashboard — emotional spine, generous breathing room, no
    // dashboard-density. Heavy analytics live on the History / Insights tabs.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Haptics.cardTap();
            context.push('/today-apps');
          },
          child: AnimatedHero(
            today: today,
            yesterday: yesterday,
            palette: snap.palette,
          ),
        ),
        const SizedBox(height: 14),
        const _DailyRewardCallout(),
        if (snap.milestones.isNotEmpty) ...<Widget>[
          for (final m in snap.milestones) ...<Widget>[
            const SizedBox(height: 10),
            MilestoneCard(milestone: m),
          ],
        ],
        const SizedBox(height: 18),
        // First-class Daily Replay entry — appears once the day has enough
        // material to make replaying worthwhile. Below 5 minutes the chapter
        // engine falls back to a single empty beat which isn't worth showing.
        if (today.screenTime.inMinutes >= 5) ...<Widget>[
          ReplayTeaserCard(today: today),
          const SizedBox(height: 18),
        ],
        TimeWentCard(today: today),
        const SizedBox(height: 14),
        RecoveryCard(last7Days: snap.last7Days),
        const SizedBox(height: 14),
        // The single most important *action* on the page.
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.timer_outlined),
            label: const Text('Start a focus block'),
            onPressed: () {
              Haptics.cardTap();
              context.push('/focus-setup');
            },
          ),
        ),
        const SizedBox(height: 22),
        // Light secondary row — weekly + share card.
        Row(
          children: <Widget>[
            Expanded(
              child: _ActionTile(
                icon: Icons.auto_stories_outlined,
                label: 'This week',
                onTap: () => context.push('/weekly'),
                accent: WxColors.violet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.ios_share_outlined,
                label: 'Share card',
                onTap: () => context.push('/share-card'),
                accent: WxColors.cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        StreakStrip(gami: snap.gami),
      ],
    );
  }
}

class _DailyRewardCallout extends ConsumerWidget {
  const _DailyRewardCallout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reward = ref.watch(dailyRewardProvider);
    if (reward == null) return const SizedBox.shrink();
    return GlassCard(
      borderColor: WxColors.amber.withValues(alpha: 0.35),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () async {
        Haptics.reward();
        await ref.read(dailyRewardProvider.notifier).claim();
      },
      child: Row(
        children: <Widget>[
          Text(reward.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Day ${reward.dayInStreak}: tap to claim',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: WxColors.amber,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '+${reward.xp} XP · +${reward.coins} coins · ${reward.message}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: WxColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.bolt, color: WxColors.amber, size: 18),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accent,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: WxColors.textPrimary,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward, color: WxColors.textMuted, size: 16),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: WxColors.crimson.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Could not load stats.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: WxColors.crimson,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: WxColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
