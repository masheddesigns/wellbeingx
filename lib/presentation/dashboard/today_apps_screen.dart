import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/haptics.dart';
import '../../core/utils/duration_format.dart';
import '../../domain/models/daily_stats.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/skeleton.dart';
import 'dashboard_state.dart';

/// Full per-app breakdown of today's screen time — reached by tapping the
/// dashboard's screen-time ring. Shows every app by name, not just the top few.
class TodayAppsScreen extends ConsumerWidget {
  const TodayAppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s apps')),
      body: snap.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          children: const <Widget>[
            SkeletonCard(height: 80),
            SizedBox(height: 12),
            SkeletonCard(height: 80),
            SizedBox(height: 12),
            SkeletonCard(height: 80),
          ],
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) => _Body(today: s.today),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.today});
  final DailyStats today;

  @override
  Widget build(BuildContext context) {
    final apps = today.apps.toList()
      ..sort((a, b) => b.foreground.compareTo(a.foreground));

    if (apps.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No app usage tracked yet today.',
            style: TextStyle(color: WxColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final maxFg = apps.first.foreground.inSeconds;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      children: <Widget>[
        Text(
          '${today.screenTime.formatHm()} on screen today across '
          '${apps.length} ${apps.length == 1 ? 'app' : 'apps'}.',
          style: const TextStyle(
            fontSize: 14,
            color: WxColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final a in apps) ...<Widget>[
                _AppRow(
                  app: a,
                  scale: maxFg == 0 ? 0 : a.foreground.inSeconds / maxFg,
                ),
                if (a != apps.last) const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
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
          '/app/${Uri.encodeComponent(app.packageName)}'
          '?name=${Uri.encodeComponent(app.displayName)}'
          '&cat=${app.category.code}',
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  app.displayName.isEmpty ? '?' : app.displayName[0],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  app.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: WxColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                app.foreground.formatHm(),
                style: WxTypography.mono(
                  size: 14,
                  weight: FontWeight.w700,
                  color: WxColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 5,
              child: Stack(
                children: <Widget>[
                  Container(color: WxColors.surface2),
                  FractionallySizedBox(
                    widthFactor: scale.clamp(0.0, 1.0),
                    child: Container(color: color),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${app.opens} ${app.opens == 1 ? 'open' : 'opens'} · '
            '${app.category.label}',
            style: const TextStyle(fontSize: 11.5, color: WxColors.textMuted),
          ),
        ],
      ),
    );
  }
}
