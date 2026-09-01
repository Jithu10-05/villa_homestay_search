import '../../../../shared/utils/date_helpers.dart';

/// The check-in / check-out pair chosen by the traveller.
///
/// All selection rules live here (not in the calendar widget) so they can be
/// unit-tested and reused.
class StayDates {
  const StayDates({this.checkIn, this.checkOut});

  const StayDates.empty()
      : checkIn = null,
        checkOut = null;

  final DateTime? checkIn;
  final DateTime? checkOut;

  bool get hasCheckIn => checkIn != null;
  bool get isComplete => checkIn != null && checkOut != null;

  /// Number of nights between check-in and check-out (0 while incomplete).
  int get nights =>
      isComplete ? DateHelpers.nightsBetween(checkIn!, checkOut!) : 0;

  /// `7 nights` / `1 night`.
  String get nightsLabel => nights == 1 ? '1 night' : '$nights nights';

  /// `11 Sep - 17 Sep` (empty string while incomplete).
  String get rangeLabel =>
      isComplete ? DateHelpers.rangeLabel(checkIn!, checkOut!) : '';

  /// Applies a calendar tap and returns the resulting selection.
  ///
  /// Rules:
  /// * the first tap picks the check-in date;
  /// * a later date completes the range;
  /// * tapping a date on/before the current check-in restarts the selection;
  /// * tapping again once a range is complete restarts the selection.
  StayDates select(DateTime day) {
    final DateTime picked = DateHelpers.dateOnly(day);

    if (checkIn == null || isComplete) {
      return StayDates(checkIn: picked);
    }
    if (!picked.isAfter(checkIn!)) {
      return StayDates(checkIn: picked);
    }
    return StayDates(checkIn: checkIn, checkOut: picked);
  }

  bool isCheckIn(DateTime day) => DateHelpers.isSameDay(checkIn, day);

  bool isCheckOut(DateTime day) => DateHelpers.isSameDay(checkOut, day);

  /// True for days strictly between check-in and check-out.
  bool isBetween(DateTime day) {
    if (!isComplete) return false;
    final DateTime d = DateHelpers.dateOnly(day);
    return d.isAfter(checkIn!) && d.isBefore(checkOut!);
  }

  /// True for check-in, check-out and every day in between.
  bool isInRange(DateTime day) =>
      isCheckIn(day) || isCheckOut(day) || isBetween(day);

  StayDates clear() => const StayDates.empty();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StayDates &&
          other.checkIn == checkIn &&
          other.checkOut == checkOut);

  @override
  int get hashCode => Object.hash(checkIn, checkOut);

  @override
  String toString() => 'StayDates($checkIn -> $checkOut)';
}
