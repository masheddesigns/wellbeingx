import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/diagnostics.dart';
import '../../core/services/onboarding_service.dart';

/// Persistent narrative memory — the substrate for landmarks and named motifs.
/// Stored as a single JSON blob under one prefs key so it loads in one read.
class NarrativeMemory {
  /// Day-level records the app remembers across weeks.
  final NarrativeLandmarks landmarks;

  /// Named recurring motifs the app has earned for this user.
  final Map<String, MotifRecord> motifs;

  const NarrativeMemory({
    required this.landmarks,
    required this.motifs,
  });

  factory NarrativeMemory.empty() => NarrativeMemory(
        landmarks: NarrativeLandmarks.empty(),
        motifs: <String, MotifRecord>{},
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'landmarks': landmarks.toJson(),
        'motifs': motifs.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory NarrativeMemory.fromJson(Map<String, dynamic> j) {
    final raw = j['motifs'];
    final motifs = <String, MotifRecord>{};
    if (raw is Map<String, dynamic>) {
      raw.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          motifs[k] = MotifRecord.fromJson(v);
        }
      });
    }
    return NarrativeMemory(
      landmarks: NarrativeLandmarks.fromJson(
          (j['landmarks'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
      motifs: motifs,
    );
  }
}

class NarrativeLandmarks {
  final int? calmestMinutes;
  final String? calmestDate; // ISO yyyy-MM-dd
  final int? heaviestMinutes;
  final String? heaviestDate;
  final String? firstSubTwoHourDate;
  final String? firstMidnightFreeWeekEnd;

  const NarrativeLandmarks({
    this.calmestMinutes,
    this.calmestDate,
    this.heaviestMinutes,
    this.heaviestDate,
    this.firstSubTwoHourDate,
    this.firstMidnightFreeWeekEnd,
  });

  factory NarrativeLandmarks.empty() => const NarrativeLandmarks();

  NarrativeLandmarks copyWith({
    int? calmestMinutes,
    String? calmestDate,
    int? heaviestMinutes,
    String? heaviestDate,
    String? firstSubTwoHourDate,
    String? firstMidnightFreeWeekEnd,
  }) =>
      NarrativeLandmarks(
        calmestMinutes: calmestMinutes ?? this.calmestMinutes,
        calmestDate: calmestDate ?? this.calmestDate,
        heaviestMinutes: heaviestMinutes ?? this.heaviestMinutes,
        heaviestDate: heaviestDate ?? this.heaviestDate,
        firstSubTwoHourDate: firstSubTwoHourDate ?? this.firstSubTwoHourDate,
        firstMidnightFreeWeekEnd:
            firstMidnightFreeWeekEnd ?? this.firstMidnightFreeWeekEnd,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (calmestMinutes != null) 'calmestMinutes': calmestMinutes,
        if (calmestDate != null) 'calmestDate': calmestDate,
        if (heaviestMinutes != null) 'heaviestMinutes': heaviestMinutes,
        if (heaviestDate != null) 'heaviestDate': heaviestDate,
        if (firstSubTwoHourDate != null)
          'firstSubTwoHourDate': firstSubTwoHourDate,
        if (firstMidnightFreeWeekEnd != null)
          'firstMidnightFreeWeekEnd': firstMidnightFreeWeekEnd,
      };

  factory NarrativeLandmarks.fromJson(Map<String, dynamic> j) =>
      NarrativeLandmarks(
        calmestMinutes: j['calmestMinutes'] as int?,
        calmestDate: j['calmestDate'] as String?,
        heaviestMinutes: j['heaviestMinutes'] as int?,
        heaviestDate: j['heaviestDate'] as String?,
        firstSubTwoHourDate: j['firstSubTwoHourDate'] as String?,
        firstMidnightFreeWeekEnd: j['firstMidnightFreeWeekEnd'] as String?,
      );
}

/// One named motif. Counts only increment — every recurrence is meaningful.
class MotifRecord {
  final int count;
  final String firstSeen; // ISO yyyy-MM-dd
  final String lastSeen;
  const MotifRecord({
    required this.count,
    required this.firstSeen,
    required this.lastSeen,
  });

  MotifRecord increment(String today) =>
      MotifRecord(count: count + 1, firstSeen: firstSeen, lastSeen: today);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'count': count,
        'firstSeen': firstSeen,
        'lastSeen': lastSeen,
      };

  factory MotifRecord.fromJson(Map<String, dynamic> j) => MotifRecord(
        count: j['count'] as int,
        firstSeen: j['firstSeen'] as String,
        lastSeen: j['lastSeen'] as String,
      );
}

class NarrativeMemoryRepository {
  NarrativeMemoryRepository(this._prefs);
  final SharedPreferences _prefs;

  static const String _key = 'wx.narrative_memory.v1';

  NarrativeMemory load() {
    try {
      final raw = _prefs.getString(_key);
      if (raw == null) return NarrativeMemory.empty();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return NarrativeMemory.fromJson(json);
    } catch (e, st) {
      WxLog.error('narrative-memory.load', 'failed to parse', e, st);
      return NarrativeMemory.empty();
    }
  }

  Future<void> save(NarrativeMemory mem) async {
    try {
      await _prefs.setString(_key, jsonEncode(mem.toJson()));
    } catch (e, st) {
      WxLog.error('narrative-memory.save', 'failed to write', e, st);
    }
  }

  Future<void> reset() async {
    await _prefs.remove(_key);
  }
}

final narrativeMemoryRepositoryProvider =
    Provider<NarrativeMemoryRepository>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return NarrativeMemoryRepository(prefs);
});
