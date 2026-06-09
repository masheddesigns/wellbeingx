import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/diagnostics.dart';
import '../core/services/native_bridge.dart';
import '../core/services/replay_reminder.dart';
import '../core/services/theme_controller.dart';
import '../data/repositories/usage_repository.dart';
import '../presentation/dashboard/dashboard_state.dart';
import 'router.dart';
import 'theme/theme.dart';

class WellbeingXApp extends ConsumerStatefulWidget {
  const WellbeingXApp({super.key});

  @override
  ConsumerState<WellbeingXApp> createState() => _WellbeingXAppState();
}

class _WellbeingXAppState extends ConsumerState<WellbeingXApp> {
  StreamSubscription<Map<String, dynamic>>? _nativeEventsSub;

  @override
  void initState() {
    super.initState();
    _nativeEventsSub = NativeBridge.events().listen(
      (event) async {
        try {
          final recorded = await ref
              .read(usageRepositoryProvider)
              .recordNativeEvent(event);
          if (recorded) {
            ref.read(notificationRevisionProvider.notifier).state++;
          }
        } catch (e, st) {
          WxLog.error('native-events', 'failed to record event', e, st);
        }
      },
      onError: (Object e, StackTrace st) {
        WxLog.error('native-events', 'stream error', e, st);
      },
    );
    // Cold-start ingest. Fires as soon as the app process is ready, regardless
    // of which route the user lands on. The dashboard's own post-frame ingest
    // is still there for when the user pulls to refresh.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Schedule the daily 9pm Replay reminder once at app start. Idempotent.
      unawaited(ReplayReminderService.scheduleDaily9pm());
      try {
        final drained = await ref
            .read(usageRepositoryProvider)
            .drainPendingNotifications();
        if (drained > 0) {
          ref.read(notificationRevisionProvider.notifier).state++;
          WxLog.info('notifications', 'drained $drained pending events');
        }

        final native = ref.read(nativeBridgeProvider);
        final hasUsage = await native.hasUsageAccess();
        if (!hasUsage) {
          WxLog.warn('cold-start', 'no usage access');
          return;
        }
        if (ref.read(ingestingProvider)) return;
        ref.read(ingestingProvider.notifier).state = true;
        WxLog.info('cold-start', 'forced ingest');
        try {
          await ref.read(usageRepositoryProvider).ingest();
          ref.read(lastIngestProvider.notifier).state =
              DateTime.now().millisecondsSinceEpoch;
          WxLog.info('cold-start', 'ingest done');
        } catch (e, st) {
          WxLog.error('cold-start', 'ingest failed', e, st);
        } finally {
          ref.read(ingestingProvider.notifier).state = false;
        }
      } catch (e, st) {
        WxLog.error('cold-start', 'unexpected', e, st);
      }
    });
  }

  @override
  void dispose() {
    _nativeEventsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final variant = ref.watch(themeControllerProvider);
    final theme = WxTheme.dark.copyWith(
      scaffoldBackgroundColor: variant.background,
      canvasColor: variant.background,
    );
    return MaterialApp.router(
      title: 'WellbeingX',
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'wx_root_restoration',
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
