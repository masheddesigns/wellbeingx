import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/app_icons.dart';
import '../../core/services/haptics.dart';
import '../../core/services/share_export.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/personality_classifier.dart';
import '../../domain/engines/replay_chapters.dart';
import '../dashboard/dashboard_state.dart';
import '../../domain/models/app_category.dart';
import '../../domain/models/daily_stats.dart';
import '../../domain/models/personality_type.dart';

/// Loaded data for one Daily Replay session.
class _ReplayData {
  final DailyStats today;
  final DailyStats yesterday;
  final PersonalityType personality;
  final ReplayScript script;
  const _ReplayData({
    required this.today,
    required this.yesterday,
    required this.personality,
    required this.script,
  });
}

final _cinematicReplayProvider = FutureProvider<_ReplayData>((ref) async {
  // Re-build the replay script after every ingest — otherwise the chapters
  // freeze on the first day's data and never reflect the latest hour.
  ref.watch(lastIngestProvider);
  final repo = ref.watch(usageRepositoryProvider);
  final today = await repo.dayStats(DateTime.now());
  final yesterday = await repo.dayStats(
    DateTime.now().subtract(const Duration(days: 1)),
  );
  final last7 = await repo.rangeStats(7);
  final personality = const PersonalityClassifier().classify(last7);
  final script = const ReplayChaptersEngine().scriptFor(
    today: today,
    yesterday: yesterday,
    personality: personality,
  );
  return _ReplayData(
    today: today,
    yesterday: yesterday,
    personality: personality,
    script: script,
  );
});

/// The flagship Daily Replay ritual — full-bleed, auto-playing, chaptered.
class CinematicReplayScreen extends ConsumerStatefulWidget {
  const CinematicReplayScreen({super.key});

  @override
  ConsumerState<CinematicReplayScreen> createState() =>
      _CinematicReplayScreenState();
}

class _CinematicReplayScreenState extends ConsumerState<CinematicReplayScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(_cinematicReplayProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      body: data.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: WxColors.accent),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '$e',
              style: const TextStyle(color: WxColors.textSecondary),
            ),
          ),
        ),
        data: (d) => _ReplayPlayer(data: d),
      ),
    );
  }
}

class _ReplayPlayer extends StatefulWidget {
  const _ReplayPlayer({required this.data});
  final _ReplayData data;

  @override
  State<_ReplayPlayer> createState() => _ReplayPlayerState();
}

