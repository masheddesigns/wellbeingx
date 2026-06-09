import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/duration_format.dart';
import '../../data/db/database.dart';
import '../../data/repositories/focus_repository.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';

class _FocusAnalytics {
  final List<FocusSessionRow> all;
  final Duration totalCompleted;
  final int completedCount;
  final FocusSessionRow? longest;
  final Map<int, int> byHour; // hour -> minutes
  final Map<int, int> byWeekday; // 1..7 -> minutes
  final Map<String, int> byTag; // tag -> sessions
  const _FocusAnalytics({
    required this.all,
    required this.totalCompleted,
    required this.completedCount,
    required this.longest,
    required this.byHour,
    required this.byWeekday,
    required this.byTag,
  });
}

final _focusAnalyticsProvider = FutureProvider<_FocusAnalytics>((ref) async {
  final repo = ref.watch(focusRepositoryProvider);
  final all = await repo.history(limit: 500);
  final completed = all.where((s) => s.completed).toList();
  final byHour = <int, int>{};
  final byWeekday = <int, int>{};
  final byTag = <String, int>{};
  Duration total = Duration.zero;
  FocusSessionRow? longest;
  for (final s in completed) {
    total += Duration(milliseconds: s.actualMs);
    if (longest == null || s.actualMs > longest.actualMs) longest = s;
    final dt = DateTime.fromMillisecondsSinceEpoch(s.startedMs);
    final mins = (s.actualMs / 60000).round();
    byHour.update(dt.hour, (v) => v + mins, ifAbsent: () => mins);
    byWeekday.update(dt.weekday, (v) => v + mins, ifAbsent: () => mins);
    final tag = s.tag ?? s.mode;
    byTag.update(tag, (v) => v + 1, ifAbsent: () => 1);
  }
  return _FocusAnalytics(
    all: all,
    totalCompleted: total,
    completedCount: completed.length,
    longest: longest,
    byHour: byHour,
    byWeekday: byWeekday,
    byTag: byTag,
  );
});

class FocusAnalyticsScreen extends ConsumerWidget {
  const FocusAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(_focusAnalyticsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Focus analytics')),
      body: view.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (a) {
          if (a.completedCount == 0) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Complete a few focus sessions to unlock analytics.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: WxColors.textSecondary),
                ),
              ),
            );
          }
          final peakHour = a.byHour.entries.isEmpty
              ? null
              : a.byHour.entries.reduce((p, q) => p.value >= q.value ? p : q).key;
          final peakDay = a.byWeekday.entries.isEmpty
              ? null
              : a.byWeekday.entries.reduce((p, q) => p.value >= q.value ? p : q).key;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            children: <Widget>[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'TOTAL FOCUS TIME',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textMuted,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a.totalCompleted.formatHm(),
                      style: WxTypography.mono(
                          size: 36, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${a.completedCount} completed sessions',
                      style: const TextStyle(
                        fontSize: 12,
                        color: WxColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (a.longest != null) ...<Widget>[
                const SectionHeader(title: 'LONGEST SESSION'),
                GlassCard(
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.bolt_outlined,
                          color: WxColors.accent, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              Duration(milliseconds: a.longest!.actualMs).formatHm(),
                              style: WxTypography.mono(
                                  size: 22, color: WxColors.accent),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${a.longest!.mode}${a.longest!.tag == null ? '' : ' · ${a.longest!.tag}'} · ${DateFormat('d MMM').format(DateTime.fromMillisecondsSinceEpoch(a.longest!.startedMs))}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: WxColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SectionHeader(title: 'WHEN YOU FOCUS'),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      peakHour == null
                          ? 'No data yet'
                          : 'Peak focus hour: ${_hourLabel(peakHour)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: WxColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      peakDay == null
                          ? ''
                          : 'Best weekday: ${_weekdayLabel(peakDay)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: WxColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _HourBars(byHour: a.byHour),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (a.byTag.isNotEmpty) ...<Widget>[
                const SectionHeader(title: 'BY INTENT'),
                GlassCard(
                  child: Column(
                    children: <Widget>[
                      for (final e in (a.byTag.entries.toList()
                            ..sort((x, y) => y.value.compareTo(x.value))))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: WxColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: WxColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${e.value} session${e.value == 1 ? '' : 's'}',
                                style: WxTypography.mono(size: 13),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _hourLabel(int h) {
    final dt = DateTime(2000, 1, 1, h);
    return DateFormat('h a').format(dt);
  }

  String _weekdayLabel(int d) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];
  }
}

class _HourBars extends StatelessWidget {
  const _HourBars({required this.byHour});
  final Map<int, int> byHour;

  @override
  Widget build(BuildContext context) {
    final maxV = byHour.values.fold<int>(0, (a, b) => b > a ? b : a);
    return SizedBox(
      height: 64,
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
                      : (((byHour[h] ?? 0) / maxV) * 60).clamp(4.0, 60.0),
                  decoration: BoxDecoration(
                    color: WxColors.accent
                        .withValues(alpha: maxV == 0 ? 0.15 : 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
