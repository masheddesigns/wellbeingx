import '../../data/repositories/narrative_memory_repository.dart';
import '../models/daily_stats.dart';
import 'narrative_intelligence.dart';

/// Output of the memory engine: any beats that should be surfaced this session
/// (newly-earned landmarks, recurring motifs that just ticked up), plus the
/// new memory snapshot to persist.
class NarrativeMemoryUpdate {
  final List<NarrativeBeat> beats;
  final NarrativeMemory next;
  const NarrativeMemoryUpdate({required this.beats, required this.next});
}

/// Detects landmarks (records the app remembers across weeks) and named
/// recurring motifs ("The Late Drift", "The Midnight Return") that the app
/// uses linguistically across sessions.
///
/// All decisions here are deterministic — no time-of-day gating. The screen
/// decides what to render; the engine decides what's true.
class NarrativeMemoryEngine {
  const NarrativeMemoryEngine();

  /// Built-in motif catalog. Keys must be stable — they're persisted.
  static const String motifLateDrift = 'late_drift';
  static const String motifMidnightReturn = 'midnight_return';
  static const String motifInstagramSpiral = 'instagram_spiral';

  static const Map<String, String> _motifLabels = <String, String>{
    motifLateDrift: 'The Late Drift',
    motifMidnightReturn: 'The Midnight Return',
    motifInstagramSpiral: 'The Spiral',
  };

