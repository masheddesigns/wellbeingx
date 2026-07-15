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
    // Cold-start maintenance. Keep expensive usage ingestion out of the first
    // frame so the dashboard can render before Android UsageStats work begins.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final drained = await ref
            .read(usageRepositoryProvider)
            .drainPendingNotifications();
        if (drained > 0) {
          ref.read(notificationRevisionProvider.notifier).state++;
          WxLog.info('notifications', 'drained $drained pending events');
        }

        unawaited(
          Future<void>.delayed(const Duration(seconds: 8), () {
            if (!mounted) return Future<void>.value();
            return runBackgroundIngest(ref);
          }),
        );
        unawaited(
          Future<void>.delayed(const Duration(seconds: 5), () {
            if (!mounted) return Future<void>.value();
            return ReplayReminderService.scheduleDaily9pm();
          }),
        );
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
