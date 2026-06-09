import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../core/services/haptics.dart';
import '../../core/utils/safe_nav.dart';
import '../../domain/models/recommendation.dart';
import '../dashboard/dashboard_state.dart';
import '../dashboard/widgets/composite_scores_strip.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/skeleton.dart';
import '../dashboard/widgets/insight_card.dart';

/// Dedicated Insights hub — pulled out of the dashboard so home stays calm.
/// This is where dense behavioral content lives now.
class InsightsHubScreen extends ConsumerWidget {
  const InsightsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(dashboardProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      body: SafeArea(
        child: dash.when(
          loading: () => ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: const <Widget>[
              SkeletonCard(height: 180),
              SizedBox(height: 14),
              SkeletonCard(height: 140),
              SizedBox(height: 14),
              SkeletonCard(height: 140),
            ],
          ),
          error: (e, _) => Center(child: Text('$e')),
          data: (snap) => _Body(snap: snap),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.snap});
  final DashboardSnapshot snap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Insights',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: WxColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'What\'s actually happening with your attention.',
          style: TextStyle(color: WxColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),

        // Recommendations first — actionable.
        if (snap.recommendations.isNotEmpty) ...<Widget>[
          FadeRise(
            child: const _SectionHeader(
              label: 'WHAT NOW',
              actionLabel: 'See all',
              route: '/recommendations',
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < snap.recommendations.take(3).length; i++) ...<Widget>[
            FadeRise(
              delay: Duration(milliseconds: 80 * (i + 1)),
              child: _RecommendationLine(rec: snap.recommendations[i]),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 14),
        ],

        // Composite scores strip (already designed for this surface).
        FadeRise(
          delay: const Duration(milliseconds: 240),
          child: const _SectionHeader(label: 'YOUR SCORES'),
        ),
        const SizedBox(height: 10),
        FadeRise(
          delay: const Duration(milliseconds: 280),
          child: CompositeScoresStrip(scores: snap.scores),
        ),
        const SizedBox(height: 22),

        // Pattern insights — narrative.
        FadeRise(
          delay: const Duration(milliseconds: 360),
          child: const _SectionHeader(label: 'PATTERNS'),
        ),
        const SizedBox(height: 10),
        if (snap.insights.isEmpty)
          const GlassCard(
            child: Text(
              'No patterns detected yet — track for a couple of days.',
              style: TextStyle(color: WxColors.textSecondary),
            ),
          )
        else
          for (int i = 0; i < snap.insights.take(6).length; i++) ...<Widget>[
            FadeRise(
              delay: Duration(milliseconds: 400 + i * 60),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InsightCard(insight: snap.insights[i]),
              ),
            ),
          ],

        const SizedBox(height: 14),

        // Quiet links to the deeper screens.
        FadeRise(
          delay: const Duration(milliseconds: 600),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                _LinkRow(
                  icon: Icons.psychology_outlined,
                  label: 'Digital personality',
                  route: '/personality',
                  color: WxColors.violet,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: WxColors.divider),
                ),
                _LinkRow(
                  icon: Icons.notifications_active_outlined,
                  label: 'Notification intelligence',
                  route: '/notification-intel',
                  color: WxColors.cyan,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: WxColors.divider),
                ),
                _LinkRow(
                  icon: Icons.science_outlined,
                  label: 'What if?',
                  route: '/simulator',
                  color: WxColors.amber,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: WxColors.divider),
                ),
                _LinkRow(
                  icon: Icons.auto_stories_outlined,
                  label: 'Weekly retrospective',
                  route: '/weekly',
                  color: WxColors.accent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    this.actionLabel,
    this.route,
  });
  final String label;
  final String? actionLabel;
  final String? route;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: WxColors.textMuted,
            letterSpacing: 1.6,
          ),
        ),
        const Spacer(),
        if (actionLabel != null && route != null)
          TextButton(
            onPressed: () {
              Haptics.tap();
              context.push(route!);
            },
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _RecommendationLine extends StatelessWidget {
  const _RecommendationLine({required this.rec});
  final Recommendation rec;

  Color get _accent {
    switch (rec.priority) {
      case RecommendationPriority.urgent:
        return WxColors.crimson;
      case RecommendationPriority.high:
        return WxColors.amber;
      case RecommendationPriority.medium:
        return WxColors.cyan;
      case RecommendationPriority.low:
        return WxColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: _accent.withValues(alpha: 0.22),
      onTap: rec.route == null
          ? null
          : () {
              Haptics.cardTap();
              context.wxNavigate(rec.route!);
            },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  rec.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: WxColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (rec.cta != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Icon(Icons.arrow_forward_ios,
                  color: _accent, size: 12),
            ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Haptics.cardTap();
        context.push(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
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
            const Icon(Icons.arrow_forward_ios,
                size: 12, color: WxColors.textMuted),
          ],
        ),
      ),
    );
  }
}
