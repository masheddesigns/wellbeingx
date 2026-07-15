import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/haptics.dart';
import '../../core/services/week_narrative.dart';
import '../../domain/engines/narrative_intelligence.dart';
import '../../domain/models/daily_stats.dart';
import '../shell/app_shell.dart';

/// Directed-narrative Insights. NOT a scrolling list. A scene sequence the
/// user paces with swipes — each scene has its own physics, its own pause,
/// its own break from layout uniformity. Entering this screen triggers a
/// threshold transition: the bottom nav fades, the void deepens, an orb
/// emerges, and only then does the narrative begin. It's a mode, not a tab.
class NarrativeInsightsScreen extends ConsumerStatefulWidget {
  const NarrativeInsightsScreen({super.key});
  @override
  ConsumerState<NarrativeInsightsScreen> createState() =>
      _NarrativeInsightsScreenState();
}

class _NarrativeInsightsScreenState
    extends ConsumerState<NarrativeInsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(shellImmersionProvider.notifier).state = true;
      }
    });
  }

  @override
  void dispose() {
    // ref is valid until super.dispose; restore the shell synchronously here.
    ref.read(shellImmersionProvider.notifier).state = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bundle = ref.watch(weekNarrativeProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      body: bundle.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: WxColors.accent),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$e',
                style: const TextStyle(color: WxColors.textSecondary)),
          ),
        ),
        data: (b) => _ScenePlayer(narrative: b),
      ),
    );
  }
}

class _ScenePlayer extends StatefulWidget {
  const _ScenePlayer({required this.narrative});
  final WeekNarrative narrative;
  @override
  State<_ScenePlayer> createState() => _ScenePlayerState();
}

