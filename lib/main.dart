import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/diagnostics.dart';
import 'core/services/onboarding_service.dart';
import 'presentation/shared/widgets/error_boundary.dart';

Future<void> main() async {
  // Capture every async error anywhere in the app, log it, and never let it
  // silently kill rendering. Combined with FlutterError.onError below, this
  // routes all failure paths through WxLog so the user can see them in-app.
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      WxLog.error(
        'flutter',
        details.summary.toString(),
        details.exception,
        details.stack,
      );
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (Object err, StackTrace st) {
      WxLog.error('platform', err.toString(), err, st);
      return true;
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      WxLog.error('widget', details.exceptionAsString());
      return WxErrorCard(details: details);
    };

    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    WxLog.info('boot', 'app started');

    runApp(
      ProviderScope(
        overrides: <Override>[
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const WellbeingXApp(),
      ),
    );
  }, (Object err, StackTrace st) {
    WxLog.error('zone', err.toString(), err, st);
    if (kDebugMode) {
      // ignore: avoid_print
      print('ZONE ERROR: $err\n$st');
    }
  });
}