class _ReplayPlayerState extends State<_ReplayPlayer>
    with TickerProviderStateMixin {
  late final AnimationController _chapterCtrl;
  late final AnimationController _ambientCtrl;
  int _index = 0;
  bool _paused = false;
  Timer? _autoNext;

  final GlobalKey _shareBoundary = GlobalKey();

  ReplayScript get _script => widget.data.script;
  ReplayChapter get _current => _script.chapters[_index];
  bool get _isLast => _index == _script.chapters.length - 1;

  @override
  void initState() {
    super.initState();
    _chapterCtrl = AnimationController(
      vsync: this,
      duration: _current.duration,
    );
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _chapterCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Haptics.replayControl();
      _startCurrent();
    });
  }

  @override
  void dispose() {
    _autoNext?.cancel();
    _chapterCtrl.dispose();
    _ambientCtrl.dispose();
    super.dispose();
  }

  void _startCurrent() {
    _chapterCtrl
      ..stop()
      ..duration = _current.duration
      ..reset();
    if (!_paused) {
      _chapterCtrl.forward();
      _autoNext?.cancel();
      _autoNext = Timer(_current.duration, _advance);
    }
  }

  void _advance() {
    if (!mounted) return;
    if (_isLast) {
      // Hold on outro — no auto close. User taps share or dismiss.
      return;
    }
    setState(() => _index++);
    Haptics.scrub();
    _startCurrent();
  }

  void _previous() {
    if (_index == 0) {
      _chapterCtrl.reset();
      if (!_paused) _chapterCtrl.forward();
      return;
    }
    setState(() => _index--);
    Haptics.scrub();
    _startCurrent();
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      _chapterCtrl.stop();
      _autoNext?.cancel();
      Haptics.light();
    } else {
      _chapterCtrl.forward();
      final remaining =
          _current.duration * (1.0 - _chapterCtrl.value).clamp(0.0, 1.0);
      _autoNext?.cancel();
      _autoNext = Timer(remaining, _advance);
      Haptics.replayControl();
    }
  }

  void _exit() {
    Navigator.of(context).maybePop();
  }

  Future<void> _share() async {
    Haptics.success();
    await ShareExport.shareBoundary(
      _shareBoundary,
      filename: 'wellbeingx-day.png',
      text: 'My day, in 60 seconds — WellbeingX',
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final palette = _paletteFor(_current.kind);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) {
        // Edges: left third = prev, right third = next, center = pause/play.
        final w = media.size.width;
        final dx = d.globalPosition.dx;
        if (dx < w * 0.28) {
          _previous();
        } else if (dx > w * 0.72) {
          _advance();
        } else {
          _togglePause();
        }
      },
      onLongPress: _exit,
      child: RepaintBoundary(
        key: _shareBoundary,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.3),
              radius: 1.2,
              colors: <Color>[
                palette.glow.withValues(alpha: 0.55),
                WxColors.void_,
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Ambient drifting noise layer.
              AnimatedBuilder(
                animation: _ambientCtrl,
                builder: (_, child) => CustomPaint(
                  painter: _AmbientPainter(
                    t: _ambientCtrl.value,
                    color: palette.glow,
                  ),
                ),
              ),
              // Main chapter content.
              Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  media.padding.top + 36,
                  24,
                  media.padding.bottom + 28,
                ),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 21),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: WxColors.textPrimary,
                          ),
                          onPressed: _exit,
                        ),
                        const Spacer(),
                        if (_current.label != null)
                          Text(
                            _current.label!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: WxColors.textMuted,
                              letterSpacing: 2.2,
                            ),
                          ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            _paused ? Icons.play_arrow : Icons.pause,
                            color: WxColors.textSecondary,
                          ),
                          onPressed: _togglePause,
                        ),
                      ],
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 480),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _ChapterStage(
                          key: ValueKey<int>(_index),
                          chapter: _current,
                          progress: _chapterCtrl.value,
                          ambient: _ambientCtrl.value,
                          today: widget.data.today,
                          palette: palette,
                          onShare: _share,
                          isLast: _isLast,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Per-chapter stage ----

class _ChapterStage extends StatelessWidget {
  const _ChapterStage({
    super.key,
    required this.chapter,
    required this.progress,
    required this.ambient,
    required this.today,
    required this.palette,
    required this.onShare,
    required this.isLast,
  });

  final ReplayChapter chapter;
  final double progress;
  final double ambient;
  final DailyStats today;
  final _Palette palette;
  final VoidCallback onShare;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    switch (chapter.kind) {
      case ChapterKind.title:
        return _TitleStage(chapter: chapter, palette: palette);
      case ChapterKind.empty:
        return _CenteredText(chapter: chapter, palette: palette);
      case ChapterKind.wake:
        return _WakeStage(chapter: chapter, palette: palette);
      case ChapterKind.morning:
        return _CountUpStage(
          chapter: chapter,
          palette: palette,
          progress: progress,
          unit: 'm',
          subline: chapter.body,
        );
      case ChapterKind.midday:
        return _PeakHourStage(chapter: chapter, palette: palette);
      case ChapterKind.slip:
        return _AppFocusStage(
          chapter: chapter,
          palette: palette,
          tone: _AppTone.slip,
        );
      case ChapterKind.bestHour:
        return _AppFocusStage(
          chapter: chapter,
          palette: palette,
          tone: _AppTone.best,
        );
      case ChapterKind.total:
        return _CountUpStage(
          chapter: chapter,
          palette: palette,
          progress: progress,
          big: true,
          unit: '',
          subline: 'on screen today',
          formatHm: true,
        );
      case ChapterKind.whereItWent:
        return _CategoryBreakdownStage(
          chapter: chapter,
          palette: palette,
          today: today,
          progress: progress,
        );
      case ChapterKind.breath:
        return const SizedBox.expand();
      case ChapterKind.outro:
        return _OutroStage(
          chapter: chapter,
          palette: palette,
          onShare: onShare,
        );
    }
  }
}

// ---- Reusable chapter visuals ----

class _TitleStage extends StatelessWidget {
  const _TitleStage({required this.chapter, required this.palette});
  final ReplayChapter chapter;
  final _Palette palette;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          chapter.label ?? '',
          style: TextStyle(
            fontSize: 11,
            color: palette.glow,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          chapter.headline,
          style: WxTypography.mono(size: 64, weight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (chapter.body != null)
          Text(
            chapter.body!,
            style: const TextStyle(fontSize: 18, color: WxColors.textSecondary),
          ),
      ],
    );
  }
}

