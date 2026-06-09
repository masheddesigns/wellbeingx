import 'package:equatable/equatable.dart';

import '../models/app_category.dart';
import '../models/daily_stats.dart';
import '../models/personality_type.dart';

/// One beat in the Daily Replay reel. Each beat is a self-contained "moment"
/// the screen can render with its own visual treatment.
enum ChapterKind {
  title,
  wake,
  morning,
  midday,
  slip,
  bestHour,
  total,
  whereItWent,
  breath,
  outro,
  empty,
}

class ReplayChapter extends Equatable {
  final ChapterKind kind;

  /// How long this chapter holds on screen.
  final Duration duration;

  /// Big emotional headline.
  final String headline;

  /// Optional supporting line.
  final String? body;

  /// Optional short label (e.g. "06:42 AM", "WAKE").
  final String? label;

  /// Optional package — drives icon rendering on the slip / best-hour chapters.
  final String? packageName;

  /// Optional category for color theming.
  final AppCategory? category;

  /// Optional numeric value the chapter visualizes (e.g. minutes for total).
  final int? primaryValue;

  /// Optional secondary value (e.g. peak hour 0..23).
  final int? secondaryValue;

  const ReplayChapter({
    required this.kind,
    required this.duration,
    required this.headline,
    this.body,
    this.label,
    this.packageName,
    this.category,
    this.primaryValue,
    this.secondaryValue,
  });

  @override
  List<Object?> get props => <Object?>[
    kind,
    duration,
    headline,
    body,
    label,
    packageName,
    category,
    primaryValue,
    secondaryValue,
  ];
}

class ReplayScript extends Equatable {
  final List<ReplayChapter> chapters;

  /// Sum of all chapter durations.
  final Duration total;

  /// True when the day has so little data that the ritual should fall back to
  /// an "empty" message instead of running.
  final bool isEmpty;

  const ReplayScript({
    required this.chapters,
    required this.total,
    required this.isEmpty,
  });

  @override
  List<Object?> get props => <Object?>[chapters, total, isEmpty];
}

class ReplayChaptersEngine {
  const ReplayChaptersEngine();

  ReplayScript scriptFor({
    required DailyStats today,
    required DailyStats yesterday,
    required PersonalityType personality,
  }) {
    final chapters = <ReplayChapter>[];
    final todayContext = _dayContext(today.day);
    final yesterdayMinutes = yesterday.screenTime.inMinutes;
    final todayMinutes = today.screenTime.inMinutes;
    final dayDelta = todayMinutes - yesterdayMinutes;
    final materiallyDifferentFromYesterday =
        yesterdayMinutes > 0 && dayDelta.abs() >= 45;

    // ---- Title ----
    chapters.add(
      ReplayChapter(
        kind: ChapterKind.title,
        duration: const Duration(milliseconds: 3200),
        headline: 'Your day.',
        body: todayContext,
        label: personality.label.toUpperCase(),
      ),
    );

    // Empty short-circuit — keep one fallback beat that lasts a few seconds.
    if (today.screenTime.inMinutes < 5) {
      chapters.add(
        const ReplayChapter(
          kind: ChapterKind.empty,
          duration: Duration(milliseconds: 4500),
          headline: 'Quiet day so far.',
          body: 'Tomorrow is a fresh page.',
        ),
      );
      return _build(chapters);
    }

    // ---- Wake ----
    final firstUnlock = today.firstUnlockMs;
    if (firstUnlock != null) {
      chapters.add(
        ReplayChapter(
          kind: ChapterKind.wake,
          duration: const Duration(milliseconds: 5500),
          headline: 'You woke up at ${_clock(firstUnlock)}.',
          body: today.firstAppPkg == null
              ? null
              : 'First open: ${_appLabel(today, today.firstAppPkg!)}.',
          label: 'WAKE',
          packageName: today.firstAppPkg,
        ),
      );
    }

    // ---- Morning ----
    final morningMins = _hourSum(today, 6, 11);
    if (morningMins >= 20 ||
        (todayMinutes >= 30 && morningMins >= todayMinutes * 0.25)) {
      chapters.add(
        ReplayChapter(
          kind: ChapterKind.morning,
          duration: const Duration(milliseconds: 6500),
          headline: morningMins < 30
              ? 'Quiet morning.'
              : morningMins < 90
              ? 'Steady morning.'
              : 'Heavy morning.',
          body: '${_h(morningMins)} on the phone before noon.',
          label: 'MORNING',
          primaryValue: morningMins,
        ),
      );
    }

    // ---- Midday peak ----
    final peakHour = _peakHour(today);
    if (peakHour != null) {
      final peakMins = today.hourBuckets[peakHour]?.inMinutes ?? 0;
      if (peakMins >= 35 ||
          (todayMinutes >= 60 && peakMins >= todayMinutes * 0.28)) {
        chapters.add(
          ReplayChapter(
            kind: ChapterKind.midday,
            duration: const Duration(milliseconds: 6000),
            headline: 'Peak at ${_hourLabel(peakHour)}.',
            body: '${_h(peakMins)} in that hour alone.',
            label: 'PEAK',
            primaryValue: peakMins,
            secondaryValue: peakHour,
          ),
        );
      }
    }

    // ---- Slip moment ----
    final slipApp = _findSlipApp(today);
    if (slipApp != null) {
      chapters.add(
        ReplayChapter(
          kind: ChapterKind.slip,
          duration: const Duration(milliseconds: 7000),
          headline:
              '${slipApp.displayName} took ${slipApp.foreground.formatHm()}.',
          body: '${slipApp.opens} opens. That was the pull.',
          label: 'SLIP',
          packageName: slipApp.packageName,
          category: slipApp.category,
          primaryValue: slipApp.foreground.inMinutes,
        ),
      );
      chapters.add(
        const ReplayChapter(
          kind: ChapterKind.breath,
          duration: Duration(milliseconds: 1700),
          headline: '',
        ),
      );
    }

    // ---- Best hour (productive) ----
    final bestApp = _findBestProductiveApp(today);
    if (bestApp != null &&
        (slipApp == null || bestApp.foreground.inMinutes >= 30)) {
      chapters.add(
        ReplayChapter(
          kind: ChapterKind.bestHour,
          duration: const Duration(milliseconds: 6000),
          headline: 'You held attention.',
          body: '${bestApp.foreground.formatHm()} on ${bestApp.displayName}.',
          label: 'STRONGEST',
          packageName: bestApp.packageName,
          category: bestApp.category,
        ),
      );
    }

    // ---- Total ----
    if (todayMinutes >= 90 || materiallyDifferentFromYesterday) {
      chapters.add(
        ReplayChapter(
          kind: ChapterKind.total,
          duration: const Duration(milliseconds: 8000),
          headline: 'Today, total.',
          body: _h(today.screenTime.inMinutes),
          label: 'TOTAL',
          primaryValue: today.screenTime.inMinutes,
        ),
      );
    }

    // ---- Where it went ----
    final categories = today.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (categories.isNotEmpty && todayMinutes >= 90) {
      final top = categories.take(3).toList();
      chapters.add(
        ReplayChapter(
          kind: ChapterKind.whereItWent,
          duration: const Duration(milliseconds: 7000),
          headline: 'Where it went.',
          body: top
              .map((e) => '${e.key.label}: ${e.value.formatHm()}')
              .join(' · '),
          label: 'BREAKDOWN',
        ),
      );
    }

    // ---- Outro ----
    final delta = today.screenTime - yesterday.screenTime;
    final outroBody = yesterday.screenTime.inMinutes == 0
        ? 'Tomorrow is your first comparison.'
        : delta.isNegative
        ? '${(-delta).formatHm()} less than yesterday.'
        : '${delta.formatHm()} more than yesterday.';
    chapters.add(
      ReplayChapter(
        kind: ChapterKind.outro,
        duration: const Duration(milliseconds: 6500),
        headline: 'Tomorrow is a fresh page.',
        body: outroBody,
        label: 'END',
      ),
    );

    return _build(chapters);
  }

