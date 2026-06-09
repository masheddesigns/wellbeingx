import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tiny in-memory ring-buffer log so the user can see what's failing
/// without us needing logcat access. Entries persist for the app session.
class WxLog {
  WxLog._();

  static final Queue<WxLogEntry> _buffer = Queue<WxLogEntry>();
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static const int _maxEntries = 200;

  static void info(String tag, String message) =>
      _add(WxLogLevel.info, tag, message);
  static void warn(String tag, String message) =>
      _add(WxLogLevel.warn, tag, message);
  static void error(String tag, String message,
      [Object? err, StackTrace? st]) {
    final detail = err == null ? message : '$message — $err';
    _add(WxLogLevel.error, tag, detail);
    if (st != null && kDebugMode) {
      // Print stack only in debug; production keeps log lean.
      // ignore: avoid_print
      print(st);
    }
  }

  static void _add(WxLogLevel level, String tag, String message) {
    _buffer.addLast(WxLogEntry(
      level: level,
      tag: tag,
      message: message,
      at: DateTime.now(),
    ));
    while (_buffer.length > _maxEntries) {
      _buffer.removeFirst();
    }
    revision.value++;
  }

  static List<WxLogEntry> snapshot() => _buffer.toList(growable: false);

  static void clear() {
    _buffer.clear();
    revision.value++;
  }
}

enum WxLogLevel { info, warn, error }

class WxLogEntry {
  final WxLogLevel level;
  final String tag;
  final String message;
  final DateTime at;
  const WxLogEntry({
    required this.level,
    required this.tag,
    required this.message,
    required this.at,
  });
}

/// Provider so screens can rebuild on log changes.
final wxLogRevisionProvider = ChangeNotifierProvider<ValueNotifier<int>>(
  (ref) => WxLog.revision,
);
