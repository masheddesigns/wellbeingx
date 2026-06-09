import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/services/haptics.dart';
import '../../../core/utils/duration_format.dart';
import '../../../domain/models/daily_stats.dart';
import '../../shared/widgets/glass_card.dart';

class TopAppsCard extends StatelessWidget {
  const TopAppsCard({super.key, required this.apps});
  final List<AppUsage> apps;

  @override
  Widget build(BuildContext context) {
    final top = apps.take(5).toList();
    if (top.isEmpty) {
      return const _EmptyTopApps();
    }
    final maxFg = top.first.foreground.inSeconds;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'TOP APPS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: WxColors.textMuted,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          for (final a in top) ...<Widget>[
            _AppRow(app: a, scale: maxFg == 0 ? 0 : a.foreground.inSeconds / maxFg),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({required this.app, required this.scale});
  final AppUsage app;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final color = WxColors.category[app.category.code] ?? WxColors.accent;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Haptics.cardTap();
        context.push(
          '/app/${Uri.encodeComponent(app.packageName)}?name=${Uri.encodeComponent(app.displayName)}&cat=${app.category.code}',
        );
      },
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                app.displayName.isEmpty ? '?' : app.displayName[0],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    app.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WxColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${app.opens} opens · ${app.category.label}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: WxColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              app.foreground.formatHm(),
              style: WxTypography.mono(size: 14, color: WxColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: scale.clamp(0.05, 1.0),
            minHeight: 4,
            backgroundColor: WxColors.surface3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    ),
    );
  }
}

class _EmptyTopApps extends StatelessWidget {
  const _EmptyTopApps();
  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'TOP APPS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: WxColors.textMuted,
              letterSpacing: 1.6,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'No app usage tracked yet today.',
            style: TextStyle(color: WxColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