class _CenteredText extends StatelessWidget {
  const _CenteredText({required this.chapter, required this.palette});
  final ReplayChapter chapter;
  final _Palette palette;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          chapter.headline,
          textAlign: TextAlign.center,
          style: WxTypography.mono(size: 36, weight: FontWeight.w700),
        ),
        if (chapter.body != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            chapter.body!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: WxColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _WakeStage extends StatelessWidget {
  const _WakeStage({required this.chapter, required this.palette});
  final ReplayChapter chapter;
  final _Palette palette;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                palette.glow.withValues(alpha: 0.6),
                palette.glow.withValues(alpha: 0.0),
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.wb_twilight, color: palette.glow, size: 48),
        ),
        const SizedBox(height: 30),
        Text(
          chapter.headline,
          textAlign: TextAlign.center,
          style: WxTypography.mono(size: 32, weight: FontWeight.w700),
        ),
        if (chapter.body != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            chapter.body!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: WxColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _CountUpStage extends StatelessWidget {
  const _CountUpStage({
    required this.chapter,
    required this.palette,
    required this.progress,
    this.big = false,
    this.unit = 'm',
    this.subline,
    this.formatHm = false,
  });
  final ReplayChapter chapter;
  final _Palette palette;
  final double progress;
  final bool big;
  final String unit;
  final String? subline;
  final bool formatHm;

  @override
  Widget build(BuildContext context) {
    final target = chapter.primaryValue ?? 0;
    final eased = Curves.easeOutCubic.transform(progress.clamp(0, 1));
    final shown = (target * eased).round();
    final number = formatHm ? _formatHm(shown) : '$shown$unit';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          chapter.headline,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: WxColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          number,
          style: WxTypography.mono(
            size: big ? 96 : 72,
            weight: FontWeight.w800,
            color: palette.glow,
          ),
        ),
        if (subline != null) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            subline!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: WxColors.textSecondary),
          ),
        ],
      ],
    );
  }

  String _formatHm(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final r = m.remainder(60);
    if (r == 0) return '${h}h';
    return '${h}h ${r}m';
  }
}

