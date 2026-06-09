import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';

class MoodRepository {
  MoodRepository(this._db);
  final WxDatabase _db;

  Future<void> log({required int score, String? tag, String? note}) async {
    await _db.into(_db.moodEntries).insert(
          MoodEntriesCompanion.insert(
            timestampMs: DateTime.now().millisecondsSinceEpoch,
            score: score,
            tag: Value<String?>(tag),
            note: Value<String?>(note),
          ),
        );
  }

  Future<List<MoodRow>> recent({int limit = 30}) {
    return (_db.select(_db.moodEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.timestampMs)])
          ..limit(limit))
        .get();
  }
}

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository(ref.watch(dbProvider));
});

class PurposeRepository {
  PurposeRepository(this._db);
  final WxDatabase _db;

  Future<void> log(String pkg, String purpose) async {
    await _db.into(_db.purposeUnlocks).insert(
          PurposeUnlocksCompanion.insert(
            timestampMs: DateTime.now().millisecondsSinceEpoch,
            packageName: pkg,
            purpose: purpose,
          ),
        );
  }

  Future<List<PurposeRow>> recent({int limit = 50}) {
    return (_db.select(_db.purposeUnlocks)
          ..orderBy([(t) => OrderingTerm.desc(t.timestampMs)])
          ..limit(limit))
        .get();
  }
}

final purposeRepositoryProvider = Provider<PurposeRepository>((ref) {
  return PurposeRepository(ref.watch(dbProvider));
});
