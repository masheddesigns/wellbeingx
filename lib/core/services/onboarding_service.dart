import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingKey = 'wx_onboarded';
const _kInstalledAtKey = 'wx_installed_at';
const _kGhostModeKey = 'wx_ghost_mode';
const _kGhostUntilKey = 'wx_ghost_until';

/// Seeded once in main() — overridden in ProviderScope.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPrefsProvider in main()'),
);

/// Whether onboarding has been completed.
final onboardingCompletedProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getBool(_kOnboardingKey) ?? false;
});

class InstallSnapshot {
  final DateTime installedAt;
  final bool ghostMode;
  final DateTime? ghostUntil;
  const InstallSnapshot({
    required this.installedAt,
    required this.ghostMode,
    required this.ghostUntil,
  });
}

class InstallController extends Notifier<InstallSnapshot> {
  @override
  InstallSnapshot build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final stored = prefs.getInt(_kInstalledAtKey);
    final installedAt = stored == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(stored);
    if (stored == null) {
      prefs.setInt(_kInstalledAtKey, installedAt.millisecondsSinceEpoch);
    }
    final ghost = prefs.getBool(_kGhostModeKey) ?? false;
    final ghostUntilMs = prefs.getInt(_kGhostUntilKey);
    return InstallSnapshot(
      installedAt: installedAt,
      ghostMode: ghost,
      ghostUntil: ghostUntilMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(ghostUntilMs),
    );
  }

  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(_kOnboardingKey, true);
    ref.read(onboardingCompletedProvider.notifier).state = true;
  }

  Future<void> startGhostWeek() async {
    final prefs = ref.read(sharedPrefsProvider);
    final until = DateTime.now().add(const Duration(days: 7));
    await prefs.setBool(_kGhostModeKey, true);
    await prefs.setInt(_kGhostUntilKey, until.millisecondsSinceEpoch);
    ref.invalidateSelf();
  }

  Future<void> endGhostWeek() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(_kGhostModeKey, false);
    await prefs.remove(_kGhostUntilKey);
    ref.invalidateSelf();
  }

  Future<void> resetAllData() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.clear();
    ref.read(onboardingCompletedProvider.notifier).state = false;
    ref.invalidateSelf();
  }
}

final installControllerProvider =
    NotifierProvider<InstallController, InstallSnapshot>(
  InstallController.new,
);
