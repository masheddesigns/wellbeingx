import 'package:intl/intl.dart';

class WxDates {
  WxDates._();

  static int dayEpoch(DateTime t) {
    final d = DateTime(t.year, t.month, t.day);
    return d.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  }

  static DateTime fromDayEpoch(int e) =>
      DateTime.fromMillisecondsSinceEpoch(e * Duration.millisecondsPerDay,
          isUtc: true)
          .toLocal();

  static DateTime startOfDay(DateTime t) => DateTime(t.year, t.month, t.day);

  static DateTime endOfDay(DateTime t) =>
      DateTime(t.year, t.month, t.day, 23, 59, 59, 999);

  static DateTime startOfWeek(DateTime t) {
    final s = startOfDay(t);
    return s.subtract(Duration(days: (s.weekday - DateTime.monday) % 7));
  }

  static DateTime startOfMonth(DateTime t) => DateTime(t.year, t.month, 1);

  static String shortLabel(DateTime t) =>
      DateFormat('EEE d MMM').format(t);

  static String dayShort(DateTime t) => DateFormat('EEE').format(t);

  static String monthLabel(DateTime t) => DateFormat('MMM yyyy').format(t);

  static String hourLabel(int hour) {
    final dt = DateTime(2000, 1, 1, hour);
    return DateFormat('h a').format(dt);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static List<int> last(int days, [DateTime? from]) {
    final base = from ?? DateTime.now();
    return List<int>.generate(days, (i) => dayEpoch(base.subtract(Duration(days: days - 1 - i))));
  }
}
