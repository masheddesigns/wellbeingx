import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/haptics.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/app_intelligence_engine.dart';
import '../../domain/models/app_category.dart';
import '../../domain/models/app_intelligence.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/skeleton.dart';

final appReportProvider = FutureProvider.family<AppIntelligenceReport,
    ({String packageName, String displayName, AppCategory category})>(
  (ref, key) async {
    final repo = ref.watch(usageRepositoryProvider);
    final last14 = await repo.rangeStats(14);
    return const AppIntelligenceEngine().analyze(
      packageName: key.packageName,
      displayName: key.displayName,
      category: key.category,
      last7Days: last14.sublist(7),
      previous7Days: last14.sublist(0, 7),
    );
  },
);

class AppDetailsScreen extends ConsumerWidget {
  const AppDetailsScreen({
    super.key,
    required this.packageName,
    required this.displayName,
    required this.category,
  });

  final String packageName;
  final String displayName;
  final AppCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(appReportProvider((
      packageName: packageName,
      displayName: displayName,
      category: category,
    )));
    return Scaffold(
      backgroundColor: WxColors.void_,
      appBar: AppBar(
        title: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            tooltip: 'Block this app',
            icon: const Icon(Icons.do_not_disturb_on_outlined),
            onPressed: () {
              Haptics.tap();
              context.push('/stay-away');
            },
          ),
        ],
      ),
      body: reportAsync.when(
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
        data: (r) => _Body(report: r),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.report});
  final AppIntelligenceReport report;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      children: <Widget>[
        FadeRise(child: _Hero(report: report)),
        const SizedBox(height: 16),
        FadeRise(
          delay: const Duration(milliseconds: 60),
          child: _RoleCard(report: report),
        ),
        const SizedBox(height: 16),
        FadeRise(
          delay: const Duration(milliseconds: 120),
          child: _ScoreGrid(report: report),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'WHEN YOU USE IT'),
        FadeRise(
          delay: const Duration(milliseconds: 180),
          child: GlassCard(child: _HourlyBars(hourly: report.hourlyMinutes)),
        ),
        if (report.insights.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          const SectionHeader(title: 'INSIGHTS'),
          for (int i = 0; i < report.insights.length; i++) ...<Widget>[
            FadeRise(
              delay: Duration(milliseconds: 240 + i * 60),
              child: _InsightLine(text: report.insights[i]),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.report});
  final AppIntelligenceReport report;

  @override
  Widget build(BuildContext context) {
    final color = WxColors.category[report.category.code] ?? WxColors.accent;
    final delta = report.weekTrendPct;
    final deltaColor = delta == 0
        ? WxColors.textMuted
        : (report.category.isDistracting ? delta > 0 : delta < 0)
            ? WxColors.crimson
            : WxColors.accent;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(WxColors.surface1, color, 0.08)!,
            const Color(0xFF080A0E),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  report.displayName.isEmpty ? '?' : report.displayName[0],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      report.displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      report.category.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                report.totalLast7.formatHm(),
                style: WxTypography.mono(
                    size: 36, weight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'in 7 days',
                  style: TextStyle(
                    fontSize: 12,
                    color: WxColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
              if (report.totalPrev7.inMinutes > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: deltaColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${delta > 0 ? '+' : ''}$delta%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: deltaColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _MicroStat(
                  label: 'Sessions',
                  value: '${report.sessionsLast7}',
                  color: WxColors.cyan),
              const SizedBox(width: 16),
              _MicroStat(
                  label: 'Avg',
                  value: report.avgSession.formatHm(),
                  color: WxColors.violet),
              const SizedBox(width: 16),
              _MicroStat(
                  label: 'Notifs',
                  value: '${report.notificationCount7}',
                  color: WxColors.amber),
            ],
          ),
        ],
      ),
    );
  }
}

