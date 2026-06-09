import 'package:equatable/equatable.dart';

import '../models/app_category.dart';
import '../models/daily_stats.dart';
import '../models/personality_type.dart';
import 'behavior_engine.dart';
import 'continuous_usage_engine.dart';
import 'sleep_engine.dart';

/// Mood label for the week. Drives the UI's motion temperament — calm gets
/// slow gradients and large negative space; chaotic gets shorter transitions
/// and harsher edges.
enum WeekMood {
  calm,
  protected,
  recovering,
  fragmented,
  drifting,
  heavy,
  chaotic,
}

class NarrativeBeat extends Equatable {
  final NarrativeBeatKind kind;
  final String label; // "PATTERN", "SLIP", "NIGHT" — caps; the chapter spine.
  final String headline; // short, sentence-shaped, observational.
  final String? body; // supporting context, may be longer.
  final String? footnote; // tiny, often a number reference.
  final NarrativeTone tone;

  /// Stable identity for named motifs ("late_drift", "midnight_return").
  /// Lets the UI render the same color/sigil every time the motif returns,
  /// which is what makes recurring patterns feel familiar rather than fresh.
  final String? motifKey;

  const NarrativeBeat({
    required this.kind,
    required this.label,
    required this.headline,
    this.body,
    this.footnote,
    this.tone = NarrativeTone.neutral,
    this.motifKey,
  });

  @override
  List<Object?> get props => <Object?>[
    kind,
    label,
    headline,
    body,
    footnote,
    tone,
    motifKey,
  ];
}

enum NarrativeBeatKind {
  today,
  thisWeek,
  pattern,
  slip,
  recovery,
  night,
  trend,
  contradiction,
  memory,
  prediction,
  ritual,
  // Hidden / conditional chapters — only appear when conditions are met.
  sunday,
  afterMidnight,
  calmStreak,
  monthly,
  arc,
  // Persistent narrative memory — landmarks (records) and named motifs.
  landmark,
  motif,

  /// Structural silence. No text, no progression cue. The screen renders just
  /// the ambient orb for ~1.6s. Inserted after heavy beats so the user has
  /// space to absorb. The opposite of communication.
  breath,
}

enum NarrativeTone { neutral, warm, caution, warning, triumph }

class NarrativeWeek extends Equatable {
  /// One sentence — the identity hero. Replaces composite scores entirely.
  final String identitySentence;

  /// Mood that drives ambient motion + palette in the UI.
  final WeekMood mood;

  /// One dominant story for the week, with cause/effect/comparison/ritual.
  final CoreStory core;

  /// The vertical narrative spine. Order is meaningful — render top-to-bottom.
  final List<NarrativeBeat> beats;

  /// Optional forward-looking guess. Null when we don't have enough confidence.
  final String? prediction;

  const NarrativeWeek({
    required this.identitySentence,
    required this.mood,
    required this.core,
    required this.beats,
    required this.prediction,
  });

  @override
  List<Object?> get props => <Object?>[
    identitySentence,
    mood,
    core,
    beats,
    prediction,
  ];
}

class CoreStory extends Equatable {
  final String headline; // "Instagram consumed 38% of your distracted time."
  final String evidence; // the data line.
  final String causality; // why this is happening (best-effort).
  final String comparison; // delta vs last week / baseline.
  final String ritual; // ONE actionable observation, not a directive.
  final NarrativeTone tone;

  const CoreStory({
    required this.headline,
    required this.evidence,
    required this.causality,
    required this.comparison,
    required this.ritual,
    required this.tone,
  });

  @override
  List<Object?> get props => <Object?>[
    headline,
    evidence,
    causality,
    comparison,
    ritual,
    tone,
  ];
}

/// Synthesizes the week into a single narrative tree. All thresholds and
/// templates live here so the screen can stay dumb and reactive.
class NarrativeIntelligenceEngine {
  const NarrativeIntelligenceEngine();

