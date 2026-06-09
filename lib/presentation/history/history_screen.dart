import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/haptics.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/models/daily_stats.dart';
import '../dashboard/dashboard_state.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/skeleton.dart';

final _historyProvider = FutureProvider<List<DailyStats>>((ref) async {
  ref.watch(lastIngestProvider);
  return ref.watch(usageRepositoryProvider).rangeStats(30);
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(_historyProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      body: SafeArea(
        child: history.when(
          loading: () => ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: const <Widget>[
              SkeletonCard(height: 220),
              SizedBox(height: 14),
              SkeletonCard(height: 160),
              SizedBox(height: 14),
              SkeletonCard(height: 200),
            ],
          ),
          error: (e, _) => Center(child: Text('$e')),
          data: (days) => _Body(days: days),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.days});
  final List<DailyStats> days;

  @override
  Widget build(BuildContext context) {
    final monthTotal = days.fold<Duration>(
      Duration.zero,
      (a, d) => a + d.screenTime,
    );
    final activeDays = days.where((d) => d.screenTime.inMinutes > 0).length;
    final avg = activeDays == 0
        ? Duration.zero
        : Duration(microseconds: monthTotal.inMicroseconds ~/ activeDays);
    final best = days
        .where((d) => d.screenTime.inMinutes > 0)
        .toList()
      ..sort((a, b) => a.screenTime.compareTo(b.screenTime));
    final worst = days.toList()
      ..sort((a, b) => b.screenTime.compareTo(a.screenTime));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'History',
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
          'Your last 30 days at a glance.',
          style: TextStyle(color: WxColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),
        FadeRise(child: _MonthSummary(monthTotal: monthTotal, dailyAvg: avg)),
        const SizedBox(height: 16),
        FadeRise(
          delay: const Duration(milliseconds: 80),
          child: _CalendarHeatmap(days: days),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'TREND'),
        FadeRise(
          delay: const Duration(milliseconds: 160),
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: SizedBox(
              height: 160,
              child: _TrendLine(days: days),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (best.isNotEmpty && worst.isNotEmpty)
          FadeRise(
            delay: const Duration(milliseconds: 240),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _DayCard(
                    label: 'LIGHTEST',
                    day: best.first,
                    accent: WxColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DayCard(
                    label: 'HEAVIEST',
                    day: worst.first,
                    accent: WxColors.crimson,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        FadeRise(
          delay: const Duration(milliseconds: 320),
          child: _DaysList(days: days.reversed.take(14).toList()),
        ),
        const SizedBox(height: 22),
        const SectionHeader(title: 'EXPLORE'),
        FadeRise(
          delay: const Duration(milliseconds: 380),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                _ExploreRow(
                  icon: Icons.lock_open_rounded,
                  color: WxColors.amber,
                  label: 'Unlock history',
                  caption: 'How often you reach for the phone',
                  route: '/unlock-history',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: WxColors.divider),
                ),
                _ExploreRow(
                  icon: Icons.bedtime_outlined,
                  color: WxColors.violet,
                  label: 'Sleep & morning',
                  caption: 'Bedtime, first pickup, sleep gap',
                  route: '/sleep-morning',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: WxColors.divider),
                ),
                _ExploreRow(
                  icon: Icons.schedule_outlined,
                  color: WxColors.crimson,
                  label: 'Binge & focus length',
                  caption: 'Longest sessions, binge timeline',
                  route: '/continuous-history',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: WxColors.divider),
                ),
                _ExploreRow(
                  icon: Icons.timeline_outlined,
                  color: WxColors.cyan,
                  label: 'Day timeline',
                  caption: 'Hour-by-hour replay',
                  route: '/timeline',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExploreRow extends StatelessWidget {
  const _ExploreRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.caption,
    required this.route,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String caption;
  final String route;

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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: WxColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    style: const TextStyle(
                      fontSize: 12,
                      color: WxColors.textSecondary,
                    ),
                  ),
                ],
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

// ---------------- Month summary ----------------

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({
    required this.monthTotal,
    required this.dailyAvg,
  });
  final Duration monthTotal;
  final Duration dailyAvg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF0F141F), Color(0xFF06070A)],
        ),
        border: Border.all(color: WxColors.cyan.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'LAST 30 DAYS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: WxColors.cyan,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                monthTotal.formatHm(),
                style: WxTypography.mono(
                  size: 44,
                  weight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${dailyAvg.formatHm()} / day average',
            style: const TextStyle(
              fontSize: 13,
              color: WxColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Calendar heatmap ----------------

class _CalendarHeatmap extends StatelessWidget {
  const _CalendarHeatmap({required this.days});
  final List<DailyStats> days;

  @override
  Widget build(BuildContext context) {
    final maxMs = days
        .map((d) => d.screenTime.inMilliseconds)
        .fold<int>(0, (a, b) => b > a ? b : a);
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'CALENDAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textMuted,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Text(
                'peak ${maxMs == 0 ? '—' : Duration(milliseconds: maxMs).formatHm()}',
                style: const TextStyle(fontSize: 11, color: WxColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Day-of-week labels.
          Row(
            children: const <Widget>[
              _DowLabel('M'),
              _DowLabel('T'),
              _DowLabel('W'),
              _DowLabel('T'),
              _DowLabel('F'),
              _DowLabel('S'),
              _DowLabel('S'),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (ctx, c) {
              const rows = 5; // ~30 days
              const cols = 7;
              const gap = 4.0;
              final w = (c.maxWidth - gap * (cols - 1)) / cols;
              final h = w; // square cells
              // Build cells starting from the most recent day going back.
              // Pad the front so the LAST cell is 'today'.
              final padding = (rows * cols) - days.length;
              final cells = <Widget>[];
              for (int i = 0; i < padding; i++) {
                cells.add(SizedBox(width: w, height: h));
              }
              for (final d in days) {
                cells.add(_HeatCell(day: d, max: maxMs, w: w, h: h));
              }
              // Lay out as a grid.
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: cells,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DowLabel extends StatelessWidget {
  const _DowLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: WxColors.textMuted,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({
    required this.day,
    required this.max,
    required this.w,
    required this.h,
  });
  final DailyStats day;
  final int max;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    final t = max == 0 ? 0.0 : (day.screenTime.inMilliseconds / max).clamp(0.0, 1.0);
    final color = Color.lerp(
      WxColors.surface3.withValues(alpha: 0.5),
      WxColors.accent,
      t,
    )!;
    final isToday = WxDates.isSameDay(day.day, DateTime.now());
    return Tooltip(
      message:
          '${DateFormat('EEE d MMM').format(day.day)} · ${day.screenTime.formatHm()}',
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: WxColors.textPrimary, width: 1.2)
              : null,
        ),
      ),
    );
  }
}

// ---------------- Trend line ----------------

class _TrendLine extends StatelessWidget {
  const _TrendLine({required this.days});
  final List<DailyStats> days;

  @override
  Widget build(BuildContext context) {
    if (days.length < 2) {
      return const Center(
        child: Text(
          'Not enough data yet.',
          style: TextStyle(color: WxColors.textSecondary),
        ),
      );
    }
    final maxV = days
        .map((d) => d.screenTime.inMinutes)
        .fold<int>(0, (a, b) => b > a ? b : a);
    final spots = <FlSpot>[
      for (int i = 0; i < days.length; i++)
        FlSpot(i.toDouble(), days[i].screenTime.inMinutes.toDouble()),
    ];
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: (maxV * 1.15).clamp(60, 1 << 30).toDouble(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.4,
            color: WxColors.cyan,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  WxColors.cyan.withValues(alpha: 0.30),
                  WxColors.cyan.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Best / worst day cards ----------------

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.label,
    required this.day,
    required this.accent,
  });
  final String label;
  final DailyStats day;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: accent.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEE d MMM').format(day.day),
            style: const TextStyle(
              fontSize: 13,
              color: WxColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(day.screenTime.formatHm(),
              style: WxTypography.mono(size: 22, color: accent)),
          const SizedBox(height: 2),
          Text(
            '${day.unlocks} unlocks',
            style: const TextStyle(
              fontSize: 11,
              color: WxColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Day-by-day list ----------------

class _DaysList extends StatelessWidget {
  const _DaysList({required this.days});
  final List<DailyStats> days;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < days.length; i++) ...<Widget>[
            _DayRow(day: days[i]),
            if (i != days.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: WxColors.divider),
              ),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});
  final DailyStats day;

  @override
  Widget build(BuildContext context) {
    final mins = day.screenTime.inMinutes;
    final maxFor14h = 14 * 60;
    final pct = (mins / maxFor14h).clamp(0.0, 1.0);
    final isToday = WxDates.isSameDay(day.day, DateTime.now());
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isToday
                        ? 'TODAY'
                        : DateFormat('EEE').format(day.day).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isToday ? WxColors.accent : WxColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM').format(day.day),
                    style: const TextStyle(
                      fontSize: 11,
                      color: WxColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: pct == 0 ? 0.02 : pct,
                  minHeight: 6,
                  backgroundColor: WxColors.surface3,
                  valueColor: const AlwaysStoppedAnimation<Color>(WxColors.accent),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              child: Text(
                day.screenTime.formatHm(),
                textAlign: TextAlign.right,
                style: WxTypography.mono(size: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
