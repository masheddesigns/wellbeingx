import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../dashboard/dashboard_state.dart';
import '../dashboard/widgets/insight_card.dart';
import '../shared/widgets/glass_card.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: dash.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (snap) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: <Widget>[
              if (snap.unusedAppNames.isNotEmpty) ...<Widget>[
                GlassCard(
                  borderColor: WxColors.violet.withValues(alpha: 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'NEVER USED THIS MONTH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: WxColors.violet,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          for (final n in snap.unusedAppNames.take(20))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: WxColors.violet.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                    color:
                                        WxColors.violet.withValues(alpha: 0.16)),
                              ),
                              child: Text(
                                n,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: WxColors.textPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              for (final i in snap.insights)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InsightCard(insight: i),
                ),
              if (snap.insights.isEmpty)
                const GlassCard(
                  child: Text(
                    'No insights yet — track for a couple of days.',
                    style: TextStyle(color: WxColors.textSecondary),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