  NarrativeWeek synthesize({
    required DailyStats today,
    required List<DailyStats> last7Days,
    required List<DailyStats> previous7Days,
    required BehaviorReport behavior,
    required SleepReport sleep,
    required ContinuousUsageReport continuous,
    required PersonalityType personality,

    /// 28-day window (oldest → newest). Powers continuity arcs and hidden
    /// chapters. Pass empty list if not yet available — engine degrades
    /// gracefully.
    List<DailyStats> last28Days = const <DailyStats>[],

    /// Local "now" — used for time-gated hidden scenes (after-midnight, etc).
    /// Engine consumers can stub this in tests.
    DateTime? now,

    /// Beats sourced from persistent narrative memory (landmarks + motifs).
    /// Synthesizer just slots them in — detection lives in the memory engine.
    List<NarrativeBeat> memoryBeats = const <NarrativeBeat>[],
  }) {
    final clock = now ?? DateTime.now();
    final mood = _classifyMood(
      last7Days: last7Days,
      previous7Days: previous7Days,
      behavior: behavior,
      sleep: sleep,
      continuous: continuous,
    );

    final identity = _identitySentence(
      mood: mood,
      last7Days: last7Days,
      previous7Days: previous7Days,
      behavior: behavior,
      sleep: sleep,
    );

    final core = _coreStory(
      last7Days: last7Days,
      previous7Days: previous7Days,
      behavior: behavior,
      sleep: sleep,
    );

    // ---- Build the *candidate* set. Composition decides what survives. ----
    final candidates = <NarrativeBeat>[];
    candidates.add(_todayBeat(today, last7Days));
    candidates.add(_thisWeekBeat(last7Days, previous7Days));

    final pattern = _patternBeat(last7Days, behavior);
    if (pattern != null) candidates.add(pattern);

    final slip = _slipBeat(last7Days, behavior, continuous);
    if (slip != null) candidates.add(slip);

    final recovery = _recoveryBeat(continuous, last7Days);
    if (recovery != null) candidates.add(recovery);

    final night = _nightBeat(sleep, last7Days);
    if (night != null) candidates.add(night);

    final trend = _trendBeat(last7Days, previous7Days);
    if (trend != null) candidates.add(trend);

    final contra = _contradictionBeat(
      last7Days: last7Days,
      previous7Days: previous7Days,
      behavior: behavior,
      sleep: sleep,
    );
    if (contra != null) candidates.add(contra);

    final memory = _memoryBeat(last7Days, previous7Days);
    if (memory != null) candidates.add(memory);

    candidates.addAll(_continuityArcs(last28Days));

    final prediction = _prediction(last7Days, previous7Days, behavior);
    if (prediction != null) {
      candidates.add(
        NarrativeBeat(
          kind: NarrativeBeatKind.prediction,
          label: 'NEXT',
          headline: prediction,
          tone: NarrativeTone.caution,
        ),
      );
    }

    candidates.addAll(
      _hiddenChapters(now: clock, last28Days: last28Days, last7Days: last7Days),
    );

    // Persistent narrative memory beats are always preserved — they're rare
    // and earned. The mood filter never drops them.
    candidates.addAll(memoryBeats);

    // ---- Mood composition: filter the candidate set by mood. ----
    var beats = _composeForMood(candidates, mood, memoryBeats);

    // ---- Adaptive restraint: when nothing meaningful happened, the app
    // should not perform significance. A genuinely quiet day with no memory
    // beats earns just identity + today + ritual. The week speaks with its
    // length, not with its narration.
    if (_isQuietDay(today, last7Days) && memoryBeats.isEmpty) {
      beats = beats
          .where(
            (b) =>
                b.kind == NarrativeBeatKind.today ||
                b.kind == NarrativeBeatKind.thisWeek ||
                b.kind == NarrativeBeatKind.calmStreak ||
                b.kind == NarrativeBeatKind.afterMidnight,
          )
          .toList();
    }

    // ---- Voice register: heavy / chaotic / fragmented weeks drop the
    // poetry and become plainspoken. The contrast is the credibility.
    beats = _applyVoice(beats, mood);

    // ---- Structural silence: insert breath beats after the heaviest moments
    // so the user has unspoken space to absorb. No text, no haptic, no count.
    beats = _intersperseBreath(beats);

    // RITUAL — one quiet, specific suggestion. Always last.
    beats.add(
      NarrativeBeat(
        kind: NarrativeBeatKind.ritual,
        label: 'RITUAL',
        headline: core.ritual,
        body: 'Try this for a few days. Notice what changes.',
        tone: NarrativeTone.warm,
      ),
    );

    return NarrativeWeek(
      identitySentence: identity,
      mood: mood,
      core: core,
      beats: beats,
      prediction: prediction,
    );
  }

  // ----------------- mood -----------------

  WeekMood _classifyMood({
    required List<DailyStats> last7Days,
    required List<DailyStats> previous7Days,
    required BehaviorReport behavior,
    required SleepReport sleep,
    required ContinuousUsageReport continuous,
  }) {
    final weekMin = _avgMinutes(last7Days);
    final prevMin = _avgMinutes(previous7Days);
    final delta = weekMin - prevMin;

    final consistency = sleep.bedtimeConsistency; // 0..100
    final binges = continuous.totalBinges;
    final overload = behavior.cognitiveOverloadScore; // 0..100, higher = worse
    final productivity = behavior.productivityScore; // 0..100, higher = better

    if (overload >= 70 || binges >= 6) return WeekMood.chaotic;
    if (weekMin > 360 && binges >= 3) return WeekMood.heavy;
    if (consistency < 40) return WeekMood.fragmented;
    if (delta < -25) return WeekMood.recovering;
    if (productivity >= 65 && overload < 40) return WeekMood.protected;
    if (weekMin > 240 && delta > 15) return WeekMood.drifting;
    return WeekMood.calm;
  }

  // ----------------- identity sentence -----------------

