import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../domain/models/daily_stats.dart';
import '../dashboard/dashboard_state.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/skeleton.dart';

final _unlockHistoryProvider = FutureProvider<List<DailyStats>>((ref) async {
  return ref.watch(last30DaysProvider.future);
});

class UnlockHistoryScreen extends ConsumerWidget {
  const UnlockHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = ref.watch(_unlockHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock history')),
      body: h.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          children: const <Widget>[
            SkeletonCard(height: 180),
            SizedBox(height: 14),
            SkeletonCard(height: 200),
          ],
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (days) => _Body(days: days),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.days});
  final List<DailyStats> days;

  @override
  Widget build(BuildContext context) {
    final today = days.last;
    final activeDays = days.where((d) => d.unlocks > 0).length;
    final totalUnlocks =
        days.fold<int>(0, (a, d) => a + d.unlocks);
    final avg = activeDays == 0 ? 0 : (totalUnlocks / activeDays).round();
    final maxV = days.map((d) => d.unlocks).fold<int>(0, (a, b) => b > a ? b : a);

    // Hourly distribution across the window.
    final hourly = List<int>.filled(24, 0);
    for (final d in days) {
      final dayHourTotal = d.hourBuckets.values
          .fold<int>(0, (a, b) => a + b.inMinutes);
      if (dayHourTotal > 0 && d.unlocks > 0) {
        d.hourBuckets.forEach((h, dur) {
          hourly[h] += ((dur.inMinutes / dayHourTotal) * d.unlocks).round();
        });
      }
    }
    final maxHour =
        hourly.fold<int>(0, (a, b) => b > a ? b : a);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      children: <Widget>[
        FadeRise(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'TODAY',
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
                    Text('${today.unlocks}',
                        style: WxTypography.mono(
                            size: 48,
                            weight: FontWeight.w800,
                            color: WxColors.amber)),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('unlocks',
                          style: TextStyle(
                              fontSize: 13, color: WxColors.textMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${today.shortUnlocks} were under 30s · avg $avg/day across last ${days.length}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: WxColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: '30-DAY UNLOCKS'),
        FadeRise(
          delay: const Duration(milliseconds: 80),
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  for (int i = 0; i < days.length; i++) ...<Widget>[
                    Expanded(
                      child: Tooltip(
                        message:
                            '${DateFormat('EEE d MMM').format(days[i].day)} · ${days[i].unlocks} unlocks',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                            height: maxV == 0
                                ? 4
                                : ((days[i].unlocks / maxV) * 110)
                                    .clamp(4.0, 110.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: <Color>[
                                  WxColors.amber.withValues(alpha: 0.3),
                                  WxColors.amber,
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
        const SizedBox(height: 16),
        const SectionHeader(title: 'WHEN YOU UNLOCK'),
        FadeRise(
          delay: const Duration(milliseconds: 160),
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Column(
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
                              height: maxHour == 0
                                  ? 4
                                  : ((hourly[h] / maxHour) * 80)
                                      .clamp(4.0, 80.0),
                              decoration: BoxDecoration(
                                color: WxColors.amber
                                    .withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
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
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeRise(
          delay: const Duration(milliseconds: 240),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'PATTERNS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textMuted,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                _Bullet(text: 'You picked up your phone ${today.unlocks} times today.'),
                if (today.shortUnlocks >= 20)
                  _Bullet(
                      text:
                          '${today.shortUnlocks} of those were under 30s — compulsive checking.'),
                if (today.firstUnlockMs != null)
                  _Bullet(
                      text:
                          'First pickup at ${_fmtClock(today.firstUnlockMs!)}.'),
                if (today.lastUnlockMs != null)
                  _Bullet(
                      text:
                          'Last unlock at ${_fmtClock(today.lastUnlockMs!)}.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmtClock(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('h:mm a').format(dt);
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 5, right: 8),
            child: Icon(Icons.bolt_outlined,
                size: 12, color: WxColors.amber),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: WxColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

