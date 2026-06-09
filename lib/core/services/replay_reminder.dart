import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'diagnostics.dart';

/// Single-purpose: schedule the daily "Your day, in 60 seconds" reminder for
/// 9:00 PM local time. The notification is intent-tagged so the app shell can
/// route it to the cinematic replay route on tap.
class ReplayReminderService {
  ReplayReminderService._();

  static const int _id = 1042;
  static const String _channelId = 'wx-replay';
  static const String _channelName = 'Daily Replay';
  static const String _channelDesc =
      'A nightly nudge to watch your day, in 60 seconds.';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Idempotent — safe to call from app start and again from settings.
  static Future<void> init() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      // Best-effort local TZ. flutter_local_notifications uses tz.local for
      // scheduling; we keep the platform default which is set up by the
      // native side or stays UTC if unknown — that's fine for daily 9pm
      // anchored to the device wall clock via DateTime.now().
      const initIos = DarwinInitializationSettings();
      const initAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(
        const InitializationSettings(
          android: initAndroid,
          iOS: initIos,
        ),
      );
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.defaultImportance,
        ),
      );
      _initialized = true;
    } catch (e, st) {
      WxLog.error('replay-reminder.init', 'init failed', e, st);
    }
  }

  /// Schedule (or re-schedule) a daily 9:00 PM local notification.
  static Future<void> scheduleDaily9pm() async {
    await init();
    try {
      await _plugin.cancel(_id);
      final next = _next9pm();
      await _plugin.zonedSchedule(
        _id,
        'Your day, in 60 seconds',
        'A quiet recap is waiting. Tap to play.',
        next,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            ticker: 'replay',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'replay',
      );
      WxLog.info('replay-reminder', 'scheduled for $next');
    } catch (e, st) {
      WxLog.error('replay-reminder.schedule', 'schedule failed', e, st);
    }
  }

  static Future<void> cancel() async {
    await init();
    await _plugin.cancel(_id);
  }

  static tz.TZDateTime _next9pm() {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21);
    if (!t.isAfter(now)) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }
}

/// Triggers reminder scheduling once when the app starts. Holds no state —
/// the dependency on ref keeps it alive for the app lifetime.
final replayReminderBootstrapProvider = Provider<void>((ref) {
  ReplayReminderService.scheduleDaily9pm();
  return;
});