  String _identitySentence({
    required WeekMood mood,
    required List<DailyStats> last7Days,
    required List<DailyStats> previous7Days,
    required BehaviorReport behavior,
    required SleepReport sleep,
  }) {
    switch (mood) {
      case WeekMood.calm:
        return 'A quieter week than most.';
      case WeekMood.protected:
        return 'You protected your focus.';
      case WeekMood.recovering:
        return 'You\'re recovering attention.';
      case WeekMood.fragmented:
        return 'This week was fragmented.';
      case WeekMood.drifting:
        return 'Your nights are slowly drifting later.';
      case WeekMood.heavy:
        return 'This week belonged to distraction.';
      case WeekMood.chaotic:
        return 'A loud, scattered week.';
    }
  }

  // ----------------- core story -----------------

  CoreStory _coreStory({
    required List<DailyStats> last7Days,
    required List<DailyStats> previous7Days,
    required BehaviorReport behavior,
    required SleepReport sleep,
  }) {
    // Pick the dominant distracting app of the week.
    final perApp = <String, _AppAgg>{};
    for (final d in last7Days) {
      for (final a in d.apps) {
        if (!a.category.isDistracting) continue;
        final agg = perApp.putIfAbsent(
          a.packageName,
          () => _AppAgg(name: a.displayName, category: a.category),
        );
        agg.minutes += a.foreground.inMinutes;
        agg.opens += a.opens;
      }
    }
    final totalDistract = perApp.values.fold<int>(0, (a, b) => a + b.minutes);
    if (perApp.isNotEmpty && totalDistract >= 60) {
      final top = perApp.values.reduce(
        (a, b) => a.minutes >= b.minutes ? a : b,
      );
      final pct = ((top.minutes / totalDistract) * 100).round();
      final delta = _avgMinutes(last7Days) - _avgMinutes(previous7Days);
      final deltaTxt = delta.abs() < 10
          ? 'about the same as last week'
          : delta < 0
          ? '${delta.abs()}m less per day than last week'
          : '$delta m more per day than last week';
      return CoreStory(
        headline: '${top.name} took $pct% of your distracted time this week.',
        evidence: '${_h(top.minutes)} across the week, ${top.opens} opens.',
        causality: top.opens > top.minutes ~/ 5
            ? 'Mostly short, reflexive checks rather than long sessions.'
            : 'Long sessions are doing the damage, not the checks.',
        comparison: 'You\'re $deltaTxt overall.',
        ritual: top.opens > top.minutes ~/ 5
            ? 'Move ${top.name} off your home screen for 3 days. See if the urge fades.'
            : 'Set a 20-minute reset before opening ${top.name} tonight.',
        tone: pct >= 40 ? NarrativeTone.warning : NarrativeTone.caution,
      );
    }

    // Fallback: use peak hour pattern.
    final peakCounts = <int, int>{};
    for (final d in last7Days) {
      final p = d.peakHour;
      if (p != null) peakCounts.update(p, (v) => v + 1, ifAbsent: () => 1);
    }
    if (peakCounts.isNotEmpty) {
      final peak = peakCounts.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      return CoreStory(
        headline: 'Your attention collapses around ${_hourLabel(peak.key)}.',
        evidence: 'That hour was the heaviest on ${peak.value} of 7 days.',
        causality:
            'A daily transition — energy dips, structure fades, scrolling fills the gap.',
        comparison: 'It\'s the most reliable pattern in your week.',
        ritual:
            'Plan one anchor activity for ${_hourLabel(peak.key)} tomorrow.',
        tone: NarrativeTone.caution,
      );
    }

    // Worst-case fallback.
    return const CoreStory(
      headline: 'A quiet week. Nothing dominant.',
      evidence: 'No single app or hour stood out.',
      causality: 'Your usage was diffuse rather than concentrated.',
      comparison: 'That\'s harder to disrupt and harder to fix.',
      ritual: 'Pick one app to put away tonight. Notice what fills the space.',
      tone: NarrativeTone.neutral,
    );
  }

  // ----------------- beats -----------------

  NarrativeBeat _todayBeat(DailyStats today, List<DailyStats> last7Days) {
    final mins = today.screenTime.inMinutes;
    final weekAvg = _avgMinutes(last7Days);
    final delta = mins - weekAvg;
    final pct = weekAvg == 0 ? 0 : ((mins / weekAvg) * 100).round();
    final body = delta.abs() < 10
        ? 'About average for your week.'
        : delta < 0
        ? '${delta.abs()}m below your weekly average.'
        : '$delta m above your weekly average.';
    return NarrativeBeat(
      kind: NarrativeBeatKind.today,
      label: 'TODAY',
      headline: _h(mins),
      body: body,
      footnote: weekAvg == 0 ? null : '$pct% of your weekly average',
      tone: delta < -10 ? NarrativeTone.warm : NarrativeTone.neutral,
    );
  }

