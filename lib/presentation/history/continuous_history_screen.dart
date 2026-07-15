import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/duration_format.dart';
import '../../domain/engines/continuous_usage_engine.dart';
import '../dashboard/dashboard_state.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/skeleton.dart';

final _continuousProvider = FutureProvider<ContinuousUsageReport>((ref) async {
  final last30 = await ref.watch(last30DaysProvider.future);
  return const ContinuousUsageEngine().analyze(days: last30);
});

class ContinuousHistoryScreen extends ConsumerWidget {
  const ContinuousHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(_continuousProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Binge & focus length')),
      body: s.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          children: const <Widget>[
            SkeletonCard(height: 220),
            SizedBox(height: 14),
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
  final ContinuousUsageReport report;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      children: <Widget>[
        FadeRise(
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF1F0F12), Color(0xFF06070A)],
              ),
              border: Border.all(color: WxColors.crimson.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'LONGEST CONTINUOUS SESSION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.crimson,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  report.longestSessionEver.inMinutes == 0
                      ? '—'
                      : report.longestSessionEver.formatHm(),
                  style: WxTypography.mono(
                      size: 44, weight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'across the last 30 days',
                  style: const TextStyle(
                    fontSize: 12,
                    color: WxColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeRise(
          delay: const Duration(milliseconds: 80),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _TileStat(
                  label: 'TOTAL BINGES',
                  value: '${report.totalBinges}',
                  caption: '> 30m on a distracting app',
                  color: WxColors.crimson,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TileStat(
                  label: 'BINGE DAYS',
                  value: '${report.daysWithBinge}',
                  caption: 'of last 30',
                  color: WxColors.amber,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeRise(
          delay: const Duration(milliseconds: 160),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _TileStat(
                  label: 'MEDIAN LONG SESSION',
                  value: report.medianLongestSession.inMinutes == 0
                      ? '—'
                      : report.medianLongestSession.formatHm(),
                  caption: 'per day',
                  color: WxColors.violet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TileStat(
                  label: 'BEST BREAK',
                  value: report.longestScreenOffEver.inMinutes == 0
                      ? '—'
                      : report.longestScreenOffEver.formatHm(),
                  caption: 'longest screen-off',
                  color: WxColors.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'LONGEST SESSION PER DAY'),
        FadeRise(
          delay: const Duration(milliseconds: 240),
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  for (int i = 0; i < report.longestSessionPerDay.length;
                      i++) ...<Widget>[
                    Expanded(
                      child: Tooltip(
                        message:
                            '${DateFormat('EEE d MMM').format(report.orderedDays[i].day)} · '
                            '${Duration(minutes: report.longestSessionPerDay[i]).formatHm()}'
                            '${report.bingePerDay[i] > 0 ? ' · ${report.bingePerDay[i]} binge' : ''}',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                            height: _bar(report.longestSessionPerDay[i],
                                report.longestSessionPerDay),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: <Color>[
                                  (report.bingePerDay[i] > 0
                                          ? WxColors.crimson
                                          : WxColors.violet)
                                      .withValues(alpha: 0.3),
                                  report.bingePerDay[i] > 0
                                      ? WxColors.crimson
                                      : WxColors.violet,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _Legend(),
      ],
    );
  }

  double _bar(int v, List<int> all) {
    final max = all.fold<int>(0, (a, b) => b > a ? b : a);
    if (max == 0) return 4;
    return ((v / max) * 120).clamp(4.0, 120.0);
  }
}

class _TileStat extends StatelessWidget {
  const _TileStat({
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });
  final String label;
  final String value;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
          Text(value, style: WxTypography.mono(size: 22)),
          const SizedBox(height: 4),
          Text(
            caption,
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

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _Dot(color: WxColors.violet, label: 'Day'),
        const SizedBox(width: 16),
        _Dot(color: WxColors.crimson, label: 'Binge day'),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.label});
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
          style:
              const TextStyle(fontSize: 11, color: WxColors.textSecondary),
        ),
      ],
    );
  }
}
