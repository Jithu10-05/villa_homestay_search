import 'package:flutter_test/flutter_test.dart';
import 'package:villa_homestay_search/features/search/domain/models/stay_dates.dart';

void main() {
  group('StayDates selection rules', () {
    test('first tap sets the check-in date only', () {
      final StayDates result =
          const StayDates.empty().select(DateTime(2026, 9, 11));

      expect(result.checkIn, DateTime(2026, 9, 11));
      expect(result.checkOut, isNull);
      expect(result.isComplete, isFalse);
      expect(result.nights, 0);
    });

    test('a later second tap completes the range', () {
      final StayDates result = const StayDates.empty()
          .select(DateTime(2026, 9, 11))
          .select(DateTime(2026, 9, 17));

      expect(result.isComplete, isTrue);
      expect(result.checkOut, DateTime(2026, 9, 17));
    });

    test('tapping an earlier date restarts the selection', () {
      final StayDates result = const StayDates.empty()
          .select(DateTime(2026, 9, 11))
          .select(DateTime(2026, 9, 5));

      expect(result.checkIn, DateTime(2026, 9, 5));
      expect(result.checkOut, isNull);
    });

    test('tapping the same date as check-in restarts the selection', () {
      final StayDates result = const StayDates.empty()
          .select(DateTime(2026, 9, 11))
          .select(DateTime(2026, 9, 11));

      expect(result.checkIn, DateTime(2026, 9, 11));
      expect(result.checkOut, isNull);
    });

    test('tapping again after a complete range starts a new range', () {
      final StayDates result = const StayDates.empty()
          .select(DateTime(2026, 9, 11))
          .select(DateTime(2026, 9, 17))
          .select(DateTime(2026, 9, 20));

      expect(result.checkIn, DateTime(2026, 9, 20));
      expect(result.checkOut, isNull);
    });

    test('the time component is stripped so days compare cleanly', () {
      final StayDates result =
          const StayDates.empty().select(DateTime(2026, 9, 11, 22, 45));

      expect(result.checkIn, DateTime(2026, 9, 11));
    });
  });

  group('StayDates night calculation', () {
    test('counts the nights between check-in and check-out', () {
      const StayDates dates = StayDates(
        checkIn: null,
        checkOut: null,
      );
      expect(dates.nights, 0);

      final StayDates week = StayDates(
        checkIn: DateTime(2026, 9, 11),
        checkOut: DateTime(2026, 9, 18),
      );
      expect(week.nights, 7);
      expect(week.nightsLabel, '7 nights');

      final StayDates single = StayDates(
        checkIn: DateTime(2026, 9, 11),
        checkOut: DateTime(2026, 9, 12),
      );
      expect(single.nights, 1);
      expect(single.nightsLabel, '1 night');
    });

    test('counts nights correctly across a month boundary', () {
      final StayDates dates = StayDates(
        checkIn: DateTime(2026, 9, 29),
        checkOut: DateTime(2026, 10, 2),
      );

      expect(dates.nights, 3);
    });

    test('formats the range label', () {
      final StayDates dates = StayDates(
        checkIn: DateTime(2026, 9, 11),
        checkOut: DateTime(2026, 9, 17),
      );

      expect(dates.rangeLabel, '11 Sep - 17 Sep');
    });
  });

  group('StayDates range helpers', () {
    final StayDates dates = StayDates(
      checkIn: DateTime(2026, 9, 11),
      checkOut: DateTime(2026, 9, 14),
    );

    test('marks the edges and the days between them', () {
      expect(dates.isCheckIn(DateTime(2026, 9, 11)), isTrue);
      expect(dates.isCheckOut(DateTime(2026, 9, 14)), isTrue);
      expect(dates.isBetween(DateTime(2026, 9, 12)), isTrue);
      expect(dates.isBetween(DateTime(2026, 9, 11)), isFalse);
      expect(dates.isInRange(DateTime(2026, 9, 14)), isTrue);
      expect(dates.isInRange(DateTime(2026, 9, 15)), isFalse);
    });
  });
}