  NarrativeBeat _thisWeekBeat(
    List<DailyStats> last7Days,
    List<DailyStats> previous7Days,
  ) {
    final total = last7Days.fold<int>(0, (a, b) => a + b.screenTime.inMinutes);
    final prev = previous7Days.fold<int>(
      0,
      (a, b) => a + b.screenTime.inMinutes,
    );
    final delta = total - prev;
    final body = prev == 0
        ? 'No comparison yet — this is your first full week of data.'
        : delta.abs() < 30
        ? 'Within 30 minutes of last week\'s total.'
        : delta < 0
        ? '${_h(delta.abs())} less than last week.'
        : '${_h(delta)} more than last week.';
    final tone = prev == 0
        ? NarrativeTone.neutral
        : delta < -30
        ? NarrativeTone.triumph
        : delta > 60
        ? NarrativeTone.warning
        : NarrativeTone.neutral;
    return NarrativeBeat(
      kind: NarrativeBeatKind.thisWeek,
      label: 'THIS WEEK',
      headline: _h(total),
      body: body,
      tone: tone,
    );
  }

  NarrativeBeat? _patternBeat(
    List<DailyStats> last7Days,
    BehaviorReport behavior,
  ) {
    // Find the hour-of-day with the strongest distracting weight averaged.
    final hourSum = <int, int>{};
    for (final d in last7Days) {
      d.hourBuckets.forEach((h, dur) {
        hourSum.update(
          h,
          (v) => v + dur.inMinutes,
          ifAbsent: () => dur.inMinutes,
        );
      });
    }
    if (hourSum.isEmpty) return null;
    final peak = hourSum.entries.reduce((a, b) => a.value >= b.value ? a : b);
    if (peak.value < 30) return null;
    final daily = (peak.value / last7Days.length).round();
    return NarrativeBeat(
      kind: NarrativeBeatKind.pattern,
      label: 'PATTERN',
      headline: 'You unlock most around ${_hourLabel(peak.key)}.',
      body:
          'Roughly ${daily}m a day in that hour — your most reliable behavior of the week.',
      tone: NarrativeTone.neutral,
    );
  }

  NarrativeBeat? _slipBeat(
    List<DailyStats> last7Days,
    BehaviorReport behavior,
    ContinuousUsageReport continuous,
  ) {
    if (continuous.longestSessionEver.inMinutes < 25) return null;
    final m = continuous.longestSessionEver.inMinutes;
    return NarrativeBeat(
      kind: NarrativeBeatKind.slip,
      label: 'SLIP',
      headline: 'A ${_h(m)} unbroken session.',
      body:
          'Your longest stretch this week. Nothing wrong with it on its own — but it\'s a tell.',
      tone: m >= 60 ? NarrativeTone.warning : NarrativeTone.caution,
    );
  }

  NarrativeBeat? _recoveryBeat(
    ContinuousUsageReport continuous,
    List<DailyStats> last7Days,
  ) {
    final off = continuous.longestScreenOffEver;
    if (off.inMinutes < 90) return null;
    return NarrativeBeat(
      kind: NarrativeBeatKind.recovery,
      label: 'RECOVERY',
      headline: 'Your longest screen-off stretch was ${_h(off.inMinutes)}.',
      body: 'That\'s the kind of gap your attention compounds into.',
      tone: NarrativeTone.warm,
    );
  }

  NarrativeBeat? _nightBeat(SleepReport sleep, List<DailyStats> last7Days) {
    if (sleep.nightUsage.inMinutes < 30 &&
        sleep.bedtimeConsistency >= 60 &&
        sleep.medianBedtime.minuteOfDay == null) {
      return null;
    }
    final bedtime = sleep.medianBedtime.format();
    final pickup = sleep.medianFirstPickup.format();
    if (sleep.stableWindowCount < 3) {
      return NarrativeBeat(
        kind: NarrativeBeatKind.night,
        label: 'NIGHT',
        headline: 'No stable sleep window detected.',
        body:
            'The night signal was too fragmented to turn into a confident story.',
        footnote: 'Probable windows found: ${sleep.stableWindowCount}',
        tone: NarrativeTone.neutral,
      );
    }
    return NarrativeBeat(
      kind: NarrativeBeatKind.night,
      label: 'NIGHT',
      headline: bedtime == '—'
          ? 'Sleep window unclear.'
          : 'Probable sleep around $bedtime, pickup around $pickup.',
      body: sleep.nightUsage.inMinutes >= 30
          ? '${_h(sleep.nightUsage.inMinutes)} of phone time after 10pm this week.'
          : 'Late-night usage stayed low — that\'s the spine of focus tomorrow.',
      footnote: 'Sleep-window consistency: ${sleep.bedtimeConsistency}/100',
      tone: sleep.nightUsage.inMinutes >= 90
          ? NarrativeTone.warning
          : NarrativeTone.neutral,
    );
  }