  ReplayScript _build(List<ReplayChapter> cs) {
    final total = cs.fold<Duration>(Duration.zero, (a, c) => a + c.duration);
    return ReplayScript(
      chapters: cs,
      total: total,
      isEmpty: cs.length <= 2 && cs.last.kind == ChapterKind.empty,
    );
  }

  // ---------------- helpers ----------------

  String _clock(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  String _hourLabel(int h) {
    final hh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final ampm = h < 12 ? 'AM' : 'PM';
    return '$hh $ampm';
  }

  String _h(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final r = m.remainder(60);
    if (r == 0) return '${h}h';
    return '${h}h ${r}m';
  }

  String _appLabel(DailyStats day, String pkg) {
    final app = day.apps
        .where((a) => a.packageName == pkg)
        .cast<AppUsage?>()
        .firstWhere((_) => true, orElse: () => null);
    return app?.displayName ?? pkg;
  }

  int _hourSum(DailyStats d, int from, int toInclusive) {
    int sum = 0;
    for (int h = from; h <= toInclusive; h++) {
      sum += d.hourBuckets[h]?.inMinutes ?? 0;
    }
    return sum;
  }

  int? _peakHour(DailyStats d) {
    if (d.hourBuckets.isEmpty) return null;
    return d.hourBuckets.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  AppUsage? _findSlipApp(DailyStats d) {
    final distract = d.apps.where((a) => a.category.isDistracting).toList()
      ..sort((a, b) => b.foreground.compareTo(a.foreground));
    if (distract.isEmpty) return null;
    final top = distract.first;
    if (top.foreground.inMinutes < 20) return null;
    return top;
  }

  AppUsage? _findBestProductiveApp(DailyStats d) {
    final prod = d.apps.where((a) => a.category.isProductive).toList()
      ..sort((a, b) => b.foreground.compareTo(a.foreground));
    if (prod.isEmpty) return null;
    final top = prod.first;
    if (top.foreground.inMinutes < 15) return null;
    return top;
  }

  String _dayContext(DateTime day) {
    switch (day.weekday) {
      case DateTime.saturday:
        return 'Saturday has its own gravity.';
      case DateTime.sunday:
        return 'Sunday leaves a different trace.';
      case DateTime.monday:
        return 'The week opened here.';
      case DateTime.friday:
        return 'Friday stretched the pattern.';
      default:
        return 'A weekday trace.';
    }
  }
}

// Tiny extension so we can write `dur.formatHm()` here without importing
// the full util — the engine is meant to be self-contained.
extension on Duration {
  String formatHm() {
    final m = inMinutes;
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final r = m.remainder(60);
    if (r == 0) return '${h}h';
    return '${h}h ${r}m';
  }
}
