import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/behavior_engine.dart';
import '../../domain/engines/personality_classifier.dart';
import '../../domain/models/daily_stats.dart';
import '../../domain/models/personality_type.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/skeleton.dart';

class _Reveal {
  final Duration totalScreen;
  final Duration distractionTotal;
  final int totalUnlocks;
  final int totalNotifications;
  final List<AppUsage> topApps;
  final BehaviorReport behavior;
  final PersonalityType personality;
  const _Reveal(
    this.totalScreen,
    this.distractionTotal,
    this.totalUnlocks,
    this.totalNotifications,
    this.topApps,
    this.behavior,
    this.personality,
  );
}

final _ghostRevealProvider = FutureProvider<_Reveal>((ref) async {
  final usage = ref.watch(usageRepositoryProvider);
  final last7 = await usage.rangeStats(7);
  final prev7 = await usage.rangeStats(14);
  final previousWeek = prev7.sublist(0, 7);
  Duration screen = Duration.zero;
  Duration distraction = Duration.zero;
  int unlocks = 0;
  int notifs = 0;
  final byApp = <String, AppUsage>{};
  for (final d in last7) {
    screen += d.screenTime;
    distraction += d.distractionTime;
    unlocks += d.unlocks;
    notifs += d.notifications;
    for (final a in d.apps) {
      final existing = byApp[a.packageName];
      byApp[a.packageName] = AppUsage(
        packageName: a.packageName,
        displayName: a.displayName,
        category: a.category,
        foreground: (existing?.foreground ?? Duration.zero) + a.foreground,
        opens: (existing?.opens ?? 0) + a.opens,
        notifications: (existing?.notifications ?? 0) + a.notifications,
      );
    }
  }
  final tops = byApp.values.toList()
    ..sort((a, b) => b.foreground.compareTo(a.foreground));
  final behavior = const BehaviorEngine().analyze(
    today: last7.last,
    last7Days: last7,
    previous7Days: previousWeek,
  );
  return _Reveal(
    screen,
    distraction,
    unlocks,
    notifs,
    tops.take(5).toList(),
    behavior,
    const PersonalityClassifier().classify(last7),
  );
});

class GhostRevealScreen extends ConsumerWidget {
  const GhostRevealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reveal = ref.watch(_ghostRevealProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      appBar: AppBar(
        title: const Text('Ghost Week'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await ref.read(installControllerProvider.notifier).endGhostWeek();
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: reveal.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => Center(child: Text('$e')),
        data: (r) => _Body(reveal: r),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      children: const <Widget>[
        SkeletonCard(height: 220),
        SizedBox(height: 12),
        SkeletonCard(height: 120),
        SizedBox(height: 12),
        SkeletonCard(height: 200),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.reveal});
  final _Reveal reveal;

  @override
  Widget build(BuildContext context) {
    final lifeLost = reveal.totalScreen;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      children: <Widget>[
        FadeRise(
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF1A0F26), Color(0xFF050608)],
              ),
              border: Border.all(
                  color: WxColors.violet.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Text('👻', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 10),
                    Text(
                      'YOUR HIDDEN WEEK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WxColors.violet,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  lifeLost.formatHm(),
                  style: WxTypography.mono(
                      size: 64, weight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'spent on your phone over 7 silent days.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: WxColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeRise(
          delay: const Duration(milliseconds: 80),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _ShockTile(
                  label: 'UNLOCKS',
                  value: '${reveal.totalUnlocks}',
                  subtitle:
                      '${(reveal.totalUnlocks / 7).round()}/day average',
                  accent: WxColors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShockTile(
                  label: 'NOTIFICATIONS',
                  value: '${reveal.totalNotifications}',
                  subtitle:
                      '${(reveal.totalNotifications / 7).round()}/day pinged you',
                  accent: WxColors.cyan,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeRise(
          delay: const Duration(milliseconds: 160),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _ShockTile(
                  label: 'DISTRACTION',
                  value: reveal.distractionTotal.formatHm(),
                  subtitle:
                      '${reveal.totalScreen.inMinutes == 0 ? 0 : ((reveal.distractionTotal.inMinutes / reveal.totalScreen.inMinutes) * 100).round()}% of screen time',
                  accent: WxColors.crimson,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShockTile(
                  label: 'OVERLOAD',
                  value: '${reveal.behavior.cognitiveOverloadScore}',
                  subtitle: 'cognitive load (avg)',
                  accent: WxColors.violet,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FadeRise(
          delay: const Duration(milliseconds: 240),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'YOU\'RE A',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textMuted,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Text(
                      reveal.personality.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            reveal.personality.label,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: WxColors.textPrimary,
                            ),
                          ),
                          Text(
                            reveal.personality.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: WxColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeRise(
          delay: const Duration(milliseconds: 320),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'WHO STOLE THE TIME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textMuted,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                for (final a in reveal.topApps)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: WxColors.category[a.category.code],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            a.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: WxColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          a.foreground.formatHm(),
                          style: WxTypography.mono(size: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FadeRise(
          delay: const Duration(milliseconds: 420),
          child: Center(
            child: Column(
              children: <Widget>[
                const Text(
                  '7 days. No filter. Real you.',
                  style: TextStyle(
                    fontSize: 14,
                    color: WxColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  child: const Text('I see myself'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ShockTile extends StatelessWidget {
  const _ShockTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accent,
  });
  final String label;
  final String value;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: accent.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: WxTypography.mono(size: 24)),
          const SizedBox(height: 4),
          Text(
            subtitle,
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
