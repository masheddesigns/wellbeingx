import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/haptics.dart';
import '../../core/utils/duration_format.dart';
import '../../data/db/database.dart';
import '../../data/repositories/mood_repository.dart';
import '../../data/repositories/usage_repository.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';

final _recentMoodsProvider = FutureProvider<List<MoodRow>>((ref) async {
  return ref.watch(moodRepositoryProvider).recent();
});

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});
  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int? _score;
  String? _tag;
  static const List<({String tag, String emoji})> _moods = <({String tag, String emoji})>[
    (tag: 'awful', emoji: '😖'),
    (tag: 'low', emoji: '😕'),
    (tag: 'okay', emoji: '😐'),
    (tag: 'good', emoji: '🙂'),
    (tag: 'great', emoji: '😄'),
  ];

  @override
  Widget build(BuildContext context) {
    final moods = ref.watch(_recentMoodsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mood')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: <Widget>[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'HOW DO YOU FEEL?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textMuted,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    for (int i = 0; i < _moods.length; i++) ...<Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Haptics.tap();
                            setState(() {
                              _score = i + 1;
                              _tag = _moods[i].tag;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _score == i + 1
                                  ? WxColors.accent.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _score == i + 1
                                    ? WxColors.accent
                                    : WxColors.hairline,
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  _moods[i].emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _moods[i].tag,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _score == i + 1
                                        ? WxColors.accent
                                        : WxColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (i != _moods.length - 1) const SizedBox(width: 6),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _score == null
                      ? null
                      : () async {
                          await ref.read(moodRepositoryProvider).log(
                                score: _score!,
                                tag: _tag,
                              );
                          Haptics.success();
                          ref.invalidate(_recentMoodsProvider);
                          if (mounted) {
                            setState(() {
                              _score = null;
                              _tag = null;
                            });
                          }
                        },
                  child: const Text('Log mood'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'CORRELATION — LAST 7 DAYS'),
          _MoodUsageCorrelation(),
          const SizedBox(height: 16),
          const SectionHeader(title: 'RECENT'),
          moods.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (rows) {
              if (rows.isEmpty) {
                return const GlassCard(
                  child: Text(
                    'No moods logged yet.',
                    style: TextStyle(color: WxColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: <Widget>[
                  for (final m in rows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: <Widget>[
                            Text(
                              _moods[(m.score - 1).clamp(0, 4)].emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    m.tag ?? _moods[(m.score - 1).clamp(0, 4)].tag,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: WxColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('EEE d MMM · HH:mm').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          m.timestampMs),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: WxColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MoodUsageCorrelation extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(usageRepositoryProvider);
    final moodsRepo = ref.watch(moodRepositoryProvider);
    return FutureBuilder<({double r, Duration avgHigh, Duration avgLow})>(
      future: () async {
        final last7 = await usage.rangeStats(7);
        final moods = await moodsRepo.recent(limit: 100);
        final byDay = <int, List<int>>{};
        for (final m in moods) {
          final dt = DateTime.fromMillisecondsSinceEpoch(m.timestampMs);
          final dayKey = DateTime(dt.year, dt.month, dt.day)
              .millisecondsSinceEpoch ~/
              Duration.millisecondsPerDay;
          byDay.putIfAbsent(dayKey, () => <int>[]).add(m.score);
        }
        Duration sumHigh = Duration.zero;
        int nHigh = 0;
        Duration sumLow = Duration.zero;
        int nLow = 0;
        for (final d in last7) {
          final key = d.day.millisecondsSinceEpoch ~/
              Duration.millisecondsPerDay;
          final scores = byDay[key];
          if (scores == null || scores.isEmpty) continue;
          final avg = scores.reduce((a, b) => a + b) / scores.length;
          if (avg >= 4) {
            sumHigh += d.screenTime;
            nHigh++;
          } else if (avg <= 2) {
            sumLow += d.screenTime;
            nLow++;
          }
        }
        return (
          r: 0.0,
          avgHigh: nHigh == 0
              ? Duration.zero
              : Duration(microseconds: sumHigh.inMicroseconds ~/ nHigh),
          avgLow: nLow == 0
              ? Duration.zero
              : Duration(microseconds: sumLow.inMicroseconds ~/ nLow),
        );
      }(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const GlassCard(
            child: SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final v = snap.data!;
        if (v.avgHigh.inMinutes == 0 && v.avgLow.inMinutes == 0) {
          return const GlassCard(
            child: Text(
              'Log a few moods over a few days to see how phone use correlates with how you feel.',
              style: TextStyle(color: WxColors.textSecondary),
            ),
          );
        }
        return GlassCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'GOOD-MOOD DAYS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textMuted,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(v.avgHigh.formatHm(),
                        style: WxTypography.mono(
                            size: 22, color: WxColors.accent)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'LOW-MOOD DAYS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textMuted,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(v.avgLow.formatHm(),
                        style: WxTypography.mono(
                            size: 22, color: WxColors.crimson)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