class _ScenePlayerState extends State<_ScenePlayer>
    with TickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _ambient;
  late final AnimationController _entry;
  /// Threshold opener — runs once on mount. While < 1.0 the scene player is
  /// suppressed and an emerging orb dominates the screen. The point is that
  /// entering Insights should feel like crossing into a different mode.
  late final AnimationController _threshold;
  int _index = 0;
  bool _holding = false;
  Timer? _holdTimer;

  late List<_Scene> _scenes;

  @override
  void initState() {
    super.initState();
    _scenes = _buildScenes(widget.narrative);
    _pageCtrl = PageController();
    final tempo = _moodTempo(widget.narrative.mood);
    _ambient = AnimationController(vsync: this, duration: tempo)..repeat();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _threshold = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          // Once the threshold lifts, the scene player's own entry begins.
          _entry.forward(from: 0);
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Haptics.light();
      _threshold.forward();
    });
  }

  @override
  void didUpdateWidget(covariant _ScenePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.narrative != widget.narrative) {
      _scenes = _buildScenes(widget.narrative);
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _pageCtrl.dispose();
    _ambient.dispose();
    _entry.dispose();
    _threshold.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _index = i);
    Haptics.scrub();
    _entry
      ..stop()
      ..reset()
      ..duration = _scenes[i].entryDuration
      ..forward();
    _holdTimer?.cancel();
    final hold = _scenes[i].holdAfter;
    if (hold != null) {
      setState(() => _holding = true);
      _holdTimer = Timer(hold, () {
        if (mounted) setState(() => _holding = false);
      });
    } else {
      setState(() => _holding = false);
    }
  }

  void _exit() => Navigator.of(context).maybePop();

  void _next() {
    if (_index < _scenes.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previous() {
    if (_index > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenes = _scenes;
    final media = MediaQuery.of(context);
    final palette = _palettesByMood[widget.narrative.mood]!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) {
        if (_threshold.value < 1.0) return; // ignore taps during threshold opener
        // Tap zones: left third = prev, right third = next, center = nothing.
        // The user paces. The app waits.
        final w = media.size.width;
        final dx = d.globalPosition.dx;
        if (dx < w * 0.30) {
          _previous();
        } else if (dx > w * 0.70) {
          _next();
        }
      },
      child: Stack(
        children: <Widget>[
          // Ambient mood layer.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambient,
              builder: (_, __) => CustomPaint(
                painter: _AmbientPainter(
                  t: _ambient.value,
                  palette: palette,
                  mood: widget.narrative.mood,
                ),
              ),
            ),
          ),
          // Scenes — opacity-gated by the threshold opener.
          AnimatedBuilder(
            animation: _threshold,
            builder: (context, _) {
              final th = _threshold.value;
              final playerOpacity = th < 0.6 ? 0.0 : ((th - 0.6) / 0.4).clamp(0.0, 1.0);
              return Opacity(
                opacity: playerOpacity,
                child: IgnorePointer(
                  ignoring: th < 1.0,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    physics: _holding
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    onPageChanged: _onPageChanged,
                    itemCount: scenes.length,
                    itemBuilder: (_, i) {
                      final scene = scenes[i];
                      return AnimatedBuilder(
                        animation: _entry,
                        builder: (_, __) => _FogEmerge(
                          progress: i == _index ? _entry.value : 1.0,
                          child: scene.builder(
                            context,
                            i == _index ? _entry.value : 1.0,
                            palette,
                            widget.narrative,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          // Threshold opener — emerging orb, mood label, then dissolves.
          AnimatedBuilder(
            animation: _threshold,
            builder: (context, _) {
              final th = _threshold.value;
              final thresholdOpacity = (1.0 - th).clamp(0.0, 1.0);
              if (thresholdOpacity <= 0.0) return const SizedBox.shrink();
              return Positioned.fill(
                child: IgnorePointer(
                  child: _ThresholdOpener(
                    progress: th,
                    palette: palette,
                    mood: widget.narrative.mood,
                  ),
                ),
              );
            },
          ),
          // Top chrome — close button only. No progress count, no segmented
          // rail. Length is intentionally ambiguous; the user shouldn't know
          // whether one scene remains or five.
          Positioned(
            left: 8,
            top: media.padding.top + 6,
            child: IconButton(
              icon: const Icon(Icons.close, color: WxColors.textMuted, size: 22),
              onPressed: _exit,
            ),
          ),
          // Hold indicator — appears when a heavy scene asks the user to wait.
          if (_holding)
            Positioned(
              bottom: media.padding.bottom + 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: WxColors.surface1.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'breathe',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: WxColors.textMuted,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          // Tail — a single discreet button to access raw analytics on the last scene.
          if (_index == scenes.length - 1)
            Positioned(
              bottom: media.padding.bottom + 64,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton.icon(
                  onPressed: () => context.push('/insights-classic'),
                  icon: const Icon(Icons.bar_chart_outlined,
                      color: WxColors.textMuted, size: 14),
                  label: const Text(
                    'See raw analytics',
                    style: TextStyle(
                      color: WxColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Duration _moodTempo(WeekMood mood) {
    switch (mood) {
      case WeekMood.calm:
      case WeekMood.protected:
      case WeekMood.recovering:
        return const Duration(seconds: 14);
      case WeekMood.fragmented:
      case WeekMood.drifting:
        return const Duration(seconds: 9);
      case WeekMood.heavy:
        return const Duration(seconds: 7);
      case WeekMood.chaotic:
        return const Duration(seconds: 5);
    }
  }
}

// ============================================================================
// Scene model
// ============================================================================

class _Scene {
  final NarrativeBeatKind kind;
  final Duration entryDuration;
  /// Pause window that disables forward swipes for emotional weight.
  final Duration? holdAfter;
  final Widget Function(
    BuildContext context,
    double entry, // 0..1 entry progress
    _MoodPalette palette,
    WeekNarrative n,
  ) builder;
  const _Scene({
    required this.kind,
    required this.entryDuration,
    required this.builder,
    this.holdAfter,
  });
}

List<_Scene> _buildScenes(WeekNarrative n) {
  final scenes = <_Scene>[];

  // 1. Identity — confrontationally minimal. No card. Two-stage dissolve.
  scenes.add(_Scene(
    kind: NarrativeBeatKind.today,
    entryDuration: const Duration(milliseconds: 2000),
    holdAfter: const Duration(milliseconds: 900),
    builder: (ctx, e, palette, _) => _IdentitySceneV2(
      sentence: n.week.identitySentence,
      mood: n.week.mood,
      palette: palette,
      entry: e,
    ),
  ));

  // 2. Core story.
  scenes.add(_Scene(
    kind: NarrativeBeatKind.thisWeek,
    entryDuration: const Duration(milliseconds: 1100),
    builder: (ctx, e, palette, _) => _CoreStoryScene(
      story: n.week.core,
      last7Days: n.last7Days,
      previous7Days: n.previous7Days,
      palette: palette,
      entry: e,
    ),
  ));

  // 3. Beats — but not as a uniform list. Each beat becomes its own scene
  //    with a layout chosen by kind. Contradictions become rupture scenes.
  for (final beat in n.week.beats) {
    if (beat.kind == NarrativeBeatKind.ritual) continue; // ritual closes.
    scenes.add(_sceneFor(beat));
  }

  // 4. Ritual — the close. Almost empty.
  final ritual = n.week.beats.firstWhere(
    (b) => b.kind == NarrativeBeatKind.ritual,
    orElse: () => const NarrativeBeat(
      kind: NarrativeBeatKind.ritual,
      label: 'RITUAL',
      headline: 'Notice what changes.',
      tone: NarrativeTone.warm,
    ),
  );
  scenes.add(_Scene(
    kind: NarrativeBeatKind.ritual,
    entryDuration: const Duration(milliseconds: 1800),
    builder: (ctx, e, palette, _) =>
        _RitualScene(beat: ritual, palette: palette, entry: e),
  ));
  return scenes;
}

_Scene _sceneFor(NarrativeBeat beat) {
  switch (beat.kind) {
    case NarrativeBeatKind.contradiction:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 700),
        holdAfter: const Duration(milliseconds: 1100),
        builder: (_, e, palette, __) =>
            _ContradictionRupture(beat: beat, palette: palette, entry: e),
      );
    case NarrativeBeatKind.slip:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 900),
        builder: (_, e, palette, __) =>
            _SlipCollapse(beat: beat, palette: palette, entry: e),
      );
    case NarrativeBeatKind.recovery:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 1200),
        builder: (_, e, palette, __) =>
            _RecoveryExpand(beat: beat, palette: palette, entry: e),
      );
    case NarrativeBeatKind.memory:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 1700),
        holdAfter: const Duration(milliseconds: 800),
        builder: (_, e, palette, __) =>
            _MemoryParallax(beat: beat, palette: palette, entry: e),
      );
    case NarrativeBeatKind.prediction:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 1300),
        builder: (_, e, palette, __) =>
            _PredictionDrift(beat: beat, palette: palette, entry: e),
      );
    case NarrativeBeatKind.afterMidnight:
    case NarrativeBeatKind.calmStreak:
    case NarrativeBeatKind.sunday:
    case NarrativeBeatKind.monthly:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 1400),
        holdAfter: const Duration(milliseconds: 700),
        builder: (_, e, palette, __) =>
            _HiddenChapterScene(beat: beat, palette: palette, entry: e),
      );
    case NarrativeBeatKind.arc:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 1100),
        builder: (_, e, palette, __) =>
            _ArcScene(beat: beat, palette: palette, entry: e),
      );
    case NarrativeBeatKind.landmark:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 1500),
        holdAfter: const Duration(milliseconds: 1000),
        builder: (_, e, palette, __) =>
            _LandmarkScene(beat: beat, palette: palette, entry: e),
      );
    case NarrativeBeatKind.motif:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 1300),
        holdAfter: const Duration(milliseconds: 800),
        builder: (_, e, palette, __) =>
            _MotifScene(beat: beat, palette: palette, entry: e),
      );
    case NarrativeBeatKind.breath:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 800),
        holdAfter: const Duration(milliseconds: 1400),
        builder: (_, __, ___, ____) => const _BreathScene(),
      );
    default:
      return _Scene(
        kind: beat.kind,
        entryDuration: const Duration(milliseconds: 900),
        builder: (_, e, palette, __) =>
            _DefaultBeatScene(beat: beat, palette: palette, entry: e),
      );
  }
}