  NarrativeBeat? _trendBeat(
    List<DailyStats> last7Days,
    List<DailyStats> previous7Days,
  ) {
    final cur = _avgMinutes(last7Days);
    final prev = _avgMinutes(previous7Days);
    if (prev == 0) return null;
    final delta = cur - prev;
    if (delta.abs() < 8) {
      return const NarrativeBeat(
        kind: NarrativeBeatKind.trend,
        label: 'TREND',
        headline: 'A flat week.',
        body: 'No meaningful drift up or down. Holding pattern.',
        tone: NarrativeTone.neutral,
      );
    }
    return NarrativeBeat(
      kind: NarrativeBeatKind.trend,
      label: 'TREND',
      headline: delta < 0
          ? 'Daily average is dropping.'
          : 'Daily average is climbing.',
      body: delta < 0
          ? '${delta.abs()}m less per day vs last week. The shape is the point.'
          : '$delta m more per day vs last week. Worth watching.',
      tone: delta < 0 ? NarrativeTone.warm : NarrativeTone.caution,
    );
  }

  NarrativeBeat? _contradictionBeat({
    required List<DailyStats> last7Days,
    required List<DailyStats> previous7Days,
    required BehaviorReport behavior,
    required SleepReport sleep,
  }) {
    final curMin = _avgMinutes(last7Days);
    final prevMin = _avgMinutes(previous7Days);
    final curUnlocks =
        last7Days.fold<int>(0, (a, b) => a + b.unlocks) ~/ last7Days.length;
    final prevUnlocks = previous7Days.isEmpty
        ? curUnlocks
        : previous7Days.fold<int>(0, (a, b) => a + b.unlocks) ~/
              previous7Days.length;

    // Less screen time but more unlocks → compulsive checks. Tightened
    // thresholds: rarity is the point. A 15m drop with 6 extra unlocks isn't
    // tension — it's noise. We need a sharp gap to surface this.
    if (prevMin > 0 && curMin < prevMin - 25 && curUnlocks > prevUnlocks + 10) {
      return const NarrativeBeat(
        kind: NarrativeBeatKind.contradiction,
        label: 'CONTRADICTION',
        headline: 'Less screen time, more checks.',
        body:
            'You used the phone less but unlocked it more often — the urge is still there.',
        tone: NarrativeTone.caution,
      );
    }

    // High productivity but poor sleep. Tightened: productive >= 70 (was 60)
    // and sleep < 40 (was 45). Should be uncommon.
    if (behavior.productivityScore >= 70 && sleep.bedtimeConsistency < 40) {
      return const NarrativeBeat(
        kind: NarrativeBeatKind.contradiction,
        label: 'CONTRADICTION',
        headline: 'Productive, but at the cost of recovery.',
        body:
            'You worked well this week. Your sleep didn\'t. The two are connected.',
        tone: NarrativeTone.warning,
      );
    }

    // Low overall use, but heavy concentration in one app.
    final perApp = <String, int>{};
    for (final d in last7Days) {
      for (final a in d.apps) {
        if (!a.category.isDistracting) continue;
        perApp.update(
          a.packageName,
          (v) => v + a.foreground.inMinutes,
          ifAbsent: () => a.foreground.inMinutes,
        );
      }
    }
    if (perApp.isNotEmpty && curMin > 0) {
      final maxApp = perApp.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      final share = (maxApp.value / (curMin * last7Days.length)).clamp(
        0.0,
        1.0,
      );
      // Tighter: 40% concentration in a quieter-than-180m week.
      if (curMin < 180 && share > 0.40) {
        return NarrativeBeat(
          kind: NarrativeBeatKind.contradiction,
          label: 'CONTRADICTION',
          headline: 'Quiet week. One loud app.',
          body: 'Your total time is low, but a single app captured most of it.',
          tone: NarrativeTone.caution,
        );
      }
    }
    return null;
  }

  NarrativeBeat? _memoryBeat(
    List<DailyStats> last7Days,
    List<DailyStats> previous7Days,
  ) {
    if (previous7Days.isEmpty) return null;
    final prevAvg = _avgMinutes(previous7Days);
    final curAvg = _avgMinutes(last7Days);
    if (prevAvg == 0) return null;
    if (curAvg < prevAvg - 30) {
      return NarrativeBeat(
        kind: NarrativeBeatKind.memory,
        label: 'MEMORY',
        headline:
            'A week ago you averaged ${_h(prevAvg)} a day. Today you\'re at ${_h(curAvg)}.',
        body: 'A version of you was louder. You moved.',
        tone: NarrativeTone.warm,
      );
    }
    if (curAvg > prevAvg + 30) {
      return NarrativeBeat(
        kind: NarrativeBeatKind.memory,
        label: 'MEMORY',
        headline:
            'A week ago you averaged ${_h(prevAvg)}. You\'re at ${_h(curAvg)} now.',
        body: 'A quieter version of you existed seven days ago.',
        tone: NarrativeTone.caution,
      );
    }
    return null;
  }

