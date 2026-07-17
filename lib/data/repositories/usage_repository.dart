import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/diagnostics.dart';
import '../../core/services/native_bridge.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/models/app_category.dart';
import '../../domain/models/daily_stats.dart';
import '../db/database.dart';

/// UsageStatsManager event constants we care about (Android).
class UsageEvt {
  static const int activityResumed = 1;
  static const int activityPaused = 2;
  static const int screenInteractive = 15;
  static const int screenNonInteractive = 16;
  static const int keyguardShown = 17;
  static const int keyguardHidden = 18;
  static const int notificationInterruption = 12;
}

const Duration _shortUnlockMax = Duration(seconds: 30);
const int _sleepStart = 23; // 11pm
const int _sleepEnd = 6; // 6am

/// Hard cap per-session foreground time. Real users almost never sit on a
/// single app for >2h continuously without ANY background event. If the OS
/// drops a paired pause event, our session length explodes — capping defends
/// against that overcount even when OEM aggregates are unavailable.
const int _maxSessionMs = 2 * 60 * 60 * 1000;

/// Hard cap per-app daily foreground. 14 hours/day on a single app is also a
/// strong signal that something leaked. Belt-and-braces in addition to session cap.
const int _maxAppDailyMs = 14 * 60 * 60 * 1000;

/// Surfaces that are not user-facing apps. We exclude these from screen-time
/// totals so our numbers match what Settings → Digital Wellbeing shows.
const Set<String> _excludedPackages = <String>{
  'com.mashingdesigns.wellbeingx', // never count ourselves
  'android',
  'com.android.systemui',
  'com.android.settings',
  'com.android.launcher',
  'com.android.launcher3',
  'com.google.android.apps.nexuslauncher',
  'com.bbk.launcher2',
  'com.miui.home',
  'com.oppo.launcher',
  'com.coloros.launcher',
  'com.realme.launcher',
  'com.huawei.android.launcher',
  'com.sec.android.app.launcher',
  'com.android.permissioncontroller',
  'com.google.android.permissioncontroller',
  'com.android.intentresolver',
};

bool _isExcludedPackage(String pkg) {
  if (_excludedPackages.contains(pkg)) return true;
  if (pkg.startsWith('com.android.')) return true;
  if (pkg.startsWith('android.')) return true;
  if (pkg.endsWith('.launcher')) return true;
  if (pkg.endsWith('.inputmethod')) return true;
  if (pkg.contains('.systemui')) return true;
  return false;
}

class _DayAccum {
  final Map<String, _AppAccum> perApp = <String, _AppAccum>{};
  final Map<int, int> hourFg = <int, int>{};
  final Map<int, int> hourUnlock = <int, int>{};
  int unlocks = 0;
  int screenOnMs = 0;
  int shortUnlocks = 0;
  int sleepMs = 0;
  int? firstUnlockMs;
  int? lastUnlockMs;
  // v3: continuous-usage history.
  /// Longest single foreground session of any non-system app.
  int longestSessionMs = 0;

  /// Longest gap between any two app sessions (proxy for "screen-off" period).
  int longestScreenOffMs = 0;

  /// First/last app the user opened on this day.
  String? firstAppPkg;
  String? lastAppPkg;

  /// Sessions on a distracting app longer than 30 minutes.
  int bingeCount = 0;

  /// Event-level texture waiting to be attached to the next foreground episode.
  int pendingUnlocks = 0;
  int pendingSwitches = 0;
}

/// Cross-day session bookkeeping. Kept outside [_DayAccum] (which is keyed
/// per calendar day) because the longest screen-off gap is almost always the
/// overnight one, spanning the boundary between two `_DayAccum`s.
class _SessionCursor {
  int? lastSessionEndMs;
}

class UsageRepository {
  UsageRepository(this._db, this._native);

  final WxDatabase _db;
  final NativeBridgeApi _native;

  // -------------------- Ingest pipeline --------------------