class _PeakHourStage extends StatelessWidget {
  const _PeakHourStage({required this.chapter, required this.palette});
  final ReplayChapter chapter;
  final _Palette palette;
  @override
  Widget build(BuildContext context) {
    final hour = chapter.secondaryValue ?? 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 220,
          height: 60,
          child: CustomPaint(
            painter: _SunPainter(hour: hour, color: palette.glow),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          chapter.headline,
          style: WxTypography.mono(size: 36, weight: FontWeight.w800),
        ),
        if (chapter.body != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            chapter.body!,
            style: const TextStyle(fontSize: 16, color: WxColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

enum _AppTone { slip, best }

class _AppFocusStage extends StatelessWidget {
  const _AppFocusStage({
    required this.chapter,
    required this.palette,
    required this.tone,
  });
  final ReplayChapter chapter;
  final _Palette palette;
  final _AppTone tone;

  @override
  Widget build(BuildContext context) {
    final cat = chapter.category ?? AppCategory.other;
    final tint = WxColors.category[cat.code] ?? palette.glow;
    final pkg = chapter.packageName ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 128,
          height: 128,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: tint.withValues(alpha: 0.10),
            border: Border.all(color: tint.withValues(alpha: 0.35), width: 1.5),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: tint.withValues(alpha: 0.22),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AppIconAvatar(
            packageName: pkg,
            fallbackLabel: chapter.headline,
            fallbackColor: tint,
            size: 88,
            radius: 22,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          chapter.headline,
          textAlign: TextAlign.center,
          style: WxTypography.mono(size: 28, weight: FontWeight.w800),
        ),
        if (chapter.body != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            chapter.body!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: WxColors.textSecondary),
          ),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: tint.withValues(alpha: 0.14),
            border: Border.all(color: tint.withValues(alpha: 0.32)),
          ),
          child: Text(
            tone == _AppTone.slip ? 'caught you' : 'kept you',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: tint,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryBreakdownStage extends StatelessWidget {
  const _CategoryBreakdownStage({
    required this.chapter,
    required this.palette,
    required this.today,
    required this.progress,
  });
  final ReplayChapter chapter;
  final _Palette palette;
  final DailyStats today;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final entries = today.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(3).toList();
    final total = top.fold<int>(0, (a, b) => a + b.value.inMinutes);
    final eased = Curves.easeOutCubic.transform(progress.clamp(0, 1));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          chapter.headline,
          style: WxTypography.mono(size: 32, weight: FontWeight.w800),
        ),
        const SizedBox(height: 28),
        for (int i = 0; i < top.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _CategoryBar(
              cat: top[i].key,
              minutes: top[i].value.inMinutes,
              fraction: total == 0
                  ? 0
                  : (top[i].value.inMinutes / total) * eased,
            ),
          ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.cat,
    required this.minutes,
    required this.fraction,
  });
  final AppCategory cat;
  final int minutes;
  final double fraction;

  String _hm(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final r = m.remainder(60);
    return r == 0 ? '${h}h' : '${h}h ${r}m';
  }

  @override
  Widget build(BuildContext context) {
    final color = WxColors.category[cat.code] ?? WxColors.accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              cat.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            Text(
              _hm(minutes),
              style: WxTypography.mono(size: 16, weight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Stack(
            children: <Widget>[
              Container(
                height: 8,
                color: WxColors.surface3.withValues(alpha: 0.4),
              ),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0, 1),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[color.withValues(alpha: 0.7), color],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutroStage extends StatelessWidget {
  const _OutroStage({
    required this.chapter,
    required this.palette,
    required this.onShare,
  });
  final ReplayChapter chapter;
  final _Palette palette;
  final VoidCallback onShare;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          chapter.headline,
          textAlign: TextAlign.center,
          style: WxTypography.mono(size: 36, weight: FontWeight.w800),
        ),
        if (chapter.body != null) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            chapter.body!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: WxColors.textSecondary),
          ),
        ],
        const SizedBox(height: 36),
        ElevatedButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.ios_share, size: 18),
          label: const Text('Share my day'),
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.glow,
            foregroundColor: WxColors.void_,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'WELLBEINGX',
          style: TextStyle(
            fontSize: 10,
            color: WxColors.textMuted,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }
}

// ---- Progress bar (Instagram-story style segmented) ----

// ---- Painters ----

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({required this.t, required this.color});
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final theta = t * 2 * math.pi;
    for (int i = 0; i < 3; i++) {
      final phase = theta + i * (2 * math.pi / 3);
      final cx = size.width * (0.5 + 0.32 * math.cos(phase));
      final cy = size.height * (0.5 + 0.28 * math.sin(phase * 1.1));
      final p = Paint()
        ..color = color.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
      canvas.drawCircle(Offset(cx, cy), size.width * 0.4, p);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter old) =>
      old.t != t || old.color != color;
}

class _SunPainter extends CustomPainter {
  _SunPainter({required this.hour, required this.color});
  final int hour;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()
      ..color = WxColors.surface3.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final r = size.width / 2;
    final cx = size.width / 2;
    final cy = size.height;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(rect, math.pi, math.pi, false, track);

    // Sun position along the arc — mapped from hour 6..20.
    final t = ((hour - 6) / 14).clamp(0.0, 1.0);
    final angle = math.pi + math.pi * t;
    final sx = cx + r * math.cos(angle);
    final sy = cy + r * math.sin(angle);

    final glow = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(Offset(sx, sy), 14, glow);
    final body = Paint()..color = color;
    canvas.drawCircle(Offset(sx, sy), 8, body);
  }

  @override
  bool shouldRepaint(covariant _SunPainter old) =>
      old.hour != hour || old.color != color;
}

// ---- Per-chapter palette ----

class _Palette {
  final Color glow;
  const _Palette(this.glow);
}

_Palette _paletteFor(ChapterKind kind) {
  switch (kind) {
    case ChapterKind.title:
      return const _Palette(WxColors.cyan);
    case ChapterKind.wake:
      return const _Palette(WxColors.amber);
    case ChapterKind.morning:
      return const _Palette(WxColors.amber);
    case ChapterKind.midday:
      return const _Palette(WxColors.cyan);
    case ChapterKind.slip:
      return const _Palette(WxColors.crimson);
    case ChapterKind.bestHour:
      return const _Palette(WxColors.accent);
    case ChapterKind.total:
      return const _Palette(WxColors.violet);
    case ChapterKind.whereItWent:
      return const _Palette(WxColors.cyan);
    case ChapterKind.breath:
      return const _Palette(WxColors.cyan);
    case ChapterKind.outro:
      return const _Palette(WxColors.accent);
    case ChapterKind.empty:
      return const _Palette(WxColors.cyan);
  }
}