  String? _prediction(
    List<DailyStats> last7Days,
    List<DailyStats> previous7Days,
    BehaviorReport behavior,
  ) {
    if (last7Days.isEmpty) return null;
    final cur = _avgMinutes(last7Days);
    final prev = _avgMinutes(previous7Days);
    if (prev > 0) {
      final delta = cur - prev;
      if (delta < -25) {
        return 'If this trend holds, you\'re on pace for your calmest week yet.';
      }
      if (delta > 30) {
        return 'If this pace continues, screen time will exceed last week by ${_h(delta * 7)} across the week.';
      }
    }
    // Predict slip hour.
    final hourSum = <int, int>{};
    for (final d in last7Days) {
      d.hourBuckets.forEach((h, dur) {
        if (h >= 21 || h < 2) {
          hourSum.update(
            h,
            (v) => v + dur.inMinutes,
            ifAbsent: () => dur.inMinutes,
          );
        }
      });
    }
    if (hourSum.isNotEmpty) {
      final peak = hourSum.entries.reduce((a, b) => a.value >= b.value ? a : b);
      if (peak.value >= 60) {
        return 'You usually slip into screen time after ${_hourLabel(peak.key)}.';
      }
    }
    return null;
  }

  // ----------------- adaptive restraint -----------------

  bool _isQuietDay(DailyStats today, List<DailyStats> last7Days) {
    if (today.screenTime.inMinutes >= 60) return false;
    final weekAvg = _avgMinutes(last7Days);
    return weekAvg < 120;
  }

  /// Insert a single [breath] scene immediately after each heavy beat
  /// (contradiction, slip, landmark, motif, after-midnight) — but never two
  /// in a row, and never as the first or final beat.
  List<NarrativeBeat> _intersperseBreath(List<NarrativeBeat> beats) {
    if (beats.length < 2) return beats;
    const heavy = <NarrativeBeatKind>{
      NarrativeBeatKind.contradiction,
      NarrativeBeatKind.slip,
      NarrativeBeatKind.landmark,
      NarrativeBeatKind.motif,
      NarrativeBeatKind.afterMidnight,
    };
    const breath = NarrativeBeat(
      kind: NarrativeBeatKind.breath,
      label: '',
      headline: '',
    );
    final out = <NarrativeBeat>[];
    for (int i = 0; i < beats.length; i++) {
      out.add(beats[i]);
      final isLast = i == beats.length - 1;
      if (isLast) continue;
      if (heavy.contains(beats[i].kind) &&
          beats[i + 1].kind != NarrativeBeatKind.breath &&
          beats[i + 1].kind != NarrativeBeatKind.ritual) {
        out.add(breath);
      }
    }
    return out;
  }

  // ----------------- voice register -----------------

  /// Some moods take poetry. Heavy weeks deserve plain language. Mixing the
  /// two creates credibility: a system that's only ever poetic stops being
  /// believed.
  bool _isPlainspoken(WeekMood m) {
    switch (m) {
      case WeekMood.heavy:
      case WeekMood.chaotic:
      case WeekMood.fragmented:
        return true;
      case WeekMood.calm:
      case WeekMood.protected:
      case WeekMood.recovering:
      case WeekMood.drifting:
        return false;
    }
  }

  /// Rewrites a small set of beat bodies in the plainspoken register. Only
  /// touches lines that have a real plain alternative — motif language stays
  /// intact because that *is* the user-facing mythology.
  List<NarrativeBeat> _applyVoice(List<NarrativeBeat> beats, WeekMood mood) {
    if (!_isPlainspoken(mood)) return beats;
    return beats.map((b) {
      switch (b.kind) {
        case NarrativeBeatKind.slip:
          return NarrativeBeat(
            kind: b.kind,
            label: b.label,
            headline: b.headline,
            body: 'You didn\'t put it down.',
            tone: b.tone,
            motifKey: b.motifKey,
          );
        case NarrativeBeatKind.recovery:
          return NarrativeBeat(
            kind: b.kind,
            label: b.label,
            headline: b.headline,
            body: 'You didn\'t pick it up.',
            tone: b.tone,
            motifKey: b.motifKey,
          );
        case NarrativeBeatKind.trend:
          return NarrativeBeat(
            kind: b.kind,
            label: b.label,
            headline: b.headline,
            body: b.headline.contains('climbing')
                ? 'Up.'
                : b.headline.contains('dropping')
                ? 'Down.'
                : 'Flat.',
            tone: b.tone,
            motifKey: b.motifKey,
          );
        default:
          return b;
      }
    }).toList();
  }

  // ----------------- mood composition -----------------

