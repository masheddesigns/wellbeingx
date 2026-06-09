import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'native_bridge.dart';

class PermissionsState {
  final bool usageAccess;
  final bool accessibility;
  final bool notifications;
  final bool batteryOptimisationsIgnored;

  const PermissionsState({
    required this.usageAccess,
    required this.accessibility,
    required this.notifications,
    required this.batteryOptimisationsIgnored,
  });

  factory PermissionsState.unknown() => const PermissionsState(
        usageAccess: false,
        accessibility: false,
        notifications: false,
        batteryOptimisationsIgnored: false,
      );

  bool get hasMandatory => usageAccess;

  PermissionsState copyWith({
    bool? usageAccess,
    bool? accessibility,
    bool? notifications,
    bool? batteryOptimisationsIgnored,
  }) =>
      PermissionsState(
        usageAccess: usageAccess ?? this.usageAccess,
        accessibility: accessibility ?? this.accessibility,
        notifications: notifications ?? this.notifications,
        batteryOptimisationsIgnored:
            batteryOptimisationsIgnored ?? this.batteryOptimisationsIgnored,
      );
}

class PermissionsController extends Notifier<PermissionsState> {
  @override
  PermissionsState build() => PermissionsState.unknown();

  NativeBridgeApi get _native => ref.read(nativeBridgeProvider);

  Future<void> refresh() async {
    final usage = await _safe(() => _native.hasUsageAccess());
    final acc = await _safe(() => _native.hasAccessibility());
    final notif = await _safe(() => _native.hasNotificationAccess());
    final batt = await _safe(() => _native.isIgnoringBatteryOptimizations());
    state = PermissionsState(
      usageAccess: usage,
      accessibility: acc,
      notifications: notif,
      batteryOptimisationsIgnored: batt,
    );
  }

  Future<void> openUsageAccess() async {
    await _safeVoid(() => _native.openUsageAccessSettings());
  }

  Future<void> openAccessibility() async {
    await _safeVoid(() => _native.openAccessibilitySettings());
  }

  Future<void> openNotificationListener() async {
    await _safeVoid(() => _native.openNotificationListenerSettings());
  }

  Future<void> requestBatteryOpt() async {
    await _safeVoid(() => _native.requestIgnoreBatteryOptimizations());
  }

  Future<bool> _safe(Future<bool> Function() fn) async {
    try {
      return await fn();
    } catch (_) {
      return false;
    }
  }

  Future<void> _safeVoid(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (_) {}
  }
}

final permissionsProvider =
    NotifierProvider<PermissionsController, PermissionsState>(
  PermissionsController.new,
);
