import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: <Type>[
    UsageEvents,
    NotificationsTable,
    AppMeta,
    DailyAggregates,
    HourBuckets,
    DailyPhone,
    BehaviorEpisodes,
    FocusSessions,
    BlockRules,
    Achievements,
    Missions,
    PurposeUnlocks,
    MoodEntries,
    KeyValues,
    BlockOverrides,
    BlockSchedules,
  ],
)
class WxDatabase extends _$WxDatabase {
  WxDatabase() : super(_open());
  WxDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _safe(() async => m.createTable(blockOverrides));
        await _safe(() async => m.createTable(blockSchedules));
        await _safe(
          () async =>
              m.addColumn(focusSessions, focusSessions.productivityScore),
        );
      }
      if (from < 3) {
        // v3: behavioral history fields on daily_phone.
        await _safe(
          () async => m.addColumn(dailyPhone, dailyPhone.longestSessionMs),
        );
        await _safe(
          () async => m.addColumn(dailyPhone, dailyPhone.longestScreenOffMs),
        );
        await _safe(() async => m.addColumn(dailyPhone, dailyPhone.bingeCount));
        await _safe(
          () async => m.addColumn(dailyPhone, dailyPhone.firstAppPkg),
        );
        await _safe(() async => m.addColumn(dailyPhone, dailyPhone.lastAppPkg));
      }
      if (from < 4) {
        await _safe(() async => m.createTable(behaviorEpisodes));
      }
      await _safe(_createIndexes);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      // Ensure indexes exist on every open — cheap and self-healing.
      await _safe(_createIndexes);
    },
  );

  Future<void> _safe(Future<void> Function() op) async {
    try {
      await op();
    } catch (_) {
      // Idempotent migration: column / table may already exist on partial
      // upgrades. We swallow and let the rest proceed.
    }
  }

  Future<void> _createIndexes() async {
    // Hot-path index: dashboard reads usually filter on day_epoch.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_daily_agg_day ON daily_aggregates(day_epoch)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_daily_agg_pkg ON daily_aggregates(package_name)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_hour_day ON hour_buckets(day_epoch)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_focus_started ON focus_sessions(started_ms)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_notif_ts ON notifications(timestamp_ms)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_behavior_started ON behavior_episodes(started_at_ms)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_behavior_app ON behavior_episodes(app_package)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_purpose_ts ON purpose_unlocks(timestamp_ms)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_mood_ts ON mood_entries(timestamp_ms)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_block_override_ts ON block_overrides(timestamp_ms)',
    );
  }

  static QueryExecutor _open() {
    return driftDatabase(name: 'wellbeingx_db');
  }
}

final dbProvider = Provider<WxDatabase>((ref) {
  final db = WxDatabase();
  ref.onDispose(db.close);
  return db;
});
