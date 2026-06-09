import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../core/services/haptics.dart';
import '../../core/utils/safe_nav.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/behavior_engine.dart';
import '../../domain/engines/recommendation_engine.dart';
import '../../domain/models/recommendation.dart';
import '../shared/widgets/glass_card.dart';

final _recsProvider = FutureProvider<List<Recommendation>>((ref) async {
  final usage = ref.watch(usageRepositoryProvider);
  final last14 = await usage.rangeStats(14);
  final today = last14.last;
  final last7 = last14.sublist(7);
  final prev7 = last14.sublist(0, 7);
  final behavior = const BehaviorEngine().analyze(
    today: today,
    last7Days: last7,
    previous7Days: prev7,
  );
  return const RecommendationEngine().generate(
    today: today,
    last7Days: last7,
    behavior: behavior,
  );
});

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recs = ref.watch(_recsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('What now?')),
      body: recs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'You\'re flying. Nothing to nudge right now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: WxColors.textSecondary),
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            children: <Widget>[
              for (final r in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecCard(rec: r),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RecCard extends StatelessWidget {
  const _RecCard({required this.rec});
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

  IconData get _icon {
    switch (rec.kind) {
      case RecommendationKind.focusSession:
        return Icons.timer_outlined;
      case RecommendationKind.scheduleBlock:
        return Icons.schedule_outlined;
      case RecommendationKind.sleepMode:
        return Icons.bedtime_outlined;
      case RecommendationKind.takeBreak:
        return Icons.pause_circle_outline;
      case RecommendationKind.reduceNotifications:
        return Icons.notifications_off_outlined;
      case RecommendationKind.ghostWeek:
        return Icons.visibility_off_outlined;
      case RecommendationKind.weekendReset:
        return Icons.weekend_outlined;
      case RecommendationKind.morningRitual:
        return Icons.wb_sunny_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: _accent.withValues(alpha: 0.25),
      onTap: rec.route == null
          ? null
          : () {
              Haptics.tap();
              context.wxNavigate(rec.route!);
            },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        rec.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: WxColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        rec.priority.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  rec.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: WxColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (rec.cta != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Text(
                        rec.cta!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: _accent, size: 14),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
