import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/focus_repository.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/behavior_engine.dart';
import '../../domain/engines/composite_scores.dart';
import '../../domain/engines/narrative_engine.dart';
import '../../domain/engines/notification_intelligence.dart';
import '../../domain/engines/personality_classifier.dart';
import '../../domain/models/narrative.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/skeleton.dart';

final _weeklyProvider = FutureProvider((ref) async {
  final usage = ref.watch(usageRepositoryProvider);
  final focus = ref.watch(focusRepositoryProvider);
  final gami = ref.watch(gamificationRepositoryProvider);

  final last14 = await usage.rangeStats(14);
  final last7 = last14.sublist(7);
  final prev7 = last14.sublist(0, 7);
  final today = last7.last;

  final behavior = const BehaviorEngine().analyze(
    today: today,
    last7Days: last7,
    previous7Days: prev7,
  );
  final notif = const NotificationIntelligence().analyze(
    today: today,
    last7Days: last7,
  );
  final scores = const CompositeScoresEngine().compute(
    today: today,
    last7Days: last7,
    previous7Days: prev7,
    behavior: behavior,
    notif: notif,
  );
  final personality = const PersonalityClassifier().classify(last7);
  final weeklyFocus = await focus.totalCompletedThisWeek();
  await gami.read();

  final retro = const NarrativeEngine().weeklyRetrospective(
    last7Days: last7,
    previous7Days: prev7,
    behavior: behavior,
    scores: scores,
    weeklyFocusTime: weeklyFocus,
    personality: personality,
  );
  return retro;
});

class WeeklySummaryScreen extends ConsumerWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(_weeklyProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      appBar: AppBar(
        title: const Text('Weekly retrospective'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Share card',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => context.push('/share-card'),
          ),
        ],
      ),
      body: view.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          children: const <Widget>[
            SkeletonCard(height: 220),
            SizedBox(height: 12),
            SkeletonCard(height: 120),
            SizedBox(height: 12),
            SkeletonCard(height: 200),
          ],
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (retro) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          children: <Widget>[
            FadeRise(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF0F1A18), Color(0xFF050608)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                      color: WxColors.accent.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        if (retro.headline.emoji != null)
                          Text(retro.headline.emoji!,
                              style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        const Text(
                          'YOUR LAST 7 DAYS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: WxColors.accent,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      retro.headline.headline,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: WxColors.textPrimary,
                        height: 1.1,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      retro.headline.body,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: WxColors.textSecondary,
                        height: 1.5,
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
                    child: _StatBlock(
                      label: 'TOTAL TIME',
                      value: retro.totalScreen.formatHm(),
                      caption: '7 days',
                      color: WxColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBlock(
                      label: 'IN FOCUS',
                      value: retro.totalFocus.formatHm(),
                      caption: 'deliberate',
                      color: WxColors.accent,
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
                    child: _StatBlock(
                      label: 'PRODUCTIVITY',
                      value: '${retro.productivityIndex}',
                      suffix: '/100',
                      caption: 'index',
                      color: WxColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBlock(
                      label: 'CONSISTENCY',
                      value: '${retro.focusConsistency}%',
                      caption: 'across days',
                      color: WxColors.violet,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < retro.chapters.length; i++)
              FadeRise(
                delay: Duration(milliseconds: 240 + i * 80),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _Chapter(narrative: retro.chapters[i]),
                ),
              ),
            const SizedBox(height: 12),
            FadeRise(
              delay: Duration(milliseconds: 240 + retro.chapters.length * 80),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'PEAKS & VALLEYS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textMuted,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('STRONGEST',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: WxColors.accent,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.3)),
                              const SizedBox(height: 4),
                              Text(retro.mostProductiveDay,
                                  style: WxTypography.mono(
                                      size: 22, color: WxColors.accent)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('NOISIEST',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: WxColors.crimson,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.3)),
                              const SizedBox(height: 4),
                              Text(retro.mostDistractingDay,
                                  style: WxTypography.mono(
                                      size: 22, color: WxColors.crimson)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FadeRise(
              delay: Duration(milliseconds: 320 + retro.chapters.length * 80),
              child: FilledButton.icon(
                onPressed: () => context.push('/share-card'),
                icon: const Icon(Icons.ios_share_outlined),
                label: const Text('Share this week'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    this.suffix,
    required this.caption,
    required this.color,
  });
  final String label;
  final String value;
  final String? suffix;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: color.withValues(alpha: 0.22),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(value, style: WxTypography.mono(size: 24)),
              if (suffix != null) ...<Widget>[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(suffix!,
                      style: const TextStyle(
                          fontSize: 11, color: WxColors.textMuted)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: const TextStyle(fontSize: 11, color: WxColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _Chapter extends StatelessWidget {
  const _Chapter({required this.narrative});
  final Narrative narrative;

  @override
  Widget build(BuildContext context) {
    final tone = narrative.tone;
    final accent = tone == NarrativeTone.energetic
        ? WxColors.accent
        : tone == NarrativeTone.alert
            ? WxColors.crimson
            : tone == NarrativeTone.reflective
                ? WxColors.cyan
                : WxColors.textPrimary;
    return GlassCard(
      borderColor: accent.withValues(alpha: 0.18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (narrative.emoji != null) ...<Widget>[
            Text(narrative.emoji!, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  narrative.headline,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  narrative.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: WxColors.textSecondary,
                    height: 1.45,
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
