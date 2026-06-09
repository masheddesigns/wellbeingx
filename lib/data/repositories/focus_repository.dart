import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../db/database.dart';

class FocusRepository {
  FocusRepository(this._db);
  final WxDatabase _db;

  Future<int> startSession({
    required Duration planned,
    required String mode,
    String? tag,
  }) async {
    return _db.into(_db.focusSessions).insert(
          FocusSessionsCompanion.insert(
            startedMs: DateTime.now().millisecondsSinceEpoch,
            plannedMs: planned.inMilliseconds,
            mode: Value<String>(mode),
            tag: Value<String?>(tag),
          ),
        );
  }

  Future<void> completeSession(
    int id, {
    required Duration actual,
    required bool completed,
    int interruptions = 0,
    int xpAwarded = 0,
    int coinsAwarded = 0,
    int productivityScore = 0,
  }) async {
    await (_db.update(_db.focusSessions)..where((t) => t.id.equals(id))).write(
      FocusSessionsCompanion(
        actualMs: Value<int>(actual.inMilliseconds),
        completed: Value<bool>(completed),
        interruptions: Value<int>(interruptions),
        xpAwarded: Value<int>(xpAwarded),
        coinsAwarded: Value<int>(coinsAwarded),
        productivityScore: Value<int>(productivityScore),
      ),
    );
  }

  Future<List<FocusSessionRow>> history({int limit = 30}) {
    return (_db.select(_db.focusSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.startedMs)])
          ..limit(limit))
        .get();
  }

  Future<Duration> totalCompletedThisWeek() async {
    final start = WxDates.startOfWeek(DateTime.now()).millisecondsSinceEpoch;
    final res = await _db
        .customSelect(
          'SELECT COALESCE(SUM(actual_ms), 0) AS total FROM focus_sessions '
          'WHERE completed = 1 AND started_ms >= ?',
          variables: [Variable<int>(start)],
          readsFrom: {_db.focusSessions},
        )
        .getSingle();
    return Duration(milliseconds: res.read<int?>('total') ?? 0);
  }

  Future<int> countCompleted() async {
    final res = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM focus_sessions WHERE completed = 1',
          readsFrom: {_db.focusSessions},
        )
        .getSingle();
    return res.read<int?>('n') ?? 0;
  }
}

final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  return FocusRepository(ref.watch(dbProvider));
});

final focusHistoryProvider =
    FutureProvider<List<FocusSessionRow>>((ref) async {
  return ref.watch(focusRepositoryProvider).history();
});