  NarrativeMemoryUpdate evaluate({
    required DailyStats today,
    required List<DailyStats> last7Days,
    required List<DailyStats> last28Days,
    required NarrativeMemory current,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final todayKey = _isoDate(clock);
    final beats = <NarrativeBeat>[];
    var landmarks = current.landmarks;
    final motifs = Map<String, MotifRecord>.from(current.motifs);

    // ---- LANDMARKS -------------------------------------------------------

    // Calmest day on record. Only set after we've seen enough days that the
    // record means something — at least 7.
    if (last28Days.length >= 7 && today.screenTime.inMinutes > 0) {
      final mins = today.screenTime.inMinutes;
      final best = landmarks.calmestMinutes;
      if (best == null || mins < best) {
        // Avoid trivial firsts — only celebrate when we have a baseline.
        if (best != null) {
          beats.add(NarrativeBeat(
            kind: NarrativeBeatKind.landmark,
            label: 'LANDMARK',
            headline: 'Today is your calmest day on record.',
            body: '${_h(mins)} — your previous low was ${_h(best)}.',
            tone: NarrativeTone.triumph,
          ));
        }
        landmarks = landmarks.copyWith(
            calmestMinutes: mins, calmestDate: todayKey);
      }
      final worst = landmarks.heaviestMinutes;
      if (worst == null || mins > worst) {
        landmarks = landmarks.copyWith(
            heaviestMinutes: mins, heaviestDate: todayKey);
      }
    }

    // First sub-2h day, ever. Only fires once.
    if (landmarks.firstSubTwoHourDate == null &&
        today.screenTime.inMinutes > 0 &&
        today.screenTime.inMinutes < 120 &&
        last28Days.length >= 7) {
      beats.add(const NarrativeBeat(
        kind: NarrativeBeatKind.landmark,
        label: 'LANDMARK',
        headline: 'Your first day under two hours.',
        body: 'You\'ve never been here before.',
        tone: NarrativeTone.triumph,
      ));
      landmarks =
          landmarks.copyWith(firstSubTwoHourDate: todayKey);
    }

    // First midnight-free week — last 7 days had zero usage in 00:00–04:00.
    if (landmarks.firstMidnightFreeWeekEnd == null &&
        last7Days.length == 7) {
      bool anyMidnight = false;
      for (final d in last7Days) {
        for (final h in const <int>[0, 1, 2, 3]) {
          if ((d.hourBuckets[h] ?? Duration.zero).inMinutes > 0) {
            anyMidnight = true;
            break;
          }
        }
        if (anyMidnight) break;
      }
      if (!anyMidnight) {
        beats.add(const NarrativeBeat(
          kind: NarrativeBeatKind.landmark,
          label: 'LANDMARK',
          headline: 'A whole week without a midnight check.',
          body: 'Your first one on record.',
          tone: NarrativeTone.triumph,
        ));
        landmarks = landmarks.copyWith(firstMidnightFreeWeekEnd: todayKey);
      }
    }

    // ---- MOTIFS ----------------------------------------------------------

    // Late Drift — fires when the last 7 days accumulated >= 60min in
    // 22:00–01:59 buckets. Increments at most once per evaluation; gated by
    // lastSeen so a single week can't double-tick.
    final nightMs = last7Days.fold<int>(0, (a, d) {
      var sum = 0;
      for (final h in const <int>[22, 23, 0, 1]) {
        sum += (d.hourBuckets[h] ?? Duration.zero).inMilliseconds;
      }
      return a + sum;
    });
    if (Duration(milliseconds: nightMs).inMinutes >= 90) {
      _bumpMotif(motifs, motifLateDrift, todayKey, beats,
          weekKey: _weekKey(clock));
    }

    // Midnight Return — at least 3 days in last 7 with usage in 00:00–04:00.
    int midnightDays = 0;
    for (final d in last7Days) {
      bool any = false;
      for (final h in const <int>[0, 1, 2, 3]) {
        if ((d.hourBuckets[h] ?? Duration.zero).inMinutes > 0) {
          any = true;
          break;
        }
      }
      if (any) midnightDays++;
    }
    if (midnightDays >= 3) {
      _bumpMotif(motifs, motifMidnightReturn, todayKey, beats,
          weekKey: _weekKey(clock));
    }

    // Spiral — top distractor consumed >= 40% of total distract time.
    final perApp = <String, int>{};
    var totalDistract = 0;
    for (final d in last7Days) {
      for (final a in d.apps) {
        if (!a.category.isDistracting) continue;
        perApp.update(
          a.packageName,
          (v) => v + a.foreground.inMinutes,
          ifAbsent: () => a.foreground.inMinutes,
        );
        totalDistract += a.foreground.inMinutes;
      }
    }
    if (totalDistract >= 60 && perApp.isNotEmpty) {
      final top = perApp.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final share = top.value / totalDistract;
      if (share >= 0.40) {
        _bumpMotif(motifs, motifInstagramSpiral, todayKey, beats,
            weekKey: _weekKey(clock));
      }
    }

    return NarrativeMemoryUpdate(
      beats: beats,
      next: NarrativeMemory(landmarks: landmarks, motifs: motifs),
    );
  }

  // Increments a motif at most once per ISO week — so a single weekly synth
  // can't mint multiple recurrences of the same motif. Emits a beat only when
  // the count crosses a meaningful threshold (2nd, 3rd, 5th, 8th, ...).
  void _bumpMotif(
    Map<String, MotifRecord> motifs,
    String key,
    String todayKey,
    List<NarrativeBeat> beats, {
    required String weekKey,
  }) {
    final existing = motifs[key];
    if (existing != null && existing.lastSeen.compareTo(weekKey) >= 0) {
      // Already counted this week (or future). Don't double-bump.
      return;
    }
    final next = existing == null
        ? MotifRecord(count: 1, firstSeen: todayKey, lastSeen: weekKey)
        : existing.increment(weekKey);
    motifs[key] = next;
    final label = _motifLabels[key] ?? key;
    if (next.count == 2) {
      beats.add(NarrativeBeat(
        kind: NarrativeBeatKind.motif,
        label: 'MOTIF',
        headline: '$label returns.',
        body: 'A pattern is forming.',
        tone: NarrativeTone.caution,
        motifKey: key,
      ));
    } else if (next.count == 3) {
      beats.add(NarrativeBeat(
        kind: NarrativeBeatKind.motif,
        label: 'MOTIF',
        headline: '$label, again.',
        body: 'Three weeks now. The app has a name for it.',
        tone: NarrativeTone.warning,
        motifKey: key,
      ));
    } else if (next.count >= 5 && next.count.isOdd) {
      beats.add(NarrativeBeat(
        kind: NarrativeBeatKind.motif,
        label: 'MOTIF',
        headline: '$label · ${next.count}.',
        body: 'A long arc.',
        tone: NarrativeTone.warning,
        motifKey: key,
      ));
    }
  }

  String _isoDate(DateTime t) {
    String pad(int v) => v < 10 ? '0$v' : '$v';
    return '${t.year}-${pad(t.month)}-${pad(t.day)}';
  }

  String _weekKey(DateTime t) {
    // Year + ISO-ish week key. Week starts Monday. Cheap, stable, sortable.
    final monday = t.subtract(Duration(days: t.weekday - 1));
    return _isoDate(monday);
  }

  String _h(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final r = m.remainder(60);
    if (r == 0) return '${h}h';
    return '${h}h ${r}m';
  }
}