// ============================================================================
// Scenes
// ============================================================================

/// Identity scene v2 — confrontationally minimal. No card. The space is the
/// statement.
class _IdentitySceneV2 extends StatelessWidget {
  const _IdentitySceneV2({
    required this.sentence,
    required this.mood,
    required this.palette,
    required this.entry,
  });
  final String sentence;
  final WeekMood mood;
  final _MoodPalette palette;
  final double entry;

  @override
  Widget build(BuildContext context) {
    final words = _splitForDrama(sentence);
    final stageA = Curves.easeOut.transform(entry.clamp(0.0, 0.55) / 0.55);
    final stageB = entry < 0.55
        ? 0.0
        : Curves.easeOut.transform((entry - 0.55) / 0.45);
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        media.padding.top + 80,
        24,
        media.padding.bottom + 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: stageA,
            child: Text(
              _moodLabel(mood),
              style: TextStyle(
                fontSize: 11,
                color: palette.glow,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.0,
              ),
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: stageA,
            child: Text(
              words.lead,
              style: const TextStyle(
                fontSize: 14,
                color: WxColors.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: stageB,
            child: Text(
              words.body,
              style: TextStyle(
                fontSize: words.body.length > 26 ? 44 : 56,
                color: WxColors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.4,
                height: 1.05,
              ),
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: stageB,
            child: Text(
              'swipe to begin',
              style: TextStyle(
                fontSize: 11,
                color: WxColors.textMuted.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _moodLabel(WeekMood m) {
    switch (m) {
      case WeekMood.calm:
        return 'CALM';
      case WeekMood.protected:
        return 'PROTECTED';
      case WeekMood.recovering:
        return 'RECOVERING';
      case WeekMood.fragmented:
        return 'FRAGMENTED';
      case WeekMood.drifting:
        return 'DRIFTING';
      case WeekMood.heavy:
        return 'HEAVY';
      case WeekMood.chaotic:
        return 'CHAOTIC';
    }
  }
}

class _SplitSentence {
  final String lead;
  final String body;
  const _SplitSentence(this.lead, this.body);
}

_SplitSentence _splitForDrama(String s) {
  // Heuristic: split into "YOU'VE BEEN" / "DRIFTING" style if possible.
  final lower = s.toLowerCase();
  if (lower.startsWith('this week ')) {
    return _SplitSentence(
        'THIS WEEK', s.substring('this week '.length).trim().toUpperCase());
  }
  if (lower.startsWith('your nights ')) {
    return _SplitSentence('YOUR NIGHTS',
        s.substring('your nights '.length).trim().toUpperCase());
  }
  if (lower.startsWith('you\'re ')) {
    return _SplitSentence(
        'YOU\'RE', s.substring('you\'re '.length).trim().toUpperCase());
  }
  if (lower.startsWith('you ')) {
    return _SplitSentence(
        'YOU', s.substring(4).trim().toUpperCase());
  }
  if (lower.startsWith('a ')) {
    return _SplitSentence('A', s.substring(2).trim().toUpperCase());
  }
  return _SplitSentence('THIS WEEK', s.toUpperCase());
}

// ----------------------------------------------------------------------------
// Core story scene — keep the heroline + trend chart. One hero visualization.
// ----------------------------------------------------------------------------

class _CoreStoryScene extends StatelessWidget {
  const _CoreStoryScene({
    required this.story,
    required this.last7Days,
    required this.previous7Days,
    required this.palette,
    required this.entry,
  });
  final CoreStory story;
  final List<DailyStats> last7Days;
  final List<DailyStats> previous7Days;
  final _MoodPalette palette;
  final double entry;

  @override
  Widget build(BuildContext context) {
    final tone = _toneColor(story.tone, palette);
    final eased = Curves.easeOut.transform(entry.clamp(0, 1));
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        media.padding.top + 80,
        24,
        media.padding.bottom + 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: eased,
            child: Text(
              'THE CORE STORY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: tone,
                letterSpacing: 2.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Opacity(
            opacity: eased,
            child: Transform.translate(
              offset: Offset(0, (1 - eased) * 12),
              child: Text(
                story.headline,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _StoryLine(label: 'EVIDENCE', text: story.evidence, color: tone),
          const SizedBox(height: 14),
          _StoryLine(
              label: 'WHY', text: story.causality, color: WxColors.textMuted),
          const SizedBox(height: 14),
          _StoryLine(
              label: 'VS LAST WEEK',
              text: story.comparison,
              color: WxColors.textMuted),
          const Spacer(),
          Opacity(
            opacity: eased,
            child: SizedBox(
              height: 110,
              child: CustomPaint(
                painter: _TrendPainter(
                  current:
                      last7Days.map((d) => d.screenTime.inMinutes).toList(),
                  previous: previous7Days
                      .map((d) => d.screenTime.inMinutes)
                      .toList(),
                  maxValue: <int>[
                    ...last7Days.map((d) => d.screenTime.inMinutes),
                    ...previous7Days.map((d) => d.screenTime.inMinutes),
                  ].fold<int>(60, (a, b) => b > a ? b : a),
                  color: palette.glow,
                  progress: eased,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryLine extends StatelessWidget {
  const _StoryLine({
    required this.label,
    required this.text,
    required this.color,
  });
  final String label;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1.6,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: WxColors.textSecondary,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// Contradiction rupture — the unforgettable moment. Split-screen, opposing
// motion, broken layout.
// ----------------------------------------------------------------------------

class _ContradictionRupture extends StatelessWidget {
  const _ContradictionRupture({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(entry.clamp(0, 1));
    final jitter = (1 - eased) * 8.0;
    final dx = math.sin(eased * 26) * jitter;
    final media = MediaQuery.of(context);

    final parts = beat.headline.split(',');
    final left = parts.isNotEmpty ? parts[0].trim() : beat.headline;
    final right = parts.length > 1
        ? parts.sublist(1).join(',').trim().replaceAll(RegExp(r'^\.|\.$'), '')
        : null;

    return Stack(
      children: <Widget>[
        // Top-half band — drifts left.
        Positioned(
          top: 0,
          left: dx,
          right: -dx,
          height: media.size.height / 2 + 4,
          child: ClipRect(
            child: Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.fromLTRB(
                  24, media.padding.top + 80, 24, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    WxColors.crimson.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'CONTRADICTION',
                    style: TextStyle(
                      fontSize: 10,
                      color: WxColors.crimson.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    left.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: WxColors.textPrimary,
                      letterSpacing: -0.6,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Hard slash dividing the screen — the rupture.
        Positioned(
          top: media.size.height / 2 - 1,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: eased,
            child: Container(
              height: 2,
              color: WxColors.crimson.withValues(alpha: 0.55),
            ),
          ),
        ),
        // Bottom-half band — drifts right.
        Positioned(
          bottom: 0,
          left: -dx,
          right: dx,
          height: media.size.height / 2 + 4,
          child: ClipRect(
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(
                  24, 24, 24, media.padding.bottom + 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: <Color>[
                    WxColors.crimson.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (right != null) ...<Widget>[
                    Text(
                      right.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: WxColors.textPrimary,
                        letterSpacing: -0.6,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (beat.body != null)
                    Opacity(
                      opacity: eased,
                      child: Text(
                        beat.body!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: WxColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// Slip — downward collapse.
// ----------------------------------------------------------------------------

class _SlipCollapse extends StatelessWidget {
  const _SlipCollapse({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;
  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeInCubic.transform(entry.clamp(0, 1));
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        media.padding.top + 100,
        24,
        media.padding.bottom + 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SceneLabel(label: beat.label, color: WxColors.crimson),
          const SizedBox(height: 24),
          Transform.translate(
            offset: Offset(0, -40 + eased * 40),
            child: Opacity(
              opacity: eased,
              child: Text(
                beat.headline,
                style: WxTypography.mono(size: 38, weight: FontWeight.w800),
              ),
            ),
          ),
          if (beat.body != null) ...<Widget>[
            const SizedBox(height: 20),
            Opacity(
              opacity: eased,
              child: Text(
                beat.body!,
                style: const TextStyle(
                  fontSize: 16,
                  color: WxColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const Spacer(),
          // Subtle collapsing bar that mirrors the metaphor.
          Opacity(
            opacity: eased,
            child: SizedBox(
              height: 80,
              child: CustomPaint(
                painter: _CollapsePainter(t: eased),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsePainter extends CustomPainter {
  _CollapsePainter({required this.t});
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = WxColors.crimson.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final n = 22;
    for (int i = 0; i < n; i++) {
      final x = (i / (n - 1)) * size.width;
      final fall = math.pow(i / n, 1.6) * t;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height * fall),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CollapsePainter old) => old.t != t;
}

// ----------------------------------------------------------------------------
// Recovery — expansion from center.
// ----------------------------------------------------------------------------

class _RecoveryExpand extends StatelessWidget {
  const _RecoveryExpand({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;
  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(entry.clamp(0, 1));
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        media.padding.top + 100,
        24,
        media.padding.bottom + 60,
      ),
      child: Stack(
        children: <Widget>[
          // Expanding ring backdrop.
          Center(
            child: Container(
              width: 60 + eased * (media.size.width - 100),
              height: 60 + eased * (media.size.width - 100),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: WxColors.accent.withValues(alpha: 0.30 * (1 - eased * 0.4)),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SceneLabel(label: beat.label, color: WxColors.accent),
              const SizedBox(height: 24),
              Opacity(
                opacity: eased,
                child: Text(
                  beat.headline,
                  style:
                      WxTypography.mono(size: 28, weight: FontWeight.w800),
                ),
              ),
              if (beat.body != null) ...<Widget>[
                const SizedBox(height: 16),
                Opacity(
                  opacity: eased,
                  child: Text(
                    beat.body!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: WxColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Memory — delayed parallax. Background moves slower than foreground.
// ----------------------------------------------------------------------------

class _MemoryParallax extends StatelessWidget {
  const _MemoryParallax({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;
  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(entry.clamp(0, 1));
    final delayed = (entry < 0.4 ? 0.0 : (entry - 0.4) / 0.6);
    final delayedEased = Curves.easeOut.transform(delayed.clamp(0.0, 1.0));
    final media = MediaQuery.of(context);
    return Stack(
      children: <Widget>[
        // Background layer — slow, large, muted text.
        Positioned(
          left: 8,
          right: 8,
          bottom: media.size.height * 0.45,
          child: Opacity(
            opacity: 0.10 * eased,
            child: Transform.translate(
              offset: Offset(0, (1 - eased) * 20),
              child: Text(
                'BEFORE',
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  color: palette.shadow,
                  letterSpacing: -3,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
        // Foreground layer — delayed.
        Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            media.padding.top + 100,
            24,
            media.padding.bottom + 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SceneLabel(label: beat.label, color: palette.glow),
              const Spacer(),
              Opacity(
                opacity: delayedEased,
                child: Transform.translate(
                  offset: Offset(0, (1 - delayedEased) * 16),
                  child: Text(
                    beat.headline,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: WxColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              if (beat.body != null) ...<Widget>[
                const SizedBox(height: 16),
                Opacity(
                  opacity: delayedEased,
                  child: Text(
                    beat.body!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: WxColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              const Spacer(flex: 2),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// Prediction — forward drift. Words slide in from the right.
// ----------------------------------------------------------------------------

class _PredictionDrift extends StatelessWidget {
  const _PredictionDrift({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;
  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(entry.clamp(0, 1));
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        media.padding.top + 100,
        24,
        media.padding.bottom + 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SceneLabel(label: 'NEXT', color: palette.glow),
          const Spacer(),
          Opacity(
            opacity: eased,
            child: Transform.translate(
              offset: Offset((1 - eased) * 80, 0),
              child: Text(
                beat.headline,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Opacity(
            opacity: eased,
            child: Container(
              height: 1,
              width: 40 + eased * 120,
              color: palette.glow.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Hidden chapter (Sunday / midnight / calm-streak / monthly) — full-bleed,
// quiet, distinct typography.
// ----------------------------------------------------------------------------

class _HiddenChapterScene extends StatelessWidget {
  const _HiddenChapterScene({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;
  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOut.transform(entry.clamp(0, 1));
    final media = MediaQuery.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(
        28,
        media.padding.top + 80,
        28,
        media.padding.bottom + 60,
      ),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.4,
          colors: <Color>[
            palette.glow.withValues(alpha: 0.20),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: eased,
            child: Text(
              '·  ${beat.label}  ·',
              style: TextStyle(
                fontSize: 11,
                color: palette.glow,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.0,
              ),
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: eased,
            child: Text(
              beat.headline,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: WxColors.textPrimary,
                letterSpacing: -1.0,
                height: 1.1,
              ),
            ),
          ),
          if (beat.body != null) ...<Widget>[
            const SizedBox(height: 18),
            Opacity(
              opacity: eased,
              child: Text(
                beat.body!,
                style: const TextStyle(
                  fontSize: 16,
                  color: WxColors.textSecondary,
                  height: 1.55,
                ),
              ),
            ),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Arc — recurring pattern. Edge-aligned right.
// ----------------------------------------------------------------------------

class _ArcScene extends StatelessWidget {
  const _ArcScene({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;
  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(entry.clamp(0, 1));
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        media.padding.top + 100,
        24,
        media.padding.bottom + 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _SceneLabel(label: beat.label, color: palette.glow),
          const Spacer(),
          Opacity(
            opacity: eased,
            child: Text(
              beat.headline,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: WxColors.textPrimary,
                letterSpacing: -0.4,
                height: 1.25,
              ),
            ),
          ),
          if (beat.body != null) ...<Widget>[
            const SizedBox(height: 14),
            Opacity(
              opacity: eased,
              child: Text(
                beat.body!,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  color: WxColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const Spacer(),
          // Three small arc dots — visual continuity sigil.
          Opacity(
            opacity: eased,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < 3; i++) ...<Widget>[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.glow.withValues(alpha: 0.5 + i * 0.16),
                    ),
                  ),
                  if (i < 2) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Default beat — used for today / thisWeek / pattern / night / trend.
// ----------------------------------------------------------------------------

class _DefaultBeatScene extends StatelessWidget {
  const _DefaultBeatScene({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;
  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOut.transform(entry.clamp(0, 1));
    final media = MediaQuery.of(context);
    final isNumeric = beat.kind == NarrativeBeatKind.today ||
        beat.kind == NarrativeBeatKind.thisWeek;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        media.padding.top + 100,
        24,
        media.padding.bottom + 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SceneLabel(
              label: beat.label, color: _toneColor(beat.tone, palette)),
          const Spacer(),
          Opacity(
            opacity: eased,
            child: Transform.translate(
              offset: Offset(0, (1 - eased) * 10),
              child: Text(
                beat.headline,
                style: WxTypography.mono(
                  size: isNumeric ? 64 : 28,
                  weight: FontWeight.w800,
                ).copyWith(height: 1.1),
              ),
            ),
          ),
          if (beat.body != null) ...<Widget>[
            const SizedBox(height: 16),
            Opacity(
              opacity: eased,
              child: Text(
                beat.body!,
                style: const TextStyle(
                  fontSize: 16,
                  color: WxColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (beat.footnote != null) ...<Widget>[
            const SizedBox(height: 12),
            Opacity(
              opacity: eased,
              child: Text(
                beat.footnote!,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: _toneColor(beat.tone, palette).withValues(alpha: 0.8),
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Ritual — almost empty.
// ----------------------------------------------------------------------------

class _RitualScene extends StatelessWidget {
  const _RitualScene({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;
  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOut.transform(entry.clamp(0, 1));
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        32,
        media.padding.top + 120,
        32,
        media.padding.bottom + 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: eased,
            child: Text(
              'RITUAL',
              style: TextStyle(
                fontSize: 11,
                color: palette.glow,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.0,
              ),
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: eased,
            child: Text(
              beat.headline,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: WxColors.textPrimary,
                height: 1.35,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// ============================================================================
// Shared bits
// ============================================================================

class _SceneLabel extends StatelessWidget {
  const _SceneLabel({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.5,
        color: color,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.6,
      ),
    );
  }
}

// ============================================================================
// Trend painter (used in Core Story)
// ============================================================================

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.current,
    required this.previous,
    required this.maxValue,
    required this.color,
    required this.progress,
  });
  final List<int> current;
  final List<int> previous;
  final int maxValue;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (current.isEmpty) return;
    final guide = Paint()
      ..color = WxColors.surface3.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 1),
        Offset(size.width, size.height - 1), guide);

    Path buildPath(List<int> series, double t) {
      final p = Path();
      if (series.isEmpty) return p;
      final dx = size.width / (series.length - 1).clamp(1, 999);
      final visibleCount = (series.length * t).clamp(0, series.length).toInt();
      for (int i = 0; i < visibleCount; i++) {
        final x = i * dx;
        final y = size.height -
            (series[i] / maxValue).clamp(0.0, 1.0) * (size.height - 6);
        if (i == 0) {
          p.moveTo(x, y);
        } else {
          p.lineTo(x, y);
        }
      }
      return p;
    }

    if (previous.isNotEmpty) {
      final ghostPaint = Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(buildPath(previous, 1), ghostPaint);
    }

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          color.withValues(alpha: 0.32),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);
    final path = buildPath(current, progress);
    final closed = Path.from(path)
      ..lineTo(size.width * progress, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(closed, fill);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);

    final dot = Paint()..color = color;
    final dx = size.width / (current.length - 1).clamp(1, 999);
    final visible = (current.length * progress).clamp(0, current.length).toInt();
    for (int i = 0; i < visible; i++) {
      final x = i * dx;
      final y = size.height -
          (current[i] / maxValue).clamp(0.0, 1.0) * (size.height - 6);
      canvas.drawCircle(Offset(x, y), 2.4, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.current != current ||
      old.previous != previous ||
      old.maxValue != maxValue ||
      old.color != color ||
      old.progress != progress;
}

// ============================================================================
// Mood palette + ambient backdrop
// ============================================================================

class _MoodPalette {
  final Color glow;
  final Color shadow;
  const _MoodPalette({required this.glow, required this.shadow});
}

const Map<WeekMood, _MoodPalette> _palettesByMood = <WeekMood, _MoodPalette>{
  WeekMood.calm: _MoodPalette(glow: WxColors.accent, shadow: WxColors.cyan),
  WeekMood.protected:
      _MoodPalette(glow: WxColors.accent, shadow: WxColors.accentDeep),
  WeekMood.recovering:
      _MoodPalette(glow: WxColors.cyan, shadow: WxColors.accent),
  WeekMood.fragmented:
      _MoodPalette(glow: WxColors.amber, shadow: WxColors.violet),
  WeekMood.drifting:
      _MoodPalette(glow: WxColors.violet, shadow: WxColors.cyan),
  WeekMood.heavy:
      _MoodPalette(glow: WxColors.amber, shadow: WxColors.crimson),
  WeekMood.chaotic:
      _MoodPalette(glow: WxColors.crimson, shadow: WxColors.amber),
};

Color _toneColor(NarrativeTone tone, _MoodPalette palette) {
  switch (tone) {
    case NarrativeTone.warm:
      return WxColors.accent;
    case NarrativeTone.caution:
      return WxColors.amber;
    case NarrativeTone.warning:
      return WxColors.crimson;
    case NarrativeTone.triumph:
      return WxColors.accent;
    case NarrativeTone.neutral:
      return palette.glow;
  }
}

/// Multi-frequency ambient drift. The orb path is the sum of three sin/cos
/// pairs at incommensurate frequency ratios — it never exactly closes, even
/// though the [t] cycle does. The interface stops feeling animated and starts
/// feeling weather-like.
class _AmbientPainter extends CustomPainter {
  _AmbientPainter({
    required this.t,
    required this.palette,
    required this.mood,
  });
  final double t;
  final _MoodPalette palette;
  final WeekMood mood;

  // Incommensurate ratios — sqrt(2), sqrt(3), e — so the Lissajous figure
  // doesn't exactly close after one [t] cycle.
  static const double _r1 = 1.0;
  static const double _r2 = 1.41421356;
  static const double _r3 = 1.73205081;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final intensity = _intensityFor(mood);
    final theta = t * 2 * math.pi;

    // Micro-jitter: faint high-frequency components break the mathematical
    // smoothness. Should feel like something moved that shouldn't have, not
    // like animation. Stops the orb from feeling like a screensaver.
    final jitter1x = 0.012 * math.sin(theta * 7.3 + 1.1);
    final jitter1y = 0.010 * math.cos(theta * 6.7 + 0.5);
    final cx1 = size.width *
        (0.5 +
            0.28 * math.cos(theta * _r1) +
            0.06 * math.sin(theta * _r2 + 0.7) +
            jitter1x);
    final cy1 = size.height *
        (0.22 +
            0.06 * math.sin(theta * _r2) +
            0.04 * math.cos(theta * _r3) +
            jitter1y);
    
    final r1 = size.width * 0.85;
    final c1 = palette.glow.withValues(alpha: 0.10 + intensity * 0.06);
    final blob1 = Paint()
      ..shader = RadialGradient(
        colors: <Color>[c1, c1.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: Offset(cx1, cy1), radius: r1));
    canvas.drawCircle(Offset(cx1, cy1), r1, blob1);

    final jitter2x = 0.014 * math.sin(theta * 5.9 + 2.3);
    final jitter2y = 0.009 * math.cos(theta * 8.1 + 1.7);
    final cx2 = size.width *
        (0.5 +
            0.30 * math.cos(theta * _r1 + math.pi) +
            0.05 * math.sin(theta * _r3 + 1.2) +
            jitter2x);
    final cy2 = size.height *
        (0.76 +
            0.07 * math.sin(theta * _r3 + 0.4) +
            0.03 * math.cos(theta * _r2 + 0.9) +
            jitter2y);

    final r2 = size.width * 0.90;
    final c2 = palette.shadow.withValues(alpha: 0.08 + intensity * 0.05);
    final blob2 = Paint()
      ..shader = RadialGradient(
        colors: <Color>[c2, c2.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: Offset(cx2, cy2), radius: r2));
    canvas.drawCircle(Offset(cx2, cy2), r2, blob2);

    // Third faint blob — slow, large, opposite phase. Adds atmospheric depth
    // without making motion feel busy.
    final cx3 = size.width *
        (0.5 + 0.18 * math.sin(theta * _r2 * 0.5 + 2.1));
    final cy3 = size.height *
        (0.5 + 0.22 * math.cos(theta * _r3 * 0.5 + 1.3));

    final r3 = size.width * 1.05;
    final c3 = palette.glow.withValues(alpha: 0.04 + intensity * 0.03);
    final blob3 = Paint()
      ..shader = RadialGradient(
        colors: <Color>[c3, c3.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: Offset(cx3, cy3), radius: r3));
    canvas.drawCircle(Offset(cx3, cy3), r3, blob3);
  }

  double _intensityFor(WeekMood m) {
    switch (m) {
      case WeekMood.calm:
      case WeekMood.protected:
        return 0.10;
      case WeekMood.recovering:
        return 0.25;
      case WeekMood.drifting:
        return 0.40;
      case WeekMood.fragmented:
        return 0.55;
      case WeekMood.heavy:
        return 0.75;
      case WeekMood.chaotic:
        return 0.95;
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter old) =>
      old.t != t || old.palette != palette || old.mood != mood;
}

// ============================================================================
// Threshold opener — the mode-entry choreography. Emerges from beneath where
// the bottom nav was, expands to fill the screen, then clears.
// ============================================================================

class _ThresholdOpener extends StatelessWidget {
  const _ThresholdOpener({
    required this.progress,
    required this.palette,
    required this.mood,
  });
  final double progress; // 0..1
  final _MoodPalette palette;
  final WeekMood mood;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Three overlapping eased segments.
    final dim = (1.0 - progress).clamp(0.0, 1.0); // 1 → 0 (opens up)
    final orb = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final labelStart = ((progress - 0.20) / 0.40).clamp(0.0, 1.0);
    final labelOut = ((progress - 0.75) / 0.20).clamp(0.0, 1.0);
    final label = labelStart * (1.0 - labelOut);
    final orbCenterY = media.size.height * (0.95 - orb * 0.45);
    final orbRadius =
        20.0 + orb * (media.size.width * 0.55);
    return Stack(
      children: <Widget>[
        // Deepening void.
        Positioned.fill(
          child: ColoredBox(
            color: WxColors.void_.withValues(alpha: 0.45 + dim * 0.55),
          ),
        ),
        // Emerging orb.
        Positioned(
          left: 0,
          right: 0,
          top: orbCenterY - orbRadius,
          height: orbRadius * 2,
          child: Center(
            child: Container(
              width: orbRadius * 2,
              height: orbRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    palette.glow.withValues(alpha: 0.55 * (1.0 - orb * 0.6)),
                    palette.glow.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Mood label briefly visible, then dissolves into the scene player.
        Positioned(
          left: 0,
          right: 0,
          top: media.padding.top + 100,
          child: Opacity(
            opacity: label,
            child: Center(
              child: Text(
                _moodWord(mood),
                style: TextStyle(
                  fontSize: 11,
                  color: palette.glow,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _moodWord(WeekMood m) {
    switch (m) {
      case WeekMood.calm:
        return 'CALM';
      case WeekMood.protected:
        return 'PROTECTED';
      case WeekMood.recovering:
        return 'RECOVERING';
      case WeekMood.fragmented:
        return 'FRAGMENTED';
      case WeekMood.drifting:
        return 'DRIFTING';
      case WeekMood.heavy:
        return 'HEAVY';
      case WeekMood.chaotic:
        return 'CHAOTIC';
    }
  }
}

// ============================================================================
// Fog-emergence — applied on top of every scene's own entry. Adds a luminance
// ramp + barely-perceptible scale so transitions feel atmospheric rather than
// mechanical.
// ============================================================================

class _FogEmerge extends StatelessWidget {
  const _FogEmerge({required this.progress, required this.child});
  final double progress; // 0..1 — same as scene's own entry
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final scale = 0.985 + 0.015 * t;
    final dim = (1.0 - t) * 0.55;
    return Stack(
      children: <Widget>[
        Transform.scale(scale: scale, child: child),
        if (dim > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.1),
                    radius: 1.4,
                    colors: <Color>[
                      Colors.transparent,
                      WxColors.void_.withValues(alpha: dim * 0.6),
                    ],
                    stops: const <double>[0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// Landmark + Motif — earned, persistent moments. Distinct full-bleed layouts.
// ============================================================================

class _LandmarkScene extends StatelessWidget {
  const _LandmarkScene({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;
  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(entry.clamp(0, 1));
    final media = MediaQuery.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 1.2,
          colors: <Color>[
            WxColors.accent.withValues(alpha: 0.18),
            Colors.transparent,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        28,
        media.padding.top + 90,
        28,
        media.padding.bottom + 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: eased,
            child: const Text(
              '·  L A N D M A R K  ·',
              style: TextStyle(
                fontSize: 11,
                color: WxColors.accent,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.6,
              ),
            ),
          ),
          const Spacer(),
          // Subtle ring sigil.
          Opacity(
            opacity: eased * 0.7,
            child: Container(
              width: 80 + eased * 8,
              height: 80 + eased * 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: WxColors.accent.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Opacity(
            opacity: eased,
            child: Text(
              beat.headline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: WxColors.textPrimary,
                letterSpacing: -0.6,
                height: 1.2,
              ),
            ),
          ),
          if (beat.body != null) ...<Widget>[
            const SizedBox(height: 14),
            Opacity(
              opacity: eased * 0.85,
              child: Text(
                beat.body!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: WxColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

/// Stable color per named motif. Recurrences must look identical across
/// weeks so the user recognizes them by sight.
const Map<String, Color> _motifColors = <String, Color>{
  'late_drift': WxColors.violet,
  'midnight_return': WxColors.crimson,
  'instagram_spiral': WxColors.amber,
};

class _MotifScene extends StatelessWidget {
  const _MotifScene({
    required this.beat,
    required this.palette,
    required this.entry,
  });
  final NarrativeBeat beat;
  final _MoodPalette palette;
  final double entry;
  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(entry.clamp(0, 1));
    final media = MediaQuery.of(context);
    final accent = _motifColors[beat.motifKey ?? ''] ?? palette.glow;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        28,
        media.padding.top + 100,
        28,
        media.padding.bottom + 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: eased,
            child: Text(
              'A NAMED PATTERN',
              style: TextStyle(
                fontSize: 10.5,
                color: accent,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.0,
              ),
            ),
          ),
          const Spacer(),
          // Sigil dots representing recurrence — drift in.
          Opacity(
            opacity: eased,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < 5; i++) ...<Widget>[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(
                          alpha: 0.25 + (i * 0.15) * eased),
                    ),
                  ),
                  if (i < 4) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Opacity(
            opacity: eased,
            child: Transform.translate(
              offset: Offset(0, (1 - eased) * 12),
              child: Text(
                beat.headline,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: WxColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
              ),
            ),
          ),
          if (beat.body != null) ...<Widget>[
            const SizedBox(height: 16),
            Opacity(
              opacity: eased * 0.85,
              child: Text(
                beat.body!,
                style: const TextStyle(
                  fontSize: 15,
                  color: WxColors.textSecondary,
                  height: 1.55,
                ),
              ),
            ),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// ============================================================================
// Breath — structural silence. No text, no progression cue, no haptic. Just
// the ambient layer rendered behind. Forces the user to absorb.
// ============================================================================

class _BreathScene extends StatelessWidget {
  const _BreathScene();
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
