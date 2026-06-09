import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single MethodChannel to native Android — `wellbeingx/native`.
/// Exposes UsageStatsManager queries, Accessibility-based blocking,
/// notification listener controls, and foreground-service controls.
class NativeBridge {
  NativeBridge._();

  static const MethodChannel _channel = MethodChannel('wellbeingx/native');

  // -------- Permissions --------
  static Future<bool> hasUsageAccess() async =>
      (await _channel.invokeMethod<bool>('perm.hasUsageAccess')) ?? false;

  static Future<void> openUsageAccessSettings() =>
      _channel.invokeMethod<void>('perm.openUsageAccess');

  static Future<bool> hasAccessibility() async =>
      (await _channel.invokeMethod<bool>('perm.hasAccessibility')) ?? false;

  static Future<void> openAccessibilitySettings() =>
      _channel.invokeMethod<void>('perm.openAccessibility');

  static Future<bool> hasNotificationAccess() async =>
      (await _channel.invokeMethod<bool>('perm.hasNotificationAccess')) ??
      false;

  static Future<void> openNotificationListenerSettings() =>
      _channel.invokeMethod<void>('perm.openNotificationListener');

  static Future<bool> isIgnoringBatteryOptimizations() async =>
      (await _channel.invokeMethod<bool>('perm.isIgnoringBatteryOpts')) ??
      false;

  static Future<void> requestIgnoreBatteryOptimizations() =>
      _channel.invokeMethod<void>('perm.requestIgnoreBatteryOpts');