  /// Filter the candidate beats by mood. The point isn't to be comprehensive —
  /// it's to vary the experience. Calm weeks feel calm because slip and
  /// contradiction simply aren't there. Chaotic weeks omit recovery for the
  /// same reason. Memory beats (landmarks/motifs) always survive.
  List<NarrativeBeat> _composeForMood(
    List<NarrativeBeat> candidates,
    WeekMood mood,
    List<NarrativeBeat> memoryBeats,
  ) {
    Set<NarrativeBeatKind> drop;
    switch (mood) {
      case WeekMood.calm:
        drop = <NarrativeBeatKind>{
          NarrativeBeatKind.slip,
          NarrativeBeatKind.contradiction,
          NarrativeBeatKind.night,
          NarrativeBeatKind.prediction,
        };
        break;
      case WeekMood.protected:
        drop = <NarrativeBeatKind>{
          NarrativeBeatKind.slip,
          NarrativeBeatKind.contradiction,
          NarrativeBeatKind.trend,
        };
        break;
      case WeekMood.recovering:
        drop = <NarrativeBeatKind>{
          NarrativeBeatKind.slip,
          NarrativeBeatKind.night,
        };
        break;
      case WeekMood.drifting:
        drop = <NarrativeBeatKind>{
          NarrativeBeatKind.recovery,
          NarrativeBeatKind.pattern,
        };
        break;
      case WeekMood.fragmented:
        drop = <NarrativeBeatKind>{
          NarrativeBeatKind.recovery,
          NarrativeBeatKind.thisWeek,
        };
        break;
      case WeekMood.heavy:
        drop = <NarrativeBeatKind>{
          NarrativeBeatKind.recovery,
          NarrativeBeatKind.pattern,
        };
        break;
      case WeekMood.chaotic:
        drop = <NarrativeBeatKind>{
          NarrativeBeatKind.recovery,
          NarrativeBeatKind.memory,
          NarrativeBeatKind.pattern,
        };
        break;
    }

    final memoryKinds = memoryBeats.map((b) => b.kind).toSet();
    return candidates
        .where((b) => memoryKinds.contains(b.kind) || !drop.contains(b.kind))
        .toList();
  }

  // ----------------- continuity arcs -----------------

  /// Detect recurring behavioral arcs across a 28-day window. These are the
  /// "third late-night drift this month" type observations that make the app
  /// feel like it remembers, not summarizes.
  List<NarrativeBeat> _continuityArcs(List<DailyStats> last28Days) {
    final out = <NarrativeBeat>[];
    if (last28Days.length < 14) return out;

    // Late-night drift recurrence — count weeks where night usage >= 60 min
    // (sum of buckets 22..02 across that week).
    int weeksWithDrift = 0;
    for (int wStart = 0; wStart + 7 <= last28Days.length; wStart += 7) {
      int nightMs = 0;
      for (int i = wStart; i < wStart + 7 && i < last28Days.length; i++) {
        final d = last28Days[i];
        for (final h in const <int>[22, 23, 0, 1]) {
          nightMs += (d.hourBuckets[h] ?? Duration.zero).inMilliseconds;
        }
      }
      if (Duration(milliseconds: nightMs).inMinutes >= 60) weeksWithDrift++;
    }
    if (weeksWithDrift >= 2) {
      final n = weeksWithDrift;
      final ord = n == 2
          ? 'second'
          : n == 3
          ? 'third'
          : '${n}th';
      out.add(
        NarrativeBeat(
          kind: NarrativeBeatKind.arc,
          label: 'ARC',
          headline: '$ord late-night drift this month.',
          body: 'The pattern keeps coming back to you.',
          tone: NarrativeTone.warning,
        ),
      );
    }

    // Falling-intensity streak for the dominant distracting app — count
    // consecutive recent days where its minutes are non-increasing.
    final topPkg = _dominantDistractingPkg(last28Days);
    if (topPkg != null) {
      int streak = 0;
      int? prev;
      for (int i = last28Days.length - 1; i >= 0; i--) {
        final d = last28Days[i];
        final mins = d.apps
            .where((a) => a.packageName == topPkg)
            .fold<int>(0, (a, b) => a + b.foreground.inMinutes);
        if (prev == null) {
          prev = mins;
          streak = 1;
          continue;
        }
        if (mins <= prev + 1) {
          streak++;
          prev = mins;
        } else {
          break;
        }
      }
      if (streak >= 5) {
        final name = _displayNameOf(last28Days, topPkg);
        out.add(
          NarrativeBeat(
            kind: NarrativeBeatKind.arc,
            label: 'ARC',
            headline: '$name intensity has fallen for $streak days.',
            body: 'Whatever you\'re doing, it\'s working on this one.',
            tone: NarrativeTone.warm,
          ),
        );
      }
    }

    // Morning reclaim after bad weekends — if the last weekend was heavy and
    // the following Mon/Tue were noticeably lighter in their morning hours.
    final reclaim = _morningReclaim(last28Days);
    if (reclaim != null) out.add(reclaim);

    return out;
  }

  String? _dominantDistractingPkg(List<DailyStats> days) {
    final agg = <String, int>{};
    for (final d in days) {
      for (final a in d.apps) {
        if (!a.category.isDistracting) continue;
        agg.update(
          a.packageName,
          (v) => v + a.foreground.inMinutes,
          ifAbsent: () => a.foreground.inMinutes,
        );
      }
    }
    if (agg.isEmpty) return null;
    final top = agg.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.key;
  }

  String _displayNameOf(List<DailyStats> days, String pkg) {
    for (final d in days) {
      for (final a in d.apps) {
        if (a.packageName == pkg) return a.displayName;
      }
    }
    return pkg;
  }

