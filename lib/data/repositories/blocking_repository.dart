import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/native_bridge.dart';
import '../../core/utils/date_utils.dart';
import '../db/database.dart';
import 'gamification_repository.dart';

class BlockingRepository {
  BlockingRepository(this._db, this._native);
  final WxDatabase _db;
  final NativeBridgeApi _native;

  Future<void> setRule({
    required String packageName,
    required String mode, // soft|hard|extreme
    DateTime? until,
  }) async {
    await _db.into(_db.blockRules).insert(
          BlockRulesCompanion.insert(
            packageName: packageName,
            mode: mode,
            untilMs: Value<int?>(until?.millisecondsSinceEpoch),
            createdMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    await _push();
  }

  Future<void> remove(int id) async {
    await (_db.delete(_db.blockRules)..where((t) => t.id.equals(id))).go();
    await _push();
  }

  Future<void> clearAll() async {
    await _db.delete(_db.blockRules).go();
    await _native.clearBlocking();
  }

  Future<List<BlockRuleRow>> active() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (_db.select(_db.blockRules)
          ..where((t) =>
              t.enabled.equals(true) &
              (t.untilMs.isNull() | t.untilMs.isBiggerThanValue(now))))
        .get();
  }

  /// Anti-cheat: log when a user breaks past a soft block. Penalties scale by mode.
  Future<int> recordOverride({
    required String packageName,
    required String mode,
    required GamificationRepository gami,
  }) async {
    final xpPenalty = mode == 'extreme'
        ? 100
        : mode == 'hard'
            ? 30
            : 10;
    final coinPenalty = mode == 'extreme' ? 10 : 3;
    await _db.into(_db.blockOverrides).insert(
          BlockOverridesCompanion.insert(
            timestampMs: DateTime.now().millisecondsSinceEpoch,
            packageName: packageName,
            mode: mode,
            xpPenalty: Value<int>(xpPenalty),
            coinPenalty: Value<int>(coinPenalty),
          ),
        );
    final state = await gami.read();
    final newXp = (state.xp - xpPenalty).clamp(0, 1 << 30);
    final newCoins = (state.coins - coinPenalty).clamp(0, 1 << 30);
    await gami.write(state.copyWith(xp: newXp, coins: newCoins));
    return xpPenalty;
  }

  Future<List<BlockOverrideRow>> recentOverrides({int days = 7}) async {
    final cutoff = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;
    return (_db.select(_db.blockOverrides)
          ..where((t) => t.timestampMs.isBiggerOrEqualValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.timestampMs)]))
        .get();
  }

  Future<int> overridesToday() async {
    final start = WxDates.startOfDay(DateTime.now()).millisecondsSinceEpoch;
    final res = await _db.customSelect(
      'SELECT COUNT(*) AS n FROM block_overrides WHERE timestamp_ms >= ?',
      variables: [Variable<int>(start)],
      readsFrom: {_db.blockOverrides},
    ).getSingle();
    return res.read<int?>('n') ?? 0;
  }

  // -------- Schedules --------

  Future<void> addSchedule({
    required String packageName,
    required int startMinute,
    required int endMinute,
    required int daysMask,
    String mode = 'hard',
  }) async {
    await _db.into(_db.blockSchedules).insert(
          BlockSchedulesCompanion.insert(
            packageName: packageName,
            startMinute: startMinute,
            endMinute: endMinute,
            daysMask: daysMask,
            mode: Value<String>(mode),
          ),
        );
  }

  Future<List<BlockScheduleRow>> schedules() =>
      (_db.select(_db.blockSchedules)..where((t) => t.enabled.equals(true))).get();

  Future<void> removeSchedule(int id) async {
    await (_db.delete(_db.blockSchedules)..where((t) => t.id.equals(id))).go();
  }

  Future<void> _push() async {
    final rules = await active();
    if (rules.isEmpty) {
      await _native.clearBlocking();
      return;
    }
    // Group by mode and push each set. In MVP, the strictest mode wins.
    String highest = 'soft';
    for (final r in rules) {
      if (r.mode == 'extreme') highest = 'extreme';
      else if (r.mode == 'hard' && highest != 'extreme') highest = 'hard';
    }
    final pkgs = rules.map((r) => r.packageName).toSet().toList();
    final until = rules
        .map((r) => r.untilMs)
        .whereType<int>()
        .fold<int?>(null, (a, b) => a == null ? b : (a > b ? a : b));
    await _native.setBlockedPackages(pkgs, mode: highest, untilMs: until);
  }
}

final blockingRepositoryProvider = Provider<BlockingRepository>((ref) {
  return BlockingRepository(
    ref.watch(dbProvider),
    ref.watch(nativeBridgeProvider),
  );
});

final activeBlockRulesProvider =
    FutureProvider<List<BlockRuleRow>>((ref) async {
  return ref.watch(blockingRepositoryProvider).active();
});
