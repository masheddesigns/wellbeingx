import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/models/gamification.dart';
import '../db/database.dart';

const _kGamiKey = 'gamification.state';

class GamificationRepository {
  GamificationRepository(this._db);
  final WxDatabase _db;

  Future<GamificationState> read() async {
    final row = await (_db.select(_db.keyValues)
          ..where((t) => t.key.equals(_kGamiKey)))
        .getSingleOrNull();
    if (row == null) return GamificationState.initial();
    try {
      return GamificationState.fromJson(
          jsonDecode(row.value) as Map<String, dynamic>);
    } catch (_) {
      return GamificationState.initial();
    }
  }

  Future<void> write(GamificationState state) async {
    await _db.into(_db.keyValues).insert(
          KeyValuesCompanion.insert(
            key: _kGamiKey,
            value: jsonEncode(state.toJson()),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<GamificationState> awardXp(int xp) async {
    final s = await read();
    final updated = s.copyWith(xp: s.xp + xp);
    await write(updated);
    return updated;
  }

  Future<GamificationState> awardCoins(int coins) async {
    final s = await read();
    final updated = s.copyWith(coins: s.coins + coins);
    await write(updated);
    return updated;
  }

  /// Bump streak based on whether [today] qualifies (e.g. completed a focus
  /// session). Resets if there was a day-long gap.
  Future<GamificationState> tickStreak({required bool qualified}) async {
    final s = await read();
    final today = WxDates.startOfDay(DateTime.now());
    final last = s.lastActiveDay == null
        ? null
        : WxDates.startOfDay(s.lastActiveDay!);
    if (!qualified) return s;
    if (last == null) {
      final updated = s.copyWith(
        currentStreak: 1,
        longestStreak: s.longestStreak < 1 ? 1 : s.longestStreak,
        lastActiveDay: today,
      );
      await write(updated);
      return updated;
    }
    if (WxDates.isSameDay(last, today)) return s;
    final newStreak = today.difference(last).inDays == 1
        ? s.currentStreak + 1
        : 1;
    final updated = s.copyWith(
      currentStreak: newStreak,
      longestStreak:
          newStreak > s.longestStreak ? newStreak : s.longestStreak,
      lastActiveDay: today,
    );
    await write(updated);
    return updated;
  }

  Future<List<AchievementRow>> unlocked() => _db.select(_db.achievements).get();

  Future<bool> unlock(String code) async {
    final existing = await (_db.select(_db.achievements)
          ..where((t) => t.code.equals(code)))
        .getSingleOrNull();
    if (existing != null) return false;
    final def =
        kAchievements.firstWhere((a) => a.code == code, orElse: () => kAchievements.first);
    await _db.into(_db.achievements).insert(
          AchievementsCompanion.insert(
            code: code,
            unlockedAtMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    await awardXp(def.xp);
    await awardCoins(def.coins);
    return true;
  }

  Future<List<MissionRow>> todaysMissions() async {
    final dayEpoch = WxDates.dayEpoch(DateTime.now());
    return (_db.select(_db.missions)
          ..where((t) => t.dayEpoch.equals(dayEpoch)))
        .get();
  }

  Future<void> ensureDailyMissions(List<({
    String code,
    String title,
    String description,
    int target,
    int xp,
    int coins,
  })> defs) async {
    final dayEpoch = WxDates.dayEpoch(DateTime.now());
    final existing = await todaysMissions();
    if (existing.isNotEmpty) return;
    await _db.batch((b) {
      for (final d in defs) {
        b.insert(
          _db.missions,
          MissionsCompanion.insert(
            dayEpoch: dayEpoch,
            code: d.code,
            title: d.title,
            description: d.description,
            target: d.target,
            xpReward: d.xp,
            coinsReward: d.coins,
          ),
        );
      }
    });
  }

  Future<void> bumpMission(String code, {int by = 1}) async {
    final dayEpoch = WxDates.dayEpoch(DateTime.now());
    final row = await (_db.select(_db.missions)
          ..where((t) => t.dayEpoch.equals(dayEpoch) & t.code.equals(code)))
        .getSingleOrNull();
    if (row == null) return;
    final progress = (row.progress + by).clamp(0, row.target);
    final completed = progress >= row.target;
    await (_db.update(_db.missions)..where((t) => t.id.equals(row.id))).write(
      MissionsCompanion(
        progress: Value<int>(progress),
        completed: Value<bool>(completed),
      ),
    );
    if (completed && !row.claimed) {
      await (_db.update(_db.missions)..where((t) => t.id.equals(row.id)))
          .write(const MissionsCompanion(claimed: Value<bool>(true)));
      await awardXp(row.xpReward);
      await awardCoins(row.coinsReward);
    }
  }
}

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return GamificationRepository(ref.watch(dbProvider));
});

final gamificationStateProvider =
    FutureProvider<GamificationState>((ref) async {
  return ref.watch(gamificationRepositoryProvider).read();
});

final achievementsProvider =
    FutureProvider<List<AchievementRow>>((ref) async {
  return ref.watch(gamificationRepositoryProvider).unlocked();
});
