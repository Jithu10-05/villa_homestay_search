import 'package:intl/intl.dart';

/// Pure date helpers shared by the domain models and the UI.
///
/// Deliberately free of Flutter imports so the domain layer stays testable
/// without a widget binding.
class DateHelpers {
  const DateHelpers._();

  /// Strips the time component so two calendar days compare correctly.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime today() => dateOnly(DateTime.now());

  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Whole nights between two calendar days.
  ///
  /// Compared in UTC so a daylight-saving change cannot shift the count.
  static int nightsBetween(DateTime from, DateTime to) {
    final DateTime start = DateTime.utc(from.year, from.month, from.day);
    final DateTime end = DateTime.utc(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }

  /// Number of days in [month] of [year] (month is 1-based).
  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// Number of whole months between two months, ignoring the day.
  static int monthsBetween(DateTime from, DateTime to) =>
      (to.year - from.year) * 12 + (to.month - from.month);

  /// `11 Sep` style label used in compact summaries.
  static String shortDay(DateTime date) => DateFormat('d MMM').format(date);

  /// `11 Sep 2026, Fri` style label used in the calendar footer.
  static String longDay(DateTime date) =>
      DateFormat('d MMM yyyy, EEE').format(date);

  /// `September 2026` header used by the calendar.
  static String monthTitle(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  /// `11 Sep - 17 Sep` range label.
  static String rangeLabel(DateTime checkIn, DateTime checkOut) =>
      '${shortDay(checkIn)} - ${shortDay(checkOut)}';
}