class _MicroStat extends StatelessWidget {
  const _MicroStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: WxTypography.mono(size: 16)),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.report});
  final AppIntelligenceReport report;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: WxColors.violet.withValues(alpha: 0.25),
      child: Row(
        children: <Widget>[
          Text(report.role.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'ROLE IN YOUR LIFE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textMuted,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.role.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  report.role.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: WxColors.textSecondary,
                    height: 1.4,
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

class _ScoreGrid extends StatelessWidget {
  const _ScoreGrid({required this.report});
  final AppIntelligenceReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _ScoreTile(
                label: 'DEPENDENCY',
                value: report.dependencyScore,
                color: WxColors.crimson,
                lowerIsBetter: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ScoreTile(
                label: 'INTERRUPTION',
                value: report.interruptionIndex,
                color: WxColors.amber,
                lowerIsBetter: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _ScoreTile(
                label: 'BINGE TENDENCY',
                value: report.bingeTendency,
                color: WxColors.violet,
                lowerIsBetter: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ScoreTile(
                label: 'NIGHT INTENSITY',
                value: report.nightIntensity,
                color: WxColors.cyan,
                lowerIsBetter: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text(
                    'PRODUCTIVITY IMPACT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: WxColors.textMuted,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${report.productivityImpact >= 0 ? '+' : ''}${report.productivityImpact}',
                    style: WxTypography.mono(
                      size: 16,
                      color: report.productivityImpact >= 0
                          ? WxColors.accent
                          : WxColors.crimson,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ImpactBar(value: report.productivityImpact),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.label,
    required this.value,
    required this.color,
    required this.lowerIsBetter,
  });
  final String label;
  final int value;
  final Color color;
  final bool lowerIsBetter;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0, 100);
    return GlassCard(
      borderColor: color.withValues(alpha: 0.22),
      padding: const EdgeInsets.all(14),
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
          Text('$v', style: WxTypography.mono(size: 24)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (v / 100).clamp(0.04, 1.0),
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

class _ImpactBar extends StatelessWidget {
  const _ImpactBar({required this.value});
  final int value;
  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(-100, 100);
    final right = clamped > 0;
    final magnitude = clamped.abs() / 100.0;
    return SizedBox(
      height: 8,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: WxColors.surface3,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 2,
              color: WxColors.textMuted,
            ),
          ),
          FractionallySizedBox(
            alignment: right ? Alignment.centerLeft : Alignment.centerRight,
            widthFactor: 0.5 + (right ? magnitude : -magnitude) * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: right
                      ? <Color>[WxColors.surface3, WxColors.accent]
                      : <Color>[WxColors.crimson, WxColors.surface3],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyBars extends StatelessWidget {
  const _HourlyBars({required this.hourly});
  final List<int> hourly;
  @override
  Widget build(BuildContext context) {
    final maxV = hourly.fold<int>(0, math.max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (int h = 0; h < 24; h++) ...<Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      height: maxV == 0
                          ? 4
                          : ((hourly[h] / maxV) * 80).clamp(4.0, 80.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: <Color>[
                            WxColors.accent.withValues(alpha: 0.3),
                            WxColors.accent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: const <Widget>[
            Text('12am',
                style:
                    TextStyle(fontSize: 9.5, color: WxColors.textMuted)),
            Spacer(),
            Text('6am',
                style:
                    TextStyle(fontSize: 9.5, color: WxColors.textMuted)),
            Spacer(),
            Text('12pm',
                style:
                    TextStyle(fontSize: 9.5, color: WxColors.textMuted)),
            Spacer(),
            Text('6pm',
                style:
                    TextStyle(fontSize: 9.5, color: WxColors.textMuted)),
            Spacer(),
            Text('11pm',
                style:
                    TextStyle(fontSize: 9.5, color: WxColors.textMuted)),
          ],
        ),
      ],
    );
  }
}

class _InsightLine extends StatelessWidget {
  const _InsightLine({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 10),
            child: Icon(Icons.bolt_outlined,
                color: WxColors.accent, size: 14),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: WxColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
