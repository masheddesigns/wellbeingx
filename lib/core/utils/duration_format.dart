extension DurationFormat on Duration {
  /// "4h 26m" / "26m" / "45s" — the chunky public stat.
  String formatHm() {
    if (inSeconds < 60) return '${inSeconds}s';
    final h = inHours;
    final m = inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// "04:26:00" — for replay / focus timers.
  String formatHms() {
    final h = inHours.toString().padLeft(2, '0');
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// "26:00" — Pomodoro mm:ss (no hours).
  String formatMs() {
    final m = inMinutes.toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Compact, two-segment: "4h 26m", "26m", "45s".
  String compact() => formatHm();
}

/// Pluralized count helper. count(132, 'unlock') -> '132 unlocks'.
String pluralize(int count, String word, [String? pluralForm]) {
  if (count == 1) return '1 $word';
  return '$count ${pluralForm ?? '${word}s'}';
}
