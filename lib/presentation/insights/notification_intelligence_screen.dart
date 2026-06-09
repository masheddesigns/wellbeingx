import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/notification_intelligence.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';

final _notifIntelProvider = FutureProvider<NotificationReport>((ref) async {
  final usage = ref.watch(usageRepositoryProvider);
  ref.watch(notificationRevisionProvider);
  final last7 = await usage.rangeStats(7);
  return const NotificationIntelligence().analyze(
    today: last7.last,
    last7Days: last7,
  );
});

class NotificationIntelligenceScreen extends ConsumerWidget {
  const NotificationIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(_notifIntelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notification intelligence')),
      body: view.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (r) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          children: <Widget>[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'PRESSURE SCORE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: WxColors.textMuted,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${r.pressureScore}',
                        style: WxTypography.mono(
                          size: 56,
                          weight: FontWeight.w800,
                          color: r.pressureScore >= 70
                              ? WxColors.crimson
                              : r.pressureScore >= 40
                              ? WxColors.amber
                              : WxColors.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          '/ 100',
                          style: TextStyle(
                            fontSize: 18,
                            color: WxColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    r.pressureScore >= 70
                        ? 'Notifications are loud. The phone is leading the day.'
                        : r.pressureScore >= 40
                        ? 'Manageable, but trim the loudest sources.'
                        : 'Quiet. Calm signal-to-noise.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: WxColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (r.pressureScore / 100).clamp(0.05, 1.0),
                      minHeight: 6,
                      backgroundColor: WxColors.surface3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        r.pressureScore >= 70
                            ? WxColors.crimson
                            : r.pressureScore >= 40
                            ? WxColors.amber
                            : WxColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'REFOCUS COST',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: WxColors.textMuted,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r.refocusCost.formatHm(),
                          style: WxTypography.mono(
                            size: 22,
                            color: WxColors.cyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'estimated daily',
                          style: TextStyle(
                            fontSize: 11,
                            color: WxColors.textMuted,
                          ),
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
                        const Text(
                          'SPAM SOURCES',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: WxColors.textMuted,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${r.spamApps}',
                          style: WxTypography.mono(
                            size: 22,
                            color: WxColors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'apps with 30+ notifs',
                          style: TextStyle(
                            fontSize: 11,
                            color: WxColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'TOP INTERRUPTERS'),
            if (r.sources.isEmpty)
              const GlassCard(
                child: Text(
                  'No notifications recorded today.',
                  style: TextStyle(color: WxColors.textSecondary),
                ),
              )
            else
              GlassCard(
                child: Column(
                  children: <Widget>[
                    for (final s in r.sources.take(8)) ...<Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: WxColors.category[s.category.code],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  s.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: WxColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  s.category.label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: WxColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${s.count}',
                            style: WxTypography.mono(size: 14),
                          ),
                        ],
                      ),
                      if (s != r.sources.take(8).last)
                        const Divider(height: 16),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
