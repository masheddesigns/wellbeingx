import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/models/daily_stats.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';

final _todayProvider = FutureProvider.family<DailyStats, DateTime>((ref, day) async {
  return ref.watch(usageRepositoryProvider).dayStats(day);
});

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});
  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  DateTime _day = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dayAsync = ref.watch(_todayProvider(_day));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(
              () => _day = _day.subtract(const Duration(days: 1)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: WxDates.isSameDay(_day, DateTime.now())
                ? null
                : () => setState(
                      () => _day = _day.add(const Duration(days: 1)),
                    ),
          ),
        ],
      ),
      body: dayAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (day) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: <Widget>[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      WxDates.shortLabel(day.day).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textMuted,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(day.screenTime.formatHm(),
                            style: WxTypography.mono(
                              size: 32,
                              weight: FontWeight.w700,
                            )),
                        const SizedBox(width: 12),
                        Text(
                          '${day.unlocks} unlocks · ${day.shortUnlocks} micro',
                          style: const TextStyle(
                            fontSize: 12,
                            color: WxColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'HOUR-BY-HOUR'),
              GlassCard(
                child: Column(
                  children: <Widget>[
                    for (int h = 0; h < 24; h++) _HourRow(hour: h, day: day),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({required this.hour, required this.day});
  final int hour;
  final DailyStats day;

  @override
  Widget build(BuildContext context) {
    final dur = day.hourBuckets[hour] ?? Duration.zero;
    final maxMin = day.hourBuckets.values
        .map((v) => v.inMinutes)
        .fold<int>(0, (a, b) => b > a ? b : a);
    final pct = maxMin == 0 ? 0.0 : (dur.inMinutes / maxMin).clamp(0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 50,
            child: Text(
              WxDates.hourLabel(hour),
              style: WxTypography.mono(size: 11, color: WxColors.textMuted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: WxColors.surface2,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: pct == 0 ? 0.001 : pct,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          WxColors.accent.withValues(alpha: 0.85),
                          WxColors.cyan.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 60,
            child: Text(
              dur.inMinutes == 0 ? '—' : dur.formatHm(),
              textAlign: TextAlign.right,
              style: WxTypography.mono(size: 11, color: WxColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
