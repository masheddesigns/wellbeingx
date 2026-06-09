import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/sleep_engine.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/skeleton.dart';

final _sleepProvider =
    FutureProvider<({SleepReport report, List<DateTime> days})>((ref) async {
      final last14 = await ref.watch(usageRepositoryProvider).rangeStats(14);
      final report = const SleepEngine().analyze(last14Days: last14);
      return (report: report, days: last14.map((d) => d.day).toList());
    });

class SleepMorningScreen extends ConsumerWidget {
  const SleepMorningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(_sleepProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep & morning')),
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
        data: (v) => _Body(report: v.report, days: v.days),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.report, required this.days});
  final SleepReport report;
  final List<DateTime> days;

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
                colors: <Color>[Color(0xFF0F1226), Color(0xFF06070A)],
              ),
              border: Border.all(
                color: WxColors.violet.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'YOUR NIGHT, YOUR MORNING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.violet,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _Stat(
                        label: 'PROBABLE SLEEP',
                        value: report.medianBedtime.format(),
                        emoji: '🌙',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'TRUE PICKUP',
                        value: report.medianFirstPickup.format(),
                        emoji: '🌅',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _Stat(
                        label: 'SLEEP GAP',
                        value: report.medianSleepGap.inMinutes == 0
                            ? '—'
                            : report.medianSleepGap.formatHm(),
                        emoji: '⏳',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'CONSISTENCY',
                        value: '${report.bedtimeConsistency}%',
                        emoji: '🎯',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'PROBABLE SLEEP — LAST 14 DAYS'),
        FadeRise(
          delay: const Duration(milliseconds: 80),
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: _ClockTimeline(
              minutes: report.lastUsageHistory,
              days: days,
              accent: WxColors.violet,
              isBedtime: true,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'TRUE PICKUP — LAST 14 DAYS'),
        FadeRise(
          delay: const Duration(milliseconds: 160),
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: _ClockTimeline(
              minutes: report.firstPickupHistory,
              days: days,
              accent: WxColors.amber,
              isBedtime: false,
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
                if (report.stableWindowCount < 3)
                  const _Bullet(
                    text:
                        'No stable sleep window detected on most nights. Treat this as a weak signal.',
                  ),
                if (report.fragmentedNightCount >= 2)
                  _Bullet(
                    text:
                        '${report.fragmentedNightCount} nights had meaningful activity after probable sleep onset.',
                  ),
                if (report.nightUsage.inMinutes >= 30)
                  _Bullet(
                    text:
                        '${report.nightUsage.formatHm()} of phone use after 10pm.',
                  ),
                if (report.bedtimeConsistency >= 70)
                  _Bullet(
                    text:
                        'Your probable sleep window is highly consistent (${report.bedtimeConsistency}%).',
                  ),
                if (report.bedtimeConsistency < 40 &&
                    report.bedtimeConsistency > 0)
                  _Bullet(
                    text:
                        'Your probable sleep window varies a lot. Steadier nights usually mean steadier focus.',
                  ),
                if (report.medianSleepGap.inHours >= 6)
                  _Bullet(
                    text:
                        'Median sleep gap: ${report.medianSleepGap.formatHm()}.',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.emoji});
  final String label;
  final String value;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(value, style: WxTypography.mono(size: 22)),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: WxColors.textMuted,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Plots one minute-of-day per day across the chart. For bedtime we shift
/// hours so 11pm and 1am sit close together visually.
class _ClockTimeline extends StatelessWidget {
  const _ClockTimeline({
    required this.minutes,
    required this.days,
    required this.accent,
    required this.isBedtime,
  });
  final List<int?> minutes;
  final List<DateTime> days;
  final Color accent;
  final bool isBedtime;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: LayoutBuilder(
        builder: (ctx, c) {
          // Y-axis: for bedtime, 6pm..6am (12 hour window centred on midnight).
          // For pickup, 4am..1pm.
          final yStart = isBedtime ? 18 * 60 : 4 * 60; // minutes
          final yEnd = isBedtime
              ? 30 * 60
              : 13 * 60; // minutes (next day for bedtime)
          final yRange = yEnd - yStart;

          double yFor(int? m) {
            if (m == null) return double.nan;
            int v = m;
            if (isBedtime && v < 12 * 60) {
              v += 24 * 60; // wrap morning into next day
            }
            final t = ((v - yStart) / yRange).clamp(0.0, 1.0);
            return c.maxHeight - t * c.maxHeight;
          }

          final width = c.maxWidth;
          final n = minutes.length;
          final stepX = n <= 1 ? width : width / (n - 1);

          return Stack(
            children: <Widget>[
              // Reference labels.
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Text(
                  isBedtime ? '6 AM' : '1 PM',
                  style: const TextStyle(
                    fontSize: 9,
                    color: WxColors.textMuted,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Text(
                  isBedtime ? '6 PM' : '4 AM',
                  style: const TextStyle(
                    fontSize: 9,
                    color: WxColors.textMuted,
                  ),
                ),
              ),
              // Connecting line + dots.
              CustomPaint(
                size: Size(width, c.maxHeight),
                painter: _LinePainter(
                  yPositions: minutes.map(yFor).toList(),
                  stepX: stepX,
                  accent: accent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.yPositions,
    required this.stepX,
    required this.accent,
  });
  final List<double> yPositions;
  final double stepX;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = accent
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dot = Paint()..color = accent;

    // Draw connecting segments where consecutive points are non-null.
    Offset? prev;
    for (int i = 0; i < yPositions.length; i++) {
      final y = yPositions[i];
      if (y.isNaN) {
        prev = null;
        continue;
      }
      final p = Offset(i * stepX, y);
      if (prev != null) canvas.drawLine(prev, p, line);
      canvas.drawCircle(p, 3, dot);
      prev = p;
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.yPositions != yPositions ||
      old.accent != accent ||
      old.stepX != stepX;
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
            child: Icon(
              Icons.bedtime_outlined,
              size: 12,
              color: WxColors.violet,
            ),
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
