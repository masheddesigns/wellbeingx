import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/haptics.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/models/daily_stats.dart';
import '../dashboard/dashboard_state.dart';

/// Flagship: animated playback of a single day. Hours sweep across the screen,
/// app icons appear when their share dominates, and a productivity-vs-distraction
/// pulse traces the curve. Designed to feel cinematic.
final _replayDayProvider = FutureProvider<DailyStats>((ref) async {
  // Refresh whenever a new ingest commits.
  ref.watch(lastIngestProvider);
  return ref.watch(usageRepositoryProvider).dayStats(DateTime.now());
});

class ReplayScreen extends ConsumerWidget {
  const ReplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(_replayDayProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      body: SafeArea(
        child: day.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (d) => _ReplayBody(day: d),
        ),
      ),
    );
  }
}

class _ReplayBody extends StatefulWidget {
  const _ReplayBody({required this.day});
  final DailyStats day;

  @override
  State<_ReplayBody> createState() => _ReplayBodyState();
}

class _ReplayBodyState extends State<_ReplayBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    _ctrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _play();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _play() {
    Haptics.tap();
    setState(() => _playing = true);
    _ctrl.forward(from: _ctrl.value).whenComplete(() {
      if (mounted) setState(() => _playing = false);
    });
  }

  void _pause() {
    Haptics.light();
    _ctrl.stop();
    setState(() => _playing = false);
  }

  void _restart() {
    _ctrl.reset();
    _play();
  }

  @override
  Widget build(BuildContext context) {
    final t = _ctrl.value;
    final hour = (t * 24).floor();
    final fraction = (t * 24) - hour;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              const Text(
                'DAY REPLAY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textMuted,
                  letterSpacing: 1.8,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          // Hero clock + emerging-app block.
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                _ParticleRing(
                  progress: t,
                  productivity: _productivityAt(widget.day, hour, fraction),
                  distraction: _distractionAt(widget.day, hour, fraction),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _hourLabel(hour),
                      style: WxTypography.mono(
                          size: 56, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _fragmentForHour(widget.day, hour),
                      style: const TextStyle(
                        fontSize: 13,
                        color: WxColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _AppRow(
                    apps: _featuredAppsAt(widget.day, hour),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ScrubberBar(
            value: t,
            day: widget.day,
            onChanged: (v) {
              _ctrl.stop();
              setState(() {
                _ctrl.value = v;
                _playing = false;
              });
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: _restart,
                icon: const Icon(Icons.replay, color: WxColors.textPrimary),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _playing ? _pause : _play,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: <Color>[WxColors.accent, WxColors.cyan],
                    ),
                  ),
                  child: Icon(
                    _playing ? Icons.pause : Icons.play_arrow,
                    color: WxColors.void_,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const SizedBox(width: 48), // symmetric spacer
            ],
          ),
        ],
      ),
    );
  }

  String _hourLabel(int h) {
    if (h >= 24) h = 23;
    final dt = DateTime(2000, 1, 1, h);
    final hr = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$hr$ampm';
  }

  double _productivityAt(DailyStats d, int h, double frac) {
    final dur = d.hourBuckets[h] ?? Duration.zero;
    if (dur.inMinutes == 0) return 0;
    final productiveShare = d.screenTime.inMinutes == 0
        ? 0
        : d.productiveTime.inMinutes / d.screenTime.inMinutes;
    return (dur.inMinutes / 60) * productiveShare * (0.6 + frac * 0.4);
  }

  double _distractionAt(DailyStats d, int h, double frac) {
    final dur = d.hourBuckets[h] ?? Duration.zero;
    if (dur.inMinutes == 0) return 0;
    final distShare = d.screenTime.inMinutes == 0
        ? 0
        : d.distractionTime.inMinutes / d.screenTime.inMinutes;
    return (dur.inMinutes / 60) * distShare * (0.6 + frac * 0.4);
  }

  String _fragmentForHour(DailyStats d, int h) {
    final mins = (d.hourBuckets[h] ?? Duration.zero).inMinutes;
    if (mins == 0) return 'screen quiet';
    if (h >= 22 || h < 5) return '${mins}m on screen — late-night';
    if (h >= 6 && h <= 9) return '${mins}m on screen — morning';
    if (h >= 12 && h <= 14) return '${mins}m on screen — midday';
    if (h >= 18 && h <= 21) return '${mins}m on screen — evening';
    return '${mins}m on screen';
  }

  List<AppUsage> _featuredAppsAt(DailyStats d, int h) {
    // Approximate: weight each app by its share of total fg, and intersect with
    // hour-bucket strength. Show top 3 most "active in this hour".
    final hourMs = (d.hourBuckets[h] ?? Duration.zero).inMilliseconds;
    if (hourMs == 0) return const <AppUsage>[];
    final sorted = d.apps.toList()
      ..sort((a, b) => b.foreground.compareTo(a.foreground));
    return sorted.take(3).toList();
  }
}

