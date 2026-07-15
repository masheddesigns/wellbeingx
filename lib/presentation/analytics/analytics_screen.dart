import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/analytics_engine.dart';
import '../../domain/engines/behavior_engine.dart';
import '../../domain/engines/notification_intelligence.dart';
import '../../domain/models/daily_stats.dart';
import '../dashboard/dashboard_state.dart';
import '../dashboard/widgets/category_breakdown.dart';
import '../dashboard/widgets/hour_heatmap.dart';
import '../dashboard/widgets/weekday_weekend_card.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/stat_tile.dart';

class _AnalyticsView {
  final List<DailyStats> last14;
  final AnalyticsSummary summary;
  final BehaviorReport behavior;
  final NotificationReport notifReport;
  final Duration lifetime;
  const _AnalyticsView({
    required this.last14,
    required this.summary,
    required this.behavior,
    required this.notifReport,
    required this.lifetime,
  });
}

final _analyticsProvider = FutureProvider<_AnalyticsView>((ref) async {
  final repo = ref.watch(usageRepositoryProvider);
  final last14 = await ref.watch(last14DaysProvider.future);
  final summary = const AnalyticsEngine().summarize(
    currentWeek: last14.sublist(7),
    previousWeek: last14.sublist(0, 7),
  );
  final behavior = const BehaviorEngine().analyze(
    today: last14.last,
    last7Days: last14.sublist(7),
    previous7Days: last14.sublist(0, 7),
  );
  final notif = const NotificationIntelligence().analyze(
    today: last14.last,
    last7Days: last14.sublist(7),
  );
  return _AnalyticsView(
    last14: last14,
    summary: summary,
    behavior: behavior,
    notifReport: notif,
    lifetime: await repo.lifetimeScreenTime(),
  );
});

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(_analyticsProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      body: SafeArea(
        child: RefreshIndicator(
          color: WxColors.accent,
          backgroundColor: WxColors.surface1,
          onRefresh: () async => ref.invalidate(_analyticsProvider),
          child: view.when(
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const <Widget>[
                SizedBox(height: 200),
                Center(child: CircularProgressIndicator()),
              ],
            ),
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                const SizedBox(height: 80),
                Center(child: Text('$e')),
              ],
            ),
            data: (v) => _Body(view: v),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.view});
  final _AnalyticsView view;

  @override
  Widget build(BuildContext context) {
    final s = view.summary;
    final b = view.behavior;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Text(
            'Stats',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: WxColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // ----- This week vs last -----
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'THIS WEEK',
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
                    child: StatTile(
                      label: 'Total',
                      value: s.weekTotal.formatHm(),
                      caption: '${s.weekDailyAvg.formatHm()} / day',
                    ),
                  ),
                  Expanded(
                    child: StatTile(
                      label: 'vs last week',
                      value: s.prevWeekTotal.inMinutes == 0
                          ? '—'
                          : '${s.growthPct >= 0 ? '+' : ''}${s.growthPct}%',
                      accent: s.growthPct <= 0
                          ? WxColors.accent
                          : WxColors.crimson,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatTile(
                      label: 'Lifetime',
                      value: view.lifetime.formatHm(),
                      caption: 'since install',
                      accent: WxColors.cyan,
                    ),
                  ),
                  Expanded(
                    child: StatTile(
                      label: 'Could save',
                      value: s.projectedSavings.formatHm(),
                      caption: 'this week',
                      accent: WxColors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ----- Screen time 14 days -----
        const SectionHeader(title: 'SCREEN TIME — 14 DAYS'),
        GlassCard(child: _ScreenTimeBars(days: view.last14)),
        const SizedBox(height: 16),

        // ----- Productivity & cognitive overload trend -----
        const SectionHeader(title: 'PRODUCTIVITY VS OVERLOAD'),
        GlassCard(
          child: _DualLineChart(
            days: view.last14.sublist(7),
            seriesA: const _Series('Productivity', WxColors.accent),
            seriesB: const _Series('Overload', WxColors.crimson),
            valueA: (d) => _BehaviorEngineProxy.productivity(d).toDouble(),
            valueB: (d) =>
                _BehaviorEngineProxy.overload(d, view.last14).toDouble(),
            yMax: 100,
          ),
        ),
        const SizedBox(height: 16),

        // ----- Unlocks trend -----
        const SectionHeader(title: 'UNLOCK TREND'),
        GlassCard(
          child: _UnlocksLine(days: view.last14),
        ),
        const SizedBox(height: 16),

        // ----- Categories week -----
        const SectionHeader(title: 'CATEGORIES — WEEK'),
        CategoryBreakdown(byCategory: s.weekByCategory),
        const SizedBox(height: 16),

        // ----- Weekday vs weekend -----
        WeekdayWeekendCard(split: b.weekendSplit),
        const SizedBox(height: 16),

        // ----- Day-of-week pattern -----
        const SectionHeader(title: 'YOUR WEEK SHAPE'),
        GlassCard(child: _DayOfWeekBars(days: view.last14)),
        const SizedBox(height: 16),

        // ----- Top apps week + growth -----
        const SectionHeader(title: 'APP MOVEMENT'),
        GlassCard(child: _AppMovement(view: view)),
        const SizedBox(height: 16),

        // ----- Heatmap -----
        const SectionHeader(title: 'HEATMAP — 7 DAYS'),
        HourHeatmap(days: view.last14.sublist(7)),
        const SizedBox(height: 16),

        // ----- Notification pressure -----
        const SectionHeader(title: 'NOTIFICATIONS'),
        GlassCard(
          onTap: () => context.push('/notification-intel'),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: WxColors.cyan.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.notifications_active_outlined,
                    color: WxColors.cyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Pressure score: ${view.notifReport.pressureScore}/100',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${view.notifReport.refocusCost.formatHm()} estimated refocus cost · ${view.notifReport.spamApps} spam apps',
                      style: const TextStyle(
                        fontSize: 12,
                        color: WxColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: WxColors.textMuted),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.timeline_outlined),
                label: const Text('Timeline'),
                onPressed: () => context.push('/timeline'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.history_outlined),
                label: const Text('Lifetime'),
                onPressed: () => context.push('/lifetime'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------- chart widgets ----------

class _ScreenTimeBars extends StatelessWidget {
  const _ScreenTimeBars({required this.days});
  final List<DailyStats> days;

  @override
  Widget build(BuildContext context) {
    final maxMs = days
        .map((d) => d.screenTime.inMilliseconds)
        .fold<int>(0, (a, b) => b > a ? b : a);
    final maxY = maxMs == 0 ? 1.0 : maxMs / 60000.0;
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY * 1.2,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= days.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      WxDates.dayShort(days[i].day).substring(0, 1),
                      style: const TextStyle(
                        fontSize: 10,
                        color: WxColors.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: <BarChartGroupData>[
            for (int i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: <BarChartRodData>[
                  BarChartRodData(
                    toY: days[i].screenTime.inMinutes.toDouble(),
                    width: 10,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: <Color>[WxColors.surface3, WxColors.accent],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Series {
  final String label;
  final Color color;
  const _Series(this.label, this.color);
}

class _DualLineChart extends StatelessWidget {
  const _DualLineChart({
    required this.days,
    required this.seriesA,
    required this.seriesB,
    required this.valueA,
    required this.valueB,
    required this.yMax,
  });
  final List<DailyStats> days;
  final _Series seriesA;
  final _Series seriesB;
  final double Function(DailyStats) valueA;
  final double Function(DailyStats) valueB;
  final double yMax;

  @override
  Widget build(BuildContext context) {
    if (days.length < 2) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Not enough data yet.',
            style: TextStyle(color: WxColors.textSecondary),
          ),
        ),
      );
    }
    final spotsA = <FlSpot>[
      for (int i = 0; i < days.length; i++) FlSpot(i.toDouble(), valueA(days[i]))
    ];
    final spotsB = <FlSpot>[
      for (int i = 0; i < days.length; i++) FlSpot(i.toDouble(), valueB(days[i]))
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            _LegendDot(color: seriesA.color, label: seriesA.label),
            const SizedBox(width: 14),
            _LegendDot(color: seriesB.color, label: seriesB.label),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: yMax,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= days.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          WxDates.dayShort(days[i].day).substring(0, 1),
                          style: const TextStyle(
                            fontSize: 10,
                            color: WxColors.textMuted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: <LineChartBarData>[
                LineChartBarData(
                  spots: spotsA,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: seriesA.color,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        seriesA.color.withValues(alpha: 0.25),
                        seriesA.color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                LineChartBarData(
                  spots: spotsB,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: seriesB.color,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: WxColors.textSecondary),
        ),
      ],
    );
  }
}

class _UnlocksLine extends StatelessWidget {
  const _UnlocksLine({required this.days});
  final List<DailyStats> days;

  @override
  Widget build(BuildContext context) {
    final maxV =
        days.map((d) => d.unlocks).fold<int>(0, (a, b) => b > a ? b : a);
    if (maxV == 0) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No unlocks recorded yet.',
            style: TextStyle(color: WxColors.textSecondary),
          ),
        ),
      );
    }
    final spots = <FlSpot>[
      for (int i = 0; i < days.length; i++)
        FlSpot(i.toDouble(), days[i].unlocks.toDouble()),
    ];
    final avg = days.fold<int>(0, (a, b) => a + b.unlocks) ~/ days.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('AVG ${avg}/day',
                style: const TextStyle(
                    fontSize: 11,
                    color: WxColors.textMuted,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('PEAK ${maxV}',
                style: const TextStyle(
                    fontSize: 11,
                    color: WxColors.amber,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxV * 1.15,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineBarsData: <LineChartBarData>[
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: WxColors.amber,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        WxColors.amber.withValues(alpha: 0.30),
                        WxColors.amber.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayOfWeekBars extends StatelessWidget {
  const _DayOfWeekBars({required this.days});
  final List<DailyStats> days;

  @override
  Widget build(BuildContext context) {
    final byWeekday = <int, ({int totalMs, int n})>{};
    for (final d in days) {
      final cur = byWeekday[d.day.weekday];
      byWeekday[d.day.weekday] = (
        totalMs: (cur?.totalMs ?? 0) + d.screenTime.inMilliseconds,
        n: (cur?.n ?? 0) + 1,
      );
    }
    final avgs = <int, int>{};
    for (final e in byWeekday.entries) {
      avgs[e.key] = e.value.n == 0 ? 0 : (e.value.totalMs ~/ e.value.n);
    }
    final maxV =
        avgs.values.fold<int>(0, (a, b) => b > a ? b : a);
    const labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (int day = 1; day <= 7; day++) ...<Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      avgs[day] == null
                          ? '—'
                          : Duration(milliseconds: avgs[day]!).formatHm(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: WxColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: maxV == 0
                          ? 4
                          : (((avgs[day] ?? 0) / maxV) * 70).clamp(4.0, 70.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: <Color>[
                            WxColors.cyan.withValues(alpha: 0.35),
                            WxColors.cyan,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[day - 1],
                      style: const TextStyle(
                        fontSize: 10,
                        color: WxColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppMovement extends StatelessWidget {
  const _AppMovement({required this.view});
  final _AnalyticsView view;

  @override
  Widget build(BuildContext context) {
    final cur = <String, AppUsage>{};
    final prev = <String, AppUsage>{};
    final last7 = view.last14.sublist(7);
    final prev7 = view.last14.sublist(0, 7);
    for (final d in last7) {
      for (final a in d.apps) {
        final ex = cur[a.packageName];
        cur[a.packageName] = AppUsage(
          packageName: a.packageName,
          displayName: a.displayName,
          category: a.category,
          foreground: (ex?.foreground ?? Duration.zero) + a.foreground,
          opens: (ex?.opens ?? 0) + a.opens,
          notifications: (ex?.notifications ?? 0) + a.notifications,
        );
      }
    }
    for (final d in prev7) {
      for (final a in d.apps) {
        final ex = prev[a.packageName];
        prev[a.packageName] = AppUsage(
          packageName: a.packageName,
          displayName: a.displayName,
          category: a.category,
          foreground: (ex?.foreground ?? Duration.zero) + a.foreground,
          opens: (ex?.opens ?? 0) + a.opens,
          notifications: (ex?.notifications ?? 0) + a.notifications,
        );
      }
    }
    final movers = <({AppUsage app, int deltaMin})>[];
    for (final entry in cur.entries) {
      final p = prev[entry.key];
      final delta = entry.value.foreground.inMinutes -
          (p?.foreground.inMinutes ?? 0);
      movers.add((app: entry.value, deltaMin: delta));
    }
    movers.sort((a, b) => b.deltaMin.abs().compareTo(a.deltaMin.abs()));
    final top = movers.take(6).toList();
    if (top.isEmpty) {
      return const Text(
        'No app data yet.',
        style: TextStyle(color: WxColors.textSecondary),
      );
    }
    return Column(
      children: <Widget>[
        for (final m in top) ...<Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: WxColors.category[m.app.category.code],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  m.app.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: WxColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${m.deltaMin > 0 ? '+' : ''}${m.deltaMin}m',
                style: WxTypography.mono(
                  size: 13,
                  color: m.deltaMin >= 0 ? WxColors.crimson : WxColors.accent,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                m.deltaMin >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: m.deltaMin >= 0 ? WxColors.crimson : WxColors.accent,
              ),
            ],
          ),
          if (m != top.last) const Divider(height: 16),
        ],
      ],
    );
  }
}

/// Tiny inline proxy that re-runs single-day behavior maths for trend lines.
class _BehaviorEngineProxy {
  static int productivity(DailyStats day) {
    final p = day.productiveTime.inMinutes;
    final d = day.distractionTime.inMinutes;
    final total = p + d;
    if (total == 0) return 50;
    return ((p / total) * 100).round();
  }

  static int overload(DailyStats day, List<DailyStats> _) {
    final notifPressure = (day.notifications / 2).clamp(0, 100);
    final sleep = (day.sleepMisuse.inMinutes / 60 * 25).clamp(0, 25);
    final screen = ((day.screenTime.inMinutes / 480) * 100).clamp(0, 25);
    return (notifPressure * 0.35 + sleep * 0.30 + screen * 0.35)
        .clamp(0, 100)
        .round();
  }
}