  // -------- Usage queries (raw events) --------
  /// Returns event maps: { packageName, eventType, timestamp, className }.
  /// eventType uses UsageEvents.* constants from Android.
  static Future<List<Map<String, dynamic>>> queryEvents({
    required int startMs,
    required int endMs,
  }) async {
    final list = await _channel.invokeMethod<List<dynamic>>(
      'usage.queryEvents',
      <String, dynamic>{'startMs': startMs, 'endMs': endMs},
    );
    if (list == null) return <Map<String, dynamic>>[];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  /// Robust fallback: per-app daily foreground totals from UsageStatsManager.
  /// Values: { packageName, totalForegroundMs, firstTimeStamp, lastTimeStamp, lastTimeUsed }
  static Future<List<Map<String, dynamic>>> queryAggregates({
    required int startMs,
    required int endMs,
  }) async {
    final list = await _channel.invokeMethod<List<dynamic>>(
      'usage.queryAggregates',
      <String, dynamic>{'startMs': startMs, 'endMs': endMs},
    );
    if (list == null) return <Map<String, dynamic>>[];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  /// Returns app metadata maps: { packageName, displayName, category, installedAtMs, isSystem }.
  static Future<List<Map<String, dynamic>>> listInstalledApps() async {
    final list = await _channel.invokeMethod<List<dynamic>>('apps.list');
    if (list == null) return <Map<String, dynamic>>[];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  /// Returns notification listener events captured while Flutter was detached.
  static Future<List<Map<String, dynamic>>> drainPendingNotifications() async {
    final list = await _channel.invokeMethod<List<dynamic>>(
      'notifications.drainPending',
    );
    if (list == null) return <Map<String, dynamic>>[];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  /// Returns a PNG icon for [packageName], or null if unavailable.
  static Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final bytes = await _channel.invokeMethod<Uint8List>(
        'apps.icon',
        <String, dynamic>{'packageName': packageName},
      );
      return bytes;
    } catch (_) {
      return null;
    }
  }

  // -------- Blocking --------
  static Future<void> setBlockedPackages(
    List<String> packages, {
    required String mode, // soft|hard|extreme
    int? untilMs,
  }) => _channel.invokeMethod<void>('block.set', <String, dynamic>{
    'packages': packages,
    'mode': mode,
    'untilMs': untilMs,
  });

  static Future<void> clearBlocking() =>
      _channel.invokeMethod<void>('block.clear');

  // -------- Focus foreground service --------
  static Future<void> startFocus({
    required int durationMs,
    required String mode,
  }) => _channel.invokeMethod<void>('focus.start', <String, dynamic>{
    'durationMs': durationMs,
    'mode': mode,
  });

  static Future<void> stopFocus() => _channel.invokeMethod<void>('focus.stop');

  /// Stream of native events (focus.tick, block.attempt, notification.posted).
  static const EventChannel _eventsChannel = EventChannel(
    'wellbeingx/native/events',
  );
  static Stream<Map<String, dynamic>> events() => _eventsChannel
      .receiveBroadcastStream()
      .map((e) => Map<String, dynamic>.from(e as Map));
}

/// Riverpod provider so we can mock in tests.
final nativeBridgeProvider = Provider<NativeBridgeApi>((ref) {
  return const _NativeBridgeImpl();
});

abstract class NativeBridgeApi {
  Future<bool> hasUsageAccess();
  Future<void> openUsageAccessSettings();
  Future<bool> hasAccessibility();
  Future<void> openAccessibilitySettings();
  Future<bool> hasNotificationAccess();
  Future<void> openNotificationListenerSettings();
  Future<bool> isIgnoringBatteryOptimizations();
  Future<void> requestIgnoreBatteryOptimizations();
  Future<List<Map<String, dynamic>>> queryEvents({
    required int startMs,
    required int endMs,
  });
  Future<List<Map<String, dynamic>>> queryAggregates({
    required int startMs,
    required int endMs,
  });
  Future<List<Map<String, dynamic>>> listInstalledApps();
  Future<List<Map<String, dynamic>>> drainPendingNotifications();
  Future<void> setBlockedPackages(
    List<String> packages, {
    required String mode,
    int? untilMs,
  });
  Future<void> clearBlocking();
  Future<void> startFocus({required int durationMs, required String mode});
  Future<void> stopFocus();
}

class _NativeBridgeImpl implements NativeBridgeApi {
  const _NativeBridgeImpl();

  @override
  Future<bool> hasUsageAccess() => NativeBridge.hasUsageAccess();
  @override
  Future<void> openUsageAccessSettings() =>
      NativeBridge.openUsageAccessSettings();
  @override
  Future<bool> hasAccessibility() => NativeBridge.hasAccessibility();
  @override
  Future<void> openAccessibilitySettings() =>
      NativeBridge.openAccessibilitySettings();
  @override
  Future<bool> hasNotificationAccess() => NativeBridge.hasNotificationAccess();
  @override
  Future<void> openNotificationListenerSettings() =>
      NativeBridge.openNotificationListenerSettings();
  @override
  Future<bool> isIgnoringBatteryOptimizations() =>
      NativeBridge.isIgnoringBatteryOptimizations();
  @override
  Future<void> requestIgnoreBatteryOptimizations() =>
      NativeBridge.requestIgnoreBatteryOptimizations();
  @override
  Future<List<Map<String, dynamic>>> queryEvents({
    required int startMs,
    required int endMs,
  }) => NativeBridge.queryEvents(startMs: startMs, endMs: endMs);
  @override
  Future<List<Map<String, dynamic>>> queryAggregates({
    required int startMs,
    required int endMs,
  }) => NativeBridge.queryAggregates(startMs: startMs, endMs: endMs);
  @override
  Future<List<Map<String, dynamic>>> listInstalledApps() =>
      NativeBridge.listInstalledApps();
  @override
  Future<List<Map<String, dynamic>>> drainPendingNotifications() =>
      NativeBridge.drainPendingNotifications();
  @override
  Future<void> setBlockedPackages(
    List<String> packages, {
    required String mode,
    int? untilMs,
  }) => NativeBridge.setBlockedPackages(packages, mode: mode, untilMs: untilMs);
  @override
  Future<void> clearBlocking() => NativeBridge.clearBlocking();
  @override
  Future<void> startFocus({required int durationMs, required String mode}) =>
      NativeBridge.startFocus(durationMs: durationMs, mode: mode);
  @override
  Future<void> stopFocus() => NativeBridge.stopFocus();
}