class _ParticleRing extends StatelessWidget {
  const _ParticleRing({
    required this.progress,
    required this.productivity,
    required this.distraction,
  });
  final double progress;
  final double productivity;
  final double distraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          productivity: productivity,
          distraction: distraction,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.productivity,
    required this.distraction,
  });
  final double progress;
  final double productivity;
  final double distraction;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 18;
    final track = Paint()
      ..color = WxColors.surface3.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(c, radius, track);

    // Outer arc — progress.
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: const <Color>[
          WxColors.accent,
          WxColors.cyan,
          WxColors.accent,
        ],
      ).createShader(Rect.fromCircle(center: c, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      -math.pi / 2,
      progress.clamp(0.0, 1.0) * 2 * math.pi,
      false,
      progressPaint,
    );

    // Productivity halo (cyan inward).
    if (productivity > 0) {
      final glow = Paint()
        ..color = WxColors.accent
            .withValues(alpha: (productivity.clamp(0, 1) * 0.4))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(c, radius - 30, glow);
    }
    if (distraction > 0) {
      final glow = Paint()
        ..color = WxColors.crimson
            .withValues(alpha: (distraction.clamp(0, 1) * 0.45))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);
      canvas.drawCircle(c, radius - 18, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.productivity != productivity ||
      old.distraction != distraction;
}

class _AppRow extends StatelessWidget {
  const _AppRow({required this.apps});
  final List<AppUsage> apps;

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) return const SizedBox.shrink();
    return Center(
      child: Wrap(
        spacing: 8,
        children: <Widget>[
          for (final a in apps)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (WxColors.category[a.category.code] ?? WxColors.accent)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: (WxColors.category[a.category.code] ?? WxColors.accent)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                a.displayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WxColors.category[a.category.code] ?? WxColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScrubberBar extends StatelessWidget {
  const _ScrubberBar({
    required this.value,
    required this.day,
    required this.onChanged,
  });
  final double value;
  final DailyStats day;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final maxMin = day.hourBuckets.values
        .map((v) => v.inMinutes)
        .fold<int>(0, (a, b) => b > a ? b : a);
    return SizedBox(
      height: 44,
      child: LayoutBuilder(
        builder: (ctx, c) {
          return Stack(
            children: <Widget>[
              // Hour-by-hour usage spectrum baked into the scrubber bar.
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: <Widget>[
                      for (int h = 0; h < 24; h++) ...<Widget>[
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            decoration: BoxDecoration(
                              color: maxMin == 0
                                  ? WxColors.surface3.withValues(alpha: 0.4)
                                  : WxColors.accent.withValues(
                                      alpha: ((day.hourBuckets[h]?.inMinutes ?? 0) /
                                              maxMin)
                                          .clamp(0.06, 1.0),
                                    ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Playhead.
              Positioned(
                left: c.maxWidth * value - 5,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 10,
                  decoration: BoxDecoration(
                    color: WxColors.accent,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: WxColors.accent.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
              // Drag layer.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (d) {
                    onChanged((d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0));
                  },
                  onTapDown: (d) {
                    onChanged((d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

