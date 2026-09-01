import 'package:flutter_test/flutter_test.dart';
import 'package:villa_homestay_search/features/search/domain/models/guest_selection.dart';

void main() {
  group('GuestSelection summary', () {
    test('uses singular and plural forms', () {
      expect(const GuestSelection().summary, '2 adults');
      expect(const GuestSelection(adults: 1).summary, '1 adult');
      expect(
        const GuestSelection(adults: 2, childrenAges: <int>[4], pets: 1)
            .summary,
        '2 adults · 1 child · 1 pet',
      );
      expect(
        const GuestSelection(adults: 3, childrenAges: <int>[4, 9], pets: 2)
            .summary,
        '3 adults · 2 children · 2 pets',
      );
    });

    test('short summary counts adults and children only', () {
      const GuestSelection guests = GuestSelection(
        adults: 2,
        childrenAges: <int>[4],
        pets: 3,
      );

      expect(guests.totalGuests, 3);
      expect(guests.shortSummary, '3 guests');
      expect(const GuestSelection(adults: 1).shortSummary, '1 guest');
    });
  });

  group('GuestSelection counters', () {
    test('never drops below one adult', () {
      const GuestSelection guests = GuestSelection(adults: 1);

      expect(guests.decrementAdults().adults, 1);
      expect(guests.incrementAdults().adults, 2);
    });

    test('caps adults, children and pets at their maximums', () {
      GuestSelection guests =
          const GuestSelection(adults: GuestSelection.maxAdults);
      expect(guests.incrementAdults().adults, GuestSelection.maxAdults);

      guests = const GuestSelection();
      for (int i = 0; i < GuestSelection.maxChildren + 3; i++) {
        guests = guests.addChild();
      }
      expect(guests.children, GuestSelection.maxChildren);

      guests = const GuestSelection(pets: GuestSelection.maxPets);
      expect(guests.incrementPets().pets, GuestSelection.maxPets);
      expect(const GuestSelection().decrementPets().pets, 0);
    });

    test('adds, updates and removes children with their ages', () {
      GuestSelection guests = const GuestSelection().addChild(age: 6);
      expect(guests.childrenAges, <int>[6]);

      guests = guests.addChild(age: 12);
      expect(guests.childrenAges, <int>[6, 12]);

      guests = guests.updateChildAge(0, 3);
      expect(guests.childrenAges, <int>[3, 12]);

      // Out of range ages are clamped, out of range indexes ignored.
      guests = guests.updateChildAge(1, 40);
      expect(guests.childrenAges, <int>[3, GuestSelection.maxChildAge]);
      expect(guests.updateChildAge(9, 5).childrenAges, guests.childrenAges);

      guests = guests.removeLastChild();
      expect(guests.childrenAges, <int>[3]);
      expect(
        const GuestSelection().removeLastChild().childrenAges,
        isEmpty,
      );
    });
  });

  group('GuestSelection validity and equality', () {
    test('requires at least one adult', () {
      expect(const GuestSelection().isValid, isTrue);
      expect(const GuestSelection(adults: 0).isValid, isFalse);
    });

    test('compares children ages by value', () {
      expect(
        const GuestSelection(childrenAges: <int>[4, 5]),
        const GuestSelection(childrenAges: <int>[4, 5]),
      );
      expect(
        const GuestSelection(childrenAges: <int>[4, 5]),
        isNot(const GuestSelection(childrenAges: <int>[5, 4])),
      );
    });
  });
}