  NarrativeBeat? _morningReclaim(List<DailyStats> days) {
    if (days.length < 9) return null;
    // Find the most recent Monday in the series.
    int? mondayIdx;
    for (int i = days.length - 1; i >= 0; i--) {
      if (days[i].day.weekday == DateTime.monday) {
        mondayIdx = i;
        break;
      }
    }
    if (mondayIdx == null || mondayIdx < 2) return null;
    final sat = days[mondayIdx - 2];
    final sun = days[mondayIdx - 1];
    final mon = days[mondayIdx];
    final weekendHeavy = (sat.screenTime + sun.screenTime).inMinutes >= 8 * 60;
    int monMorning = 0;
    int weekendMorning = 0;
    for (final h in const <int>[6, 7, 8, 9, 10]) {
      monMorning += (mon.hourBuckets[h] ?? Duration.zero).inMinutes;
      weekendMorning += (sat.hourBuckets[h] ?? Duration.zero).inMinutes;
      weekendMorning += (sun.hourBuckets[h] ?? Duration.zero).inMinutes;
    }
    final weekendMorningAvg = weekendMorning ~/ 2;
    if (weekendHeavy && monMorning < weekendMorningAvg - 15) {
      return const NarrativeBeat(
        kind: NarrativeBeatKind.arc,
        label: 'ARC',
        headline: 'You reclaim mornings after heavy weekends.',
        body: 'It\'s a real pattern. You\'ve done it before.',
        tone: NarrativeTone.warm,
      );
    }
    return null;
  }

  // ----------------- hidden chapters -----------------

  /// Time- and condition-gated chapters. They only render when something
  /// specific is true — that's the point: rarity creates anticipation.
  List<NarrativeBeat> _hiddenChapters({
    required DateTime now,
    required List<DailyStats> last28Days,
    required List<DailyStats> last7Days,
  }) {
    final out = <NarrativeBeat>[];

    // Sunday recap — only on Sunday evening.
    if (now.weekday == DateTime.sunday && now.hour >= 18) {
      final mins = last7Days.fold<int>(0, (a, b) => a + b.screenTime.inMinutes);
      out.add(
        NarrativeBeat(
          kind: NarrativeBeatKind.sunday,
          label: 'SUNDAY',
          headline: 'A week closes.',
          body:
              '${_h(mins)} of attention spent. Tomorrow is a fresh column on the page.',
          tone: NarrativeTone.warm,
        ),
      );
    }

    // After-midnight — only when current local time is 00:00–04:00.
    if (now.hour >= 0 && now.hour < 4) {
      out.add(
        const NarrativeBeat(
          kind: NarrativeBeatKind.afterMidnight,
          label: 'AFTER MIDNIGHT',
          headline: 'It\'s late.',
          body:
              'Most of what feels urgent right now will not feel urgent in the morning.',
          tone: NarrativeTone.caution,
        ),
      );
    }

    // Calm streak — last 3 days each under 90 minutes.
    if (last7Days.length >= 3) {
      final tail = last7Days.sublist(last7Days.length - 3);
      final allCalm = tail.every((d) => d.screenTime.inMinutes < 90);
      if (allCalm) {
        out.add(
          const NarrativeBeat(
            kind: NarrativeBeatKind.calmStreak,
            label: 'CALM',
            headline: 'Three quiet days in a row.',
            body:
                'You don\'t need to declare a streak. Your day already feels different.',
            tone: NarrativeTone.warm,
          ),
        );
      }
    }

    // Monthly chapter — only when a month boundary fell in the last 7 days.
    if (last28Days.isNotEmpty) {
      final lastDay = last28Days.last.day;
      final boundaryRecent = lastDay.day <= 7;
      if (boundaryRecent && last28Days.length >= 21) {
        final monthAvg =
            last28Days.fold<int>(0, (a, b) => a + b.screenTime.inMinutes) ~/
            last28Days.length;
        out.add(
          NarrativeBeat(
            kind: NarrativeBeatKind.monthly,
            label: 'MONTHLY',
            headline: 'A month of you.',
            body:
                'Average day: ${_h(monthAvg)}. The shape is what matters, not any single day.',
            tone: NarrativeTone.neutral,
          ),
        );
      }
    }

    return out;
  }

  // ----------------- helpers -----------------

  int _avgMinutes(List<DailyStats> days) {
    if (days.isEmpty) return 0;
    final total = days.fold<int>(0, (a, b) => a + b.screenTime.inMinutes);
    return (total / days.length).round();
  }

  String _h(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final r = m.remainder(60);
    if (r == 0) return '${h}h';
    return '${h}h ${r}m';
  }

  String _hourLabel(int h) {
    final hh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final ampm = h < 12 ? 'AM' : 'PM';
    return '$hh $ampm';
  }
}

class _AppAgg {
  final String name;
  final AppCategory category;
  int minutes = 0;
  int opens = 0;
  _AppAgg({required this.name, required this.category});
}
