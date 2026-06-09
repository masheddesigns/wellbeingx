import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/haptics.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/simulator_engine.dart';
import '../../domain/models/daily_stats.dart';
import '../shared/widgets/glass_card.dart';

final _topAppsProvider = FutureProvider<List<AppUsage>>((ref) async {
  final last7 = await ref.watch(usageRepositoryProvider).rangeStats(7);
  final byApp = <String, AppUsage>{};
  for (final d in last7) {
    for (final a in d.apps) {
      final ex = byApp[a.packageName];
      byApp[a.packageName] = AppUsage(
        packageName: a.packageName,
        displayName: a.displayName,
        category: a.category,
        foreground: (ex?.foreground ?? Duration.zero) + a.foreground,
        opens: (ex?.opens ?? 0) + a.opens,
        notifications: (ex?.notifications ?? 0) + a.notifications,
      );
    }
  }
  final list = byApp.values.toList()
    ..sort((a, b) => b.foreground.compareTo(a.foreground));
  // Per-day average across the 7-day window.
  return list
      .take(8)
      .map((a) => AppUsage(
            packageName: a.packageName,
            displayName: a.displayName,
            category: a.category,
            foreground: Duration(milliseconds: a.foreground.inMilliseconds ~/ 7),
            opens: (a.opens / 7).round(),
            notifications: (a.notifications / 7).round(),
          ))
      .toList();
});

class SimulatorScreen extends ConsumerStatefulWidget {
  const SimulatorScreen({super.key});
  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen> {
  AppUsage? _selected;
  double _reductionPct = 30;

  @override
  Widget build(BuildContext context) {
    final apps = ref.watch(_topAppsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('What if?')),
      body: apps.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Track for a few days first — then we can simulate cuts against your top apps.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: WxColors.textSecondary),
                ),
              ),
            );
          }
          _selected ??= list.first;
          final dailyDelta =
              -Duration(minutes: (_selected!.foreground.inMinutes * (_reductionPct / 100)).round());
          final result = const SimulatorEngine().simulate(
            app: _selected!,
            dailyDelta: dailyDelta,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            children: <Widget>[
              const Text(
                'PICK AN APP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textMuted,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final a = list[i];
                    final selected = a.packageName == _selected!.packageName;
                    return ChoiceChip(
                      label: Text(a.displayName),
                      selected: selected,
                      onSelected: (_) {
                        Haptics.tap();
                        setState(() => _selected = a);
                      },
                      selectedColor: WxColors.accent,
                      backgroundColor: WxColors.surface2,
                      side: const BorderSide(color: WxColors.hairline),
                      labelStyle: TextStyle(
                        color: selected
                            ? WxColors.void_
                            : WxColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'CUT BY ${_reductionPct.round()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textMuted,
                  letterSpacing: 1.6,
                ),
              ),
              Slider(
                value: _reductionPct,
                min: 5,
                max: 100,
                divisions: 19,
                onChanged: (v) => setState(() => _reductionPct = v),
              ),
              const SizedBox(height: 16),
              GlassCard(
                borderColor: WxColors.accent.withValues(alpha: 0.35),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'YOU\'D RECLAIM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WxColors.accent,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.yearSaved.formatHm(),
                      style: WxTypography.mono(
                        size: 44,
                        weight: FontWeight.w800,
                        color: WxColors.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'every year',
                      style: TextStyle(
                        fontSize: 14,
                        color: WxColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      result.headline,
                      style: const TextStyle(
                        fontSize: 14,
                        color: WxColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'BOOKS YOU COULD READ',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: WxColors.textMuted,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${result.booksReadable}',
                            style: WxTypography.mono(
                              size: 28,
                              color: WxColors.cyan,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text('@ 8h each',
                              style: TextStyle(
                                  fontSize: 11, color: WxColors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'WORKOUTS POSSIBLE',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: WxColors.textMuted,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${result.workoutsPossible}',
                            style: WxTypography.mono(
                              size: 28,
                              color: WxColors.amber,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text('@ 30m each',
                              style: TextStyle(
                                  fontSize: 11, color: WxColors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'DAILY VS WEEKLY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textMuted,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Row(label: 'Cut per day', value: (-dailyDelta).formatHm()),
                    const SizedBox(height: 8),
                    _Row(label: 'Saved per week', value: result.weeklySaved.formatHm()),
                    const SizedBox(height: 8),
                    _Row(label: 'Saved per year', value: result.yearSaved.formatHm()),
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

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: WxColors.textPrimary),
          ),
        ),
        Text(value, style: WxTypography.mono(size: 14)),
      ],
    );
  }
}