  /// Pulls events between [from] and [to] from UsageStatsManager,
  /// rebuilds aggregates per affected day, all in-memory, then writes
  /// in a single batched transaction.
  Future<void> ingest({DateTime? from, DateTime? to}) async {
    final end = to ?? DateTime.now();
    final start = from ?? end.subtract(const Duration(days: 14));

    final events = await _native.queryEvents(
      startMs: start.millisecondsSinceEpoch,
      endMs: end.millisecondsSinceEpoch,
    );

    // Always pull aggregate totals as a sanity floor. Some OEMs (Vivo, MIUI,
    // Honor) drop UsageEvents under aggressive battery management, but the
    // bucket-style `queryUsageStats` API still returns honest totals.
    final aggregates = await _native.queryAggregates(
      startMs: start.millisecondsSinceEpoch,
      endMs: end.millisecondsSinceEpoch,
    );

    if (events.isEmpty && aggregates.isEmpty) {
      await _refreshAppMeta();
      return;
    }

    events.sort(
      (a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int),
    );

    // Group events by day-epoch and accumulate.
    final accs = <int, _DayAccum>{};
    final episodes = <_BehaviorEpisodeDraft>[];
    final sessionCursor = _SessionCursor();
    int? activeStart;
    String? activeApp;
    int? screenOnAt;
    int? unlockAt;

    for (final e in events) {
      final t = e['timestamp'] as int;
      final type = (e['eventType'] as int?) ?? 0;
      final pkg = (e['packageName'] as String?) ?? 'unknown';
      final dt = DateTime.fromMillisecondsSinceEpoch(t);
      final dayEpoch = WxDates.dayEpoch(dt);
      final acc = accs.putIfAbsent(dayEpoch, _DayAccum.new);
      final h = dt.hour;

      switch (type) {
        case UsageEvt.activityResumed:
          if (activeApp != null && activeStart != null) {
            _attribute(accs, episodes, sessionCursor, activeApp, activeStart, t);
          }
          if (activeApp != null && activeApp != pkg) {
            acc.pendingSwitches += 1;
          }
          activeApp = pkg;
          activeStart = t;
          break;
        case UsageEvt.activityPaused:
          if (activeApp != null && activeStart != null) {
            _attribute(accs, episodes, sessionCursor, activeApp, activeStart, t);
            activeApp = null;
            activeStart = null;
          }
          break;
        case UsageEvt.screenInteractive:
          screenOnAt = t;
          break;
        case UsageEvt.screenNonInteractive:
          if (screenOnAt != null) {
            acc.screenOnMs += (t - screenOnAt).clamp(
              0,
              Duration.millisecondsPerDay,
            );
            screenOnAt = null;
          }
          break;
        case UsageEvt.keyguardHidden:
          acc.unlocks += 1;
          acc.firstUnlockMs ??= t;
          acc.lastUnlockMs = t;
          acc.hourUnlock.update(h, (v) => v + 1, ifAbsent: () => 1);
          unlockAt = t;
          acc.pendingUnlocks += 1;
          break;
        case UsageEvt.keyguardShown:
          if (unlockAt != null && t >= unlockAt) {
            final session = Duration(milliseconds: t - unlockAt);
            if (session <= _shortUnlockMax) acc.shortUnlocks += 1;
            unlockAt = null;
          }
          break;
      }
    }
    // Close any dangling foreground at "end".
    if (activeApp != null && activeStart != null) {
      _attribute(
        accs,
        episodes,
        sessionCursor,
        activeApp,
        activeStart,
        end.millisecondsSinceEpoch,
      );
    }

    // OEM aggregates are AUTHORITATIVE for daily per-app totals. They match
    // what Settings → Digital Wellbeing shows. Events are only used for hour
    // distribution. Without this, leaked-resume events can inflate totals 2×.
    if (aggregates.isNotEmpty) {
      // Group OEM totals by (dayEpoch, package). queryUsageStats may return
      // multiple buckets per app per day — sum them.
      final oemTotals = <int, Map<String, int>>{};
      final oemLastUsedHour = <int, Map<String, int>>{};
      for (final agg in aggregates) {
        final pkg = (agg['packageName'] as String?) ?? '';
        if (pkg.isEmpty) continue;
        // Skip system surfaces — same rationale as in _attribute().
        if (_isExcludedPackage(pkg)) continue;
        final totalMs = ((agg['totalForegroundMs'] as num?) ?? 0).toInt();
        if (totalMs <= 0) continue;
        // `lastTimeUsed` is the package's genuine last-used timestamp;
        // `lastTimeStamp` is only the end-of-day query-bucket boundary (see
        // MainActivity.kt), so it must never be preferred — using it first
        // pinned every OEM-aggregate fallback app to hour 23 (sleep window).
        final lastMs =
            ((agg['lastTimeUsed'] as num?) ??
                    (agg['lastTimeStamp'] as num?) ??
                    end.millisecondsSinceEpoch)
                .toInt();
        final dayEpoch = WxDates.dayEpoch(
          DateTime.fromMillisecondsSinceEpoch(lastMs),
        );
        oemTotals
            .putIfAbsent(dayEpoch, () => <String, int>{})
            .update(pkg, (v) => v + totalMs, ifAbsent: () => totalMs);
        oemLastUsedHour
            .putIfAbsent(dayEpoch, () => <String, int>{})
            .update(
              pkg,
              (_) => DateTime.fromMillisecondsSinceEpoch(lastMs).hour,
              ifAbsent: () => DateTime.fromMillisecondsSinceEpoch(lastMs).hour,
            );
      }

      // For each day with OEM data, override per-app foreground time and
      // re-distribute the hour buckets proportionally to whatever event-based
      // distribution we have. If no events for that app, dump it in lastUsed
      // hour as a single block.
      for (final entry in oemTotals.entries) {
        final dayEpoch = entry.key;
        final pkgTotals = entry.value;
        final acc = accs.putIfAbsent(dayEpoch, _DayAccum.new);

        // Capture the prior hour distribution per package so we can rescale.
        // We reconstruct from acc.perApp[pkg].fgMs and the day's hour totals.
        // Simpler: reset hour bucket totals and rebuild from scratch using
        // event proportions when present, else lastUsed hour.
        final priorPerAppHourShares = <String, Map<int, double>>{};
        for (final pkgEntry in acc.perApp.entries) {
          final pkg = pkgEntry.key;
          final app = pkgEntry.value;
          if (app.fgMs <= 0) continue;
          // Approximate per-app hour share by scaling the day's hour buckets
          // by this app's share of total foreground time before override.
          final totalDayMs = acc.perApp.values.fold<int>(
            0,
            (a, b) => a + b.fgMs,
          );
          if (totalDayMs <= 0) continue;
          final appShare = app.fgMs / totalDayMs;
          final shares = <int, double>{};
          acc.hourFg.forEach((h, ms) {
            shares[h] = ms * appShare;
          });
          priorPerAppHourShares[pkg] = shares;
        }

        // Reset day-level hour buckets and rebuild from OEM totals.
        acc.hourFg.clear();
        acc.sleepMs = 0;

        for (final pkgEntry in pkgTotals.entries) {
          final pkg = pkgEntry.key;
          final oemMs = pkgEntry.value;
          // Override the per-app foreground.
          final app = acc.perApp[pkg] ?? (_AppAccum()..opens = 1);
          app.fgMs = oemMs;
          if (acc.perApp[pkg] == null) acc.perApp[pkg] = app;

          // Distribute oemMs across hour buckets.
          final shares = priorPerAppHourShares[pkg];
          if (shares != null && shares.isNotEmpty) {
            final shareTotal = shares.values.fold<double>(0, (a, b) => a + b);
            if (shareTotal > 0) {
              shares.forEach((h, share) {
                final ms = ((share / shareTotal) * oemMs).round();
                acc.hourFg.update(h, (v) => v + ms, ifAbsent: () => ms);
                if (h >= _sleepStart || h < _sleepEnd) {
                  acc.sleepMs += ms;
                }
              });
              continue;
            }
          }
          // No event-based distribution — single block at lastUsed hour.
          final h = oemLastUsedHour[dayEpoch]?[pkg] ?? 12;
          acc.hourFg.update(h, (v) => v + oemMs, ifAbsent: () => oemMs);
          if (h >= _sleepStart || h < _sleepEnd) {
            acc.sleepMs += oemMs;
          }
        }

        // Drop any per-app entries that weren't reported by OEM aggregates —
        // those were almost certainly stale event-leaks.
        acc.perApp.removeWhere((pkg, _) => !pkgTotals.containsKey(pkg));
      }
    }

    // Pre-fetch existing notifications by day to merge.
    final dayKeys = accs.keys.toList();
    final notifsByDayApp = <int, Map<String, int>>{};
    final notifTimesByPkg = <String, List<int>>{};
    if (dayKeys.isNotEmpty) {
      final firstDayMs = WxDates.fromDayEpoch(
        dayKeys.reduce((a, b) => a < b ? a : b),
      ).millisecondsSinceEpoch;
      final lastDayMs =
          WxDates.fromDayEpoch(
            dayKeys.reduce((a, b) => a > b ? a : b),
          ).millisecondsSinceEpoch +
          Duration.millisecondsPerDay;
      final rows =
          await (_db.select(_db.notificationsTable)..where(
                (t) => t.timestampMs.isBetweenValues(firstDayMs, lastDayMs - 1),
              ))
              .get();
      for (final r in rows) {
        final d = WxDates.dayEpoch(
          DateTime.fromMillisecondsSinceEpoch(r.timestampMs),
        );
        notifsByDayApp
            .putIfAbsent(d, () => <String, int>{})
            .update(r.packageName, (v) => v + 1, ifAbsent: () => 1);
        notifTimesByPkg
            .putIfAbsent(r.packageName, () => <int>[])
            .add(r.timestampMs);
      }
    }

    for (int i = 0; i < episodes.length; i++) {
      final times = notifTimesByPkg[episodes[i].appPackage];
      if (times == null || times.isEmpty) continue;
      final count = times
          .where(
            (ts) =>
                ts >=
                    episodes[i].startedAtMs -
                        const Duration(minutes: 10).inMilliseconds &&
                ts <= episodes[i].endedAtMs,
          )
          .length;
      if (count == 0) continue;
      episodes[i] = episodes[i].copyWithNotificationContext(count);
    }

    // One transaction, batched inserts. We wipe ALL days within the query
    // window (not just days we have new data for) so any stale rows from
    // previous buggy ingest passes are cleared. Days entirely outside the
    // window keep their stored values so we don't lose long-term history.
    final windowStart = WxDates.dayEpoch(start);
    final windowEnd = WxDates.dayEpoch(end);
    await _db.transaction(() async {
      await (_db.delete(
        _db.dailyAggregates,
      )..where((t) => t.dayEpoch.isBetweenValues(windowStart, windowEnd))).go();
      await (_db.delete(
        _db.hourBuckets,
      )..where((t) => t.dayEpoch.isBetweenValues(windowStart, windowEnd))).go();
      await (_db.delete(
        _db.dailyPhone,
      )..where((t) => t.dayEpoch.isBetweenValues(windowStart, windowEnd))).go();
      await (_db.delete(_db.behaviorEpisodes)..where(
            (t) => t.startedAtMs.isBetweenValues(
              start.millisecondsSinceEpoch,
              end.millisecondsSinceEpoch,
            ),
          ))
          .go();

      await _db.batch((b) {
        accs.forEach((dayEpoch, acc) {
          final notifs = notifsByDayApp[dayEpoch] ?? const <String, int>{};
          for (final entry in acc.perApp.entries) {
            // Cap per-app daily foreground to a sane ceiling. Belt-and-braces:
            // leaked sessions are already capped, but if many resumes arrived
            // without pauses, totals could still drift.
            final fgMs = entry.value.fgMs > _maxAppDailyMs
                ? _maxAppDailyMs
                : entry.value.fgMs;
            b.insert(
              _db.dailyAggregates,
              DailyAggregatesCompanion.insert(
                dayEpoch: dayEpoch,
                packageName: entry.key,
                foregroundMs: Value<int>(fgMs),
                opens: Value<int>(entry.value.opens),
                notifications: Value<int>(notifs[entry.key] ?? 0),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
          for (int h = 0; h < 24; h++) {
            b.insert(
              _db.hourBuckets,
              HourBucketsCompanion.insert(
                dayEpoch: dayEpoch,
                hour: h,
                foregroundMs: Value<int>(acc.hourFg[h] ?? 0),
                unlocks: Value<int>(acc.hourUnlock[h] ?? 0),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
          b.insert(
            _db.dailyPhone,
            DailyPhoneCompanion.insert(
              dayEpoch: Value<int>(dayEpoch),
              unlocks: Value<int>(acc.unlocks),
              screenOnMs: Value<int>(acc.screenOnMs),
              pickups: Value<int>(acc.unlocks),
              shortUnlocks: Value<int>(acc.shortUnlocks),
              sleepMisuseMs: Value<int>(acc.sleepMs),
              firstUnlockMs: Value<int?>(acc.firstUnlockMs),
              lastUnlockMs: Value<int?>(acc.lastUnlockMs),
              longestSessionMs: Value<int>(acc.longestSessionMs),
              longestScreenOffMs: Value<int>(acc.longestScreenOffMs),
              bingeCount: Value<int>(acc.bingeCount),
              firstAppPkg: Value<String?>(acc.firstAppPkg),
              lastAppPkg: Value<String?>(acc.lastAppPkg),
            ),
            mode: InsertMode.insertOrReplace,
          );
        });
        for (final episode in episodes) {
          b.insert(
            _db.behaviorEpisodes,
            BehaviorEpisodesCompanion.insert(
              startedAtMs: episode.startedAtMs,
              endedAtMs: episode.endedAtMs,
              appPackage: episode.appPackage,
              interactionCount: Value<int>(episode.interactionCount),
              unlockCount: Value<int>(episode.unlockCount),
              notificationTriggered: Value<bool>(episode.notificationTriggered),
              appSwitches: Value<int>(episode.appSwitches),
              passiveDurationMs: Value<int>(episode.passiveDurationMs),
              activeDurationMs: Value<int>(episode.activeDurationMs),
              interruptionCount: Value<int>(episode.interruptionCount),
              classification: Value<String>(episode.classification),
            ),
          );
        }
      });
    });

    // Refresh installed-app metadata too (cheap; small list).
    await _refreshAppMeta();
  }

  void _attribute(
    Map<int, _DayAccum> accs,
    List<_BehaviorEpisodeDraft> episodes,
    _SessionCursor cursor,
    String pkg,
    int startMs,
    int endMs,
  ) {
    if (endMs <= startMs) return;
    if (_isExcludedPackage(pkg)) return;
    if (endMs - startMs > _maxSessionMs) {
      endMs = startMs + _maxSessionMs;
    }

    // ---- Per-session level metrics (assigned to the day where the session began) ----
    final sessionMs = endMs - startMs;
    final dt0 = DateTime.fromMillisecondsSinceEpoch(startMs);
    final accStart = accs.putIfAbsent(WxDates.dayEpoch(dt0), _DayAccum.new);
    final passiveMs = _passiveMs(pkg, startMs, sessionMs);
    final unlocks = accStart.pendingUnlocks;
    final switches = accStart.pendingSwitches;
    accStart.pendingUnlocks = 0;
    accStart.pendingSwitches = 0;

    episodes.add(
      _BehaviorEpisodeDraft(
        startedAtMs: startMs,
        endedAtMs: endMs,
        appPackage: pkg,
        interactionCount: 1,
        unlockCount: unlocks,
        notificationTriggered: false,
        appSwitches: switches,
        passiveDurationMs: passiveMs,
        activeDurationMs: sessionMs - passiveMs,
        interruptionCount: 0,
        classification: _episodeClassification(pkg, startMs, sessionMs),
      ),
    );

    // Screen-off gap tracked across the whole ingest window (not per day) —
    // the longest gap is almost always the overnight one spanning midnight,
    // which a per-day accumulator can never see since the next day always
    // starts with a fresh, gap-less accumulator.
    if (cursor.lastSessionEndMs != null) {
      final gap = startMs - cursor.lastSessionEndMs!;
      if (gap > accStart.longestScreenOffMs) {
        accStart.longestScreenOffMs = gap;
      }
    }
    cursor.lastSessionEndMs = endMs;

    accStart.firstAppPkg ??= pkg;
    accStart.lastAppPkg = pkg;

    // ---- Day-clipped session/binge metrics (a session crossing midnight is
    // split at the boundary, consistent with how foreground time is split
    // in the per-segment loop below) ----
    int dayCursor = startMs;
    while (dayCursor < endMs) {
      final dt = DateTime.fromMillisecondsSinceEpoch(dayCursor);
      final dayEpoch = WxDates.dayEpoch(dt);
      final dayStart = WxDates.fromDayEpoch(dayEpoch).millisecondsSinceEpoch;
      final dayEnd = dayStart + Duration.millisecondsPerDay;
      final segEnd = endMs < dayEnd ? endMs : dayEnd;
      final daySessionMs = segEnd - dayCursor;
      final acc = accs.putIfAbsent(dayEpoch, _DayAccum.new);
      if (daySessionMs > acc.longestSessionMs) {
        acc.longestSessionMs = daySessionMs;
      }
      if (daySessionMs >= 30 * 60 * 1000 &&
          CategoryHeuristics.classify(pkg).isDistracting) {
        acc.bingeCount += 1;
      }
      dayCursor = segEnd;
    }

    // ---- Per-segment slicing (hour buckets, sleep window, app aggregate) ----
    int segCursor = startMs;
    while (segCursor < endMs) {
      final dt = DateTime.fromMillisecondsSinceEpoch(segCursor);
      final dayEpoch = WxDates.dayEpoch(dt);
      final dayStart = WxDates.fromDayEpoch(dayEpoch).millisecondsSinceEpoch;
      final dayEnd = dayStart + Duration.millisecondsPerDay;
      final hourStart =
          (segCursor ~/ Duration.millisecondsPerHour) *
          Duration.millisecondsPerHour;
      final hourEnd = hourStart + Duration.millisecondsPerHour;
      final segEnd = <int>[
        endMs,
        dayEnd,
        hourEnd,
      ].reduce((a, b) => a < b ? a : b);
      final segMs = segEnd - segCursor;
      if (segMs <= 0) break;
      final acc = accs.putIfAbsent(dayEpoch, _DayAccum.new);
      final app = acc.perApp.putIfAbsent(pkg, _AppAccum.new);
      app.fgMs += segMs;
      if (segCursor == startMs) app.opens += 1;
      acc.hourFg.update(dt.hour, (v) => v + segMs, ifAbsent: () => segMs);
      if (dt.hour >= _sleepStart || dt.hour < _sleepEnd) {
        acc.sleepMs += segMs;
      }
      segCursor = segEnd;
    }
  }

  Future<void> _refreshAppMeta() async {
    const lastCheckKey = 'app_meta.last_check';
    final now = DateTime.now().millisecondsSinceEpoch;
    final row = await (_db.select(_db.keyValues)
          ..where((t) => t.key.equals(lastCheckKey)))
        .getSingleOrNull();
    if (row != null) {
      final lastChecked = int.tryParse(row.value) ?? 0;
      if (now - lastChecked < const Duration(hours: 24).inMilliseconds) {
        WxLog.info('app-meta', 'skipped refresh: last checked less than 24h ago');
        return;
      }
    }

    final apps = await _native.listInstalledApps();
    if (apps.isEmpty) return;
    await _db.batch((b) {
      for (final a in apps) {
        final pkg = a['packageName'] as String? ?? '';
        if (pkg.isEmpty) continue;
        final name = (a['displayName'] as String?) ?? pkg;
        final cat =
            (a['category'] as String?) ??
            CategoryHeuristics.classify(pkg, name).code;
        b.insert(
          _db.appMeta,
          AppMetaCompanion.insert(
            packageName: pkg,
            displayName: name,
            category: Value<String>(cat),
            installedAtMs: Value<int>(
              ((a['installedAtMs'] as num?) ?? 0).toInt(),
            ),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await _db.into(_db.keyValues).insert(
          KeyValuesCompanion.insert(
            key: lastCheckKey,
            value: now.toString(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  // -------------------- Read API --------------------

  DailyStats _assembleStats({
    required DateTime day,
    required DailyPhoneRow? phone,
    required List<DailyAggRow> aggs,
    required List<HourBucketRow> hours,
    required Map<String, AppMetaRow> metaByPkg,
  }) {
    final apps = aggs
        .map((a) {
          final m = metaByPkg[a.packageName];
          return AppUsage(
            packageName: a.packageName,
            displayName: m?.displayName ?? a.packageName,
            category: AppCategory.fromCode(m?.category),
            foreground: Duration(milliseconds: a.foregroundMs),
            opens: a.opens,
            notifications: a.notifications,
          );
        })
        .toList(growable: false);

    final byCategory = <AppCategory, Duration>{};
    for (final a in apps) {
      byCategory.update(
        a.category,
        (v) => v + a.foreground,
        ifAbsent: () => a.foreground,
      );
    }
    final hourMap = <int, Duration>{
      for (final h in hours) h.hour: Duration(milliseconds: h.foregroundMs),
    };
    final totalScreen = apps.fold<Duration>(
      Duration.zero,
      (acc, a) => acc + a.foreground,
    );
    return DailyStats(
      day: WxDates.startOfDay(day),
      screenTime: totalScreen,
      unlocks: phone?.unlocks ?? 0,
      pickups: phone?.pickups ?? 0,
      shortUnlocks: phone?.shortUnlocks ?? 0,
      sleepMisuse: Duration(milliseconds: phone?.sleepMisuseMs ?? 0),
      apps: apps,
      hourBuckets: hourMap,
      byCategory: byCategory,
      notifications: apps.fold<int>(0, (a, b) => a + b.notifications),
      firstUnlockMs: phone?.firstUnlockMs,
      lastUnlockMs: phone?.lastUnlockMs,
      longestSession: Duration(milliseconds: phone?.longestSessionMs ?? 0),
      longestScreenOff: Duration(milliseconds: phone?.longestScreenOffMs ?? 0),
      bingeCount: phone?.bingeCount ?? 0,
      firstAppPkg: phone?.firstAppPkg,
      lastAppPkg: phone?.lastAppPkg,
    );
  }

  Future<DailyStats> dayStats(DateTime day) async {
    final dayEpoch = WxDates.dayEpoch(day);
    final phone = await (_db.select(
      _db.dailyPhone,
    )..where((t) => t.dayEpoch.equals(dayEpoch))).getSingleOrNull();
    final aggs =
        await (_db.select(_db.dailyAggregates)
              ..where((t) => t.dayEpoch.equals(dayEpoch))
              ..orderBy([(t) => OrderingTerm.desc(t.foregroundMs)]))
            .get();
    final hours = await (_db.select(
      _db.hourBuckets,
    )..where((t) => t.dayEpoch.equals(dayEpoch))).get();
    final metas = await _db.select(_db.appMeta).get();
    final metaByPkg = <String, AppMetaRow>{
      for (final m in metas) m.packageName: m,
    };

    return _assembleStats(
      day: day,
      phone: phone,
      aggs: aggs,
      hours: hours,
      metaByPkg: metaByPkg,
    );
  }

  Future<List<DailyStats>> rangeStats(int days) async {
    final today = DateTime.now();
    final startEpoch = WxDates.dayEpoch(today.subtract(Duration(days: days - 1)));
    final endEpoch = WxDates.dayEpoch(today);

    final phones = await (_db.select(_db.dailyPhone)
          ..where((t) => t.dayEpoch.isBetweenValues(startEpoch, endEpoch)))
        .get();
    final aggs = await (_db.select(_db.dailyAggregates)
          ..where((t) => t.dayEpoch.isBetweenValues(startEpoch, endEpoch))
          ..orderBy([(t) => OrderingTerm.desc(t.foregroundMs)]))
        .get();
    final hours = await (_db.select(_db.hourBuckets)
          ..where((t) => t.dayEpoch.isBetweenValues(startEpoch, endEpoch)))
        .get();
    final metas = await _db.select(_db.appMeta).get();

    final metaByPkg = <String, AppMetaRow>{
      for (final m in metas) m.packageName: m,
    };
    final phoneMap = <int, DailyPhoneRow>{
      for (final p in phones) p.dayEpoch: p,
    };
    final aggsMap = <int, List<DailyAggRow>>{};
    for (final a in aggs) {
      aggsMap.putIfAbsent(a.dayEpoch, () => <DailyAggRow>[]).add(a);
    }
    final hoursMap = <int, List<HourBucketRow>>{};
    for (final h in hours) {
      hoursMap.putIfAbsent(h.dayEpoch, () => <HourBucketRow>[]).add(h);
    }

    final out = <DailyStats>[];
    for (int i = days - 1; i >= 0; i--) {
      final targetDay = today.subtract(Duration(days: i));
      final epoch = WxDates.dayEpoch(targetDay);
      out.add(_assembleStats(
        day: targetDay,
        phone: phoneMap[epoch],
        aggs: aggsMap[epoch] ?? <DailyAggRow>[],
        hours: hoursMap[epoch] ?? <HourBucketRow>[],
        metaByPkg: metaByPkg,
      ));
    }
    return out;
  }

  Future<Duration> lifetimeScreenTime() async {
    final res = await _db
        .customSelect(
          'SELECT COALESCE(SUM(foreground_ms), 0) AS total FROM daily_aggregates',
          readsFrom: {_db.dailyAggregates},
        )
        .getSingle();
    final total = res.read<int?>('total') ?? 0;
    return Duration(milliseconds: total);
  }

  Future<List<AppMetaRow>> unusedApps({
    Duration window = const Duration(days: 30),
  }) async {
    final cutoff = WxDates.dayEpoch(DateTime.now().subtract(window));
    final usedPkgsRows =
        await (_db.selectOnly(_db.dailyAggregates, distinct: true)
              ..addColumns([_db.dailyAggregates.packageName])
              ..where(
                _db.dailyAggregates.dayEpoch.isBiggerOrEqualValue(cutoff),
              ))
            .get();
    final used = usedPkgsRows
        .map((r) => r.read(_db.dailyAggregates.packageName))
        .whereType<String>()
        .toSet();
    final all = await _db.select(_db.appMeta).get();
    return all.where((m) => !used.contains(m.packageName)).toList();
  }

  Future<void> recordNotification(String pkg, [DateTime? at]) async {
    final t = at ?? DateTime.now();
    final dayEpoch = WxDates.dayEpoch(t);
    await _db.transaction(() async {
      await _db
          .into(_db.notificationsTable)
          .insert(
            NotificationsTableCompanion.insert(
              packageName: pkg,
              timestampMs: t.millisecondsSinceEpoch,
            ),
          );

      final existing =
          await (_db.select(_db.dailyAggregates)..where(
                (row) =>
                    row.dayEpoch.equals(dayEpoch) & row.packageName.equals(pkg),
              ))
              .getSingleOrNull();
      await _db
          .into(_db.dailyAggregates)
          .insert(
            DailyAggregatesCompanion.insert(
              dayEpoch: dayEpoch,
              packageName: pkg,
              foregroundMs: Value<int>(existing?.foregroundMs ?? 0),
              opens: Value<int>(existing?.opens ?? 0),
              notifications: Value<int>((existing?.notifications ?? 0) + 1),
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
  }

  Future<int> drainPendingNotifications() async {
    final events = await _native.drainPendingNotifications();
    var recorded = 0;
    for (final event in events) {
      final pkg = event['packageName'] as String?;
      if (pkg == null || pkg.isEmpty) continue;
      final ts = (event['timestamp'] as num?)?.toInt();
      await recordNotification(
        pkg,
        ts == null ? null : DateTime.fromMillisecondsSinceEpoch(ts),
      );
      recorded++;
    }
    return recorded;
  }

  Future<bool> recordNativeEvent(Map<String, dynamic> event) async {
    if (event['type'] != 'notification.posted') return false;
    final pkg = event['packageName'] as String?;
    if (pkg == null || pkg.isEmpty) return false;
    final ts = (event['timestamp'] as num?)?.toInt();
    await recordNotification(
      pkg,
      ts == null ? null : DateTime.fromMillisecondsSinceEpoch(ts),
    );
    return true;
  }

  int _passiveMs(String pkg, int startMs, int sessionMs) {
    final cat = CategoryHeuristics.classify(pkg);
    final h = DateTime.fromMillisecondsSinceEpoch(startMs).hour;
    final late = h >= 22 || h < 6;
    if (sessionMs < 20 * 60 * 1000) return 0;
    if (cat == AppCategory.entertainment || (cat.isDistracting && late)) {
      return (sessionMs * 0.55).round();
    }
    return 0;
  }

  String _episodeClassification(String pkg, int startMs, int sessionMs) {
    final cat = CategoryHeuristics.classify(pkg);
    final h = DateTime.fromMillisecondsSinceEpoch(startMs).hour;
    final late = h >= 22 || h < 6;
    if (sessionMs < 20 * 1000) return 'residue';
    if (sessionMs < 90 * 1000) return 'check';
    if (late && cat.isDistracting && sessionMs >= 5 * 60 * 1000) {
      return 'drift';
    }
    if (cat.isProductive && sessionMs >= 10 * 60 * 1000) return 'focused';
    if (sessionMs >= 30 * 60 * 1000 && cat == AppCategory.entertainment) {
      return 'passive';
    }
    if (sessionMs >= 20 * 60 * 1000) return 'immersive';
    return 'neutral';
  }
}

class _AppAccum {
  int fgMs = 0;
  int opens = 0;
}

class _BehaviorEpisodeDraft {
  final int startedAtMs;
  final int endedAtMs;
  final String appPackage;
  final int interactionCount;
  final int unlockCount;
  final bool notificationTriggered;
  final int appSwitches;
  final int passiveDurationMs;
  final int activeDurationMs;
  final int interruptionCount;
  final String classification;

  const _BehaviorEpisodeDraft({
    required this.startedAtMs,
    required this.endedAtMs,
    required this.appPackage,
    required this.interactionCount,
    required this.unlockCount,
    required this.notificationTriggered,
    required this.appSwitches,
    required this.passiveDurationMs,
    required this.activeDurationMs,
    required this.interruptionCount,
    required this.classification,
  });

  _BehaviorEpisodeDraft copyWithNotificationContext(int count) {
    return _BehaviorEpisodeDraft(
      startedAtMs: startedAtMs,
      endedAtMs: endedAtMs,
      appPackage: appPackage,
      interactionCount: interactionCount,
      unlockCount: unlockCount,
      notificationTriggered: true,
      appSwitches: appSwitches,
      passiveDurationMs: passiveDurationMs,
      activeDurationMs: activeDurationMs,
      interruptionCount: interruptionCount + count,
      classification: classification,
    );
  }
}

final usageRepositoryProvider = Provider<UsageRepository>((ref) {
  return UsageRepository(
    ref.watch(dbProvider),
    ref.watch(nativeBridgeProvider),
  );
});

final notificationRevisionProvider = StateProvider<int>((ref) => 0);
