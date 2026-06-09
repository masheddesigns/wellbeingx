import 'package:drift/drift.dart';

/// Raw usage events from UsageStatsManager (start/stop) — append-only.
@DataClassName('UsageEventRow')
class UsageEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  IntColumn get eventType =>
      integer()(); // 1=resumed, 2=paused, 18=screenOn, 19=screenOff, 12=keyguardShown, 13=keyguardHidden
  IntColumn get timestampMs => integer()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get className => text().nullable()();
}

/// Notifications observed.
@DataClassName('NotificationRow')
class NotificationsTable extends Table {
  @override
  String get tableName => 'notifications';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  IntColumn get timestampMs => integer()();
}

/// Per-app metadata (display label, category override, blocking flag).
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get packageName => text()();
  TextColumn get displayName => text()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  BoolColumn get isUserOverride =>
      boolean().withDefault(const Constant(false))();
  IntColumn get installedAtMs => integer().withDefault(const Constant(0))();
  TextColumn get iconBase64 => text().nullable()();
  @override
  Set<Column> get primaryKey => {packageName};
}

/// Daily aggregates — fast lookup for charts.
@DataClassName('DailyAggRow')
class DailyAggregates extends Table {
  IntColumn get dayEpoch => integer()(); // days since epoch
  TextColumn get packageName => text()();
  IntColumn get foregroundMs => integer().withDefault(const Constant(0))();
  IntColumn get opens => integer().withDefault(const Constant(0))();
  IntColumn get notifications => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {dayEpoch, packageName};
}

/// Per-hour bucket — heatmap.
@DataClassName('HourBucketRow')
class HourBuckets extends Table {
  IntColumn get dayEpoch => integer()();
  IntColumn get hour => integer()(); // 0..23
  IntColumn get foregroundMs => integer().withDefault(const Constant(0))();
  IntColumn get unlocks => integer().withDefault(const Constant(0))();
  IntColumn get pickups => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {dayEpoch, hour};
}

/// Daily phone-level metrics (unlocks, screen on time, etc.)
@DataClassName('DailyPhoneRow')
class DailyPhone extends Table {
  IntColumn get dayEpoch => integer()();
  IntColumn get unlocks => integer().withDefault(const Constant(0))();
  IntColumn get screenOnMs => integer().withDefault(const Constant(0))();
  IntColumn get pickups => integer().withDefault(const Constant(0))();
  IntColumn get shortUnlocks =>
      integer().withDefault(const Constant(0))(); // <30s sessions
  IntColumn get sleepMisuseMs =>
      integer().withDefault(const Constant(0))(); // usage during 11pm-6am
  IntColumn get firstUnlockMs => integer().nullable()();
  IntColumn get lastUnlockMs => integer().nullable()();
  // v3: behavioral depth
  IntColumn get longestSessionMs => integer().withDefault(const Constant(0))();
  IntColumn get longestScreenOffMs =>
      integer().withDefault(const Constant(0))();
  IntColumn get bingeCount => integer().withDefault(const Constant(0))();
  TextColumn get firstAppPkg => text().nullable()();
  TextColumn get lastAppPkg => text().nullable()();
  @override
  Set<Column> get primaryKey => {dayEpoch};
}

/// Persistent behavioral timeline. Episodes are intentionally conservative:
/// they describe observable phone behavior, not psychological certainty.
@DataClassName('BehaviorEpisodeRow')
class BehaviorEpisodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get startedAtMs => integer()();
  IntColumn get endedAtMs => integer()();
  TextColumn get appPackage => text()();
  IntColumn get interactionCount => integer().withDefault(const Constant(1))();
  IntColumn get unlockCount => integer().withDefault(const Constant(0))();
  BoolColumn get notificationTriggered =>
      boolean().withDefault(const Constant(false))();
  IntColumn get appSwitches => integer().withDefault(const Constant(0))();
  IntColumn get passiveDurationMs => integer().withDefault(const Constant(0))();
  IntColumn get activeDurationMs => integer().withDefault(const Constant(0))();
  IntColumn get interruptionCount => integer().withDefault(const Constant(0))();
  TextColumn get classification =>
      text().withDefault(const Constant('neutral'))();
}

/// Focus sessions — Pomodoro and deep work.
@DataClassName('FocusSessionRow')
class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get startedMs => integer()();
  IntColumn get plannedMs => integer()();
  IntColumn get actualMs => integer().withDefault(const Constant(0))();
  TextColumn get mode => text().withDefault(
    const Constant('pomodoro'),
  )(); // pomodoro|deep|stayaway|study|coding|workout|custom
  TextColumn get tag => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get xpAwarded => integer().withDefault(const Constant(0))();
  IntColumn get coinsAwarded => integer().withDefault(const Constant(0))();
  IntColumn get interruptions => integer().withDefault(const Constant(0))();
  IntColumn get productivityScore =>
      integer().withDefault(const Constant(0))(); // 0..100
  TextColumn get note => text().nullable()();
}

/// Stay-Away rules (blocking).
@DataClassName('BlockRuleRow')
class BlockRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  TextColumn get mode => text()(); // soft|hard|extreme
  IntColumn get untilMs => integer().nullable()(); // null = always
  IntColumn get dailyLimitMs => integer().nullable()(); // optional per-day cap
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get createdMs => integer()();
}

/// Unlocked achievements.
@DataClassName('AchievementRow')
class Achievements extends Table {
  TextColumn get code => text()();
  IntColumn get unlockedAtMs => integer()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {code};
}

/// Daily mission progress.
@DataClassName('MissionRow')
class Missions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dayEpoch => integer()();
  TextColumn get code => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get target => integer()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  IntColumn get xpReward => integer()();
  IntColumn get coinsReward => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get claimed => boolean().withDefault(const Constant(false))();
}

/// Purpose unlock answers — why are you opening this app?
@DataClassName('PurposeRow')
class PurposeUnlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get timestampMs => integer()();
  TextColumn get packageName => text()();
  TextColumn get purpose => text()(); // work|habit|bored|reply|just_checking
  IntColumn get followUpDurationMs => integer().nullable()();
}

/// Mood entries — manual or post-session.
@DataClassName('MoodRow')
class MoodEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get timestampMs => integer()();
  IntColumn get score => integer()(); // 1..5
  TextColumn get tag => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// Key-value settings (gamification snapshot, ghost mode, prefs).
@DataClassName('KvRow')
class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

/// Anti-cheat: each time the user breaks through a Stay-Away rule, log it.
/// We use this to compute streak penalties and surface "bypass habit" insights.
@DataClassName('BlockOverrideRow')
class BlockOverrides extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get timestampMs => integer()();
  TextColumn get packageName => text()();
  TextColumn get mode => text()(); // soft|hard|extreme
  IntColumn get xpPenalty => integer().withDefault(const Constant(0))();
  IntColumn get coinPenalty => integer().withDefault(const Constant(0))();
}

/// Time-of-day block schedules. e.g. "block IG between 22:00–06:00".
@DataClassName('BlockScheduleRow')
class BlockSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  IntColumn get startMinute => integer()(); // minutes since midnight (0..1439)
  IntColumn get endMinute => integer()();
  IntColumn get daysMask => integer()(); // bitmask Mon=1, Tue=2, ... Sun=64
  TextColumn get mode => text().withDefault(const Constant('hard'))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}
