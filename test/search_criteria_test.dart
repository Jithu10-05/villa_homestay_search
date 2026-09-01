import 'package:flutter_test/flutter_test.dart';
import 'package:villa_homestay_search/features/search/domain/models/app_location.dart';
import 'package:villa_homestay_search/features/search/domain/models/guest_selection.dart';
import 'package:villa_homestay_search/features/search/domain/models/search_criteria.dart';
import 'package:villa_homestay_search/features/search/domain/models/stay_dates.dart';

const AppLocation goa = AppLocation(id: 'goa', city: 'Goa', country: 'India');

SearchCriteria criteriaWith({
  AppLocation? location = goa,
  DateTime? checkIn,
  DateTime? checkOut,
  GuestSelection guests = const GuestSelection(),
}) {
  return SearchCriteria(
    location: location,
    dates: StayDates(checkIn: checkIn, checkOut: checkOut),
    guests: guests,
  );
}

void main() {
  group('SearchCriteria validation', () {
    test('blocks a search without a destination', () {
      final SearchCriteria criteria = criteriaWith(
        location: null,
        checkIn: DateTime(2026, 9, 11),
        checkOut: DateTime(2026, 9, 17),
      );

      expect(criteria.validate(), SearchValidationError.missingLocation);
      expect(criteria.canSearch, isFalse);
    });

    test('blocks a search without any dates', () {
      final SearchCriteria criteria = criteriaWith();

      expect(criteria.validate(), SearchValidationError.missingDates);
    });

    test('blocks a search with only a check-in date', () {
      final SearchCriteria criteria = criteriaWith(
        checkIn: DateTime(2026, 9, 11),
      );

      expect(criteria.validate(), SearchValidationError.incompleteDates);
    });

    test('blocks a search with no adults', () {
      final SearchCriteria criteria = criteriaWith(
        checkIn: DateTime(2026, 9, 11),
        checkOut: DateTime(2026, 9, 17),
        guests: const GuestSelection(adults: 0),
      );

      expect(criteria.validate(), SearchValidationError.invalidGuests);
    });

    test('allows a complete search', () {
      final SearchCriteria criteria = criteriaWith(
        checkIn: DateTime(2026, 9, 11),
        checkOut: DateTime(2026, 9, 17),
      );

      expect(criteria.validate(), isNull);
      expect(criteria.canSearch, isTrue);
      expect(criteria.nights, 6);
    });

    test('every validation error carries a message for the UI', () {
      for (final SearchValidationError error in SearchValidationError.values) {
        expect(error.message, isNotEmpty);
      }
    });
  });

  group('SearchCriteria labels', () {
    test('summarises the trip for the listings header', () {
      final SearchCriteria criteria = criteriaWith(
        checkIn: DateTime(2026, 9, 11),
        checkOut: DateTime(2026, 9, 17),
        guests: const GuestSelection(adults: 2, childrenAges: <int>[6]),
      );

      expect(criteria.locationLabel, 'Goa');
      expect(criteria.summaryLine, '11 Sep - 17 Sep · 3 guests');
      expect(criteria.datesLabel, '11 Sep - 17 Sep, 6 nights');
    });

    test('prompts for the missing pieces while incomplete', () {
      expect(
        criteriaWith(location: null).locationLabel,
        'Where are you going?',
      );
      expect(criteriaWith().datesLabel, 'Add dates');
      expect(
        criteriaWith(checkIn: DateTime(2026, 9, 11)).datesLabel,
        '11 Sep - Add check-out',
      );
    });
  });

  group('SearchCriteria updates', () {
    test('copyWith keeps untouched fields and preserves equality', () {
      final SearchCriteria base = criteriaWith(
        checkIn: DateTime(2026, 9, 11),
        checkOut: DateTime(2026, 9, 17),
      );

      final SearchCriteria sameValues = base.copyWith();
      expect(sameValues, base);

      final SearchCriteria withGuests =
          base.copyWith(guests: const GuestSelection(adults: 4));
      expect(withGuests.guests.adults, 4);
      expect(withGuests.dates, base.dates);
      expect(withGuests.location, base.location);
      expect(withGuests, isNot(base));
    });

    test('entire place toggle is part of the criteria', () {
      final SearchCriteria criteria =
          criteriaWith().copyWith(entirePlaceOnly: true);

      expect(criteria.entirePlaceOnly, isTrue);
    });
  });
}
