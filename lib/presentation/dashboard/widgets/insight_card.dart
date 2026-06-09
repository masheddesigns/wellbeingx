import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../core/utils/safe_nav.dart';
import '../../../domain/models/insight.dart';
import '../../shared/widgets/glass_card.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight});
  final Insight insight;

  Color get _accent {
    switch (insight.severity) {
      case InsightSeverity.positive:
        return WxColors.accent;
      case InsightSeverity.warning:
        return WxColors.amber;
      case InsightSeverity.critical:
        return WxColors.crimson;
      case InsightSeverity.neutral:
        return WxColors.cyan;
    }
  }

  IconData get _icon {
    switch (insight.kind) {
      case InsightKind.unlockCount:
        return Icons.lock_open_rounded;
      case InsightKind.socialMediaTime:
        return Icons.forum_outlined;
      case InsightKind.productivityDrop:
        return Icons.trending_down_rounded;
      case InsightKind.potentialSavings:
        return Icons.savings_outlined;
      case InsightKind.peakDistractionWindow:
        return Icons.access_time_filled_rounded;
      case InsightKind.unusedApps:
        return Icons.archive_outlined;
      case InsightKind.shortUnlockSpiral:
        return Icons.repeat_rounded;
      case InsightKind.sleepMisuse:
        return Icons.bedtime_outlined;
      case InsightKind.notificationFlood:
        return Icons.notifications_active_outlined;
      case InsightKind.streak:
        return Icons.local_fire_department_outlined;
      case InsightKind.focusEfficiency:
        return Icons.bolt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: _accent.withValues(alpha: 0.18),
      onTap: insight.route == null ? null : () => context.wxNavigate(insight.route!),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  insight.headline,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: WxColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insight.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: WxColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (insight.cta != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Text(
                        insight.cta!,
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
