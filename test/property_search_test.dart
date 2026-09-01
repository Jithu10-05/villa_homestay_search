import 'package:flutter_test/flutter_test.dart';
import 'package:villa_homestay_search/features/listings/data/mock_property_repository.dart';
import 'package:villa_homestay_search/features/listings/domain/models/property.dart';
import 'package:villa_homestay_search/features/listings/domain/models/property_sort.dart';
import 'package:villa_homestay_search/features/search/domain/models/app_location.dart';
import 'package:villa_homestay_search/features/search/domain/models/guest_selection.dart';
import 'package:villa_homestay_search/features/search/domain/models/search_criteria.dart';
import 'package:villa_homestay_search/features/search/domain/models/stay_dates.dart';

const MockPropertyRepository repository =
    MockPropertyRepository(latency: Duration.zero);

const AppLocation goa = AppLocation(id: 'goa', city: 'Goa', country: 'India');
const AppLocation kochi =
    AppLocation(id: 'kochi', city: 'Kochi', country: 'India');

SearchCriteria criteriaFor(
  AppLocation? location, {
  GuestSelection guests = const GuestSelection(),
  bool entirePlaceOnly = false,
}) {
  return SearchCriteria(
    location: location,
    dates: StayDates(
      checkIn: DateTime(2026, 9, 11),
      checkOut: DateTime(2026, 9, 17),
    ),
    guests: guests,
    entirePlaceOnly: entirePlaceOnly,
  );
}

void main() {
  group('MockPropertyRepository', () {
    test('returns the curated stays for a known destination', () async {
      final List<Property> results =
          await repository.searchProperties(criteriaFor(goa));

      expect(results, isNotEmpty);
      expect(
        results.every((Property property) => property.city == 'Goa'),
        isTrue,
      );
      expect(
        results.map((Property property) => property.name),
        contains('Palm Breeze Villa'),
      );
    });

    test('generates stays for destinations without curated data', () async {
      final List<Property> results =
          await repository.searchProperties(criteriaFor(kochi));

      expect(results, isNotEmpty);
      expect(
        results.every(
          (Property property) =>
              property.city == 'Kochi' && property.country == 'India',
        ),
        isTrue,
      );
    });

    test('returns nothing when no destination is selected', () async {
      final List<Property> results =
          await repository.searchProperties(criteriaFor(null));

      expect(results, isEmpty);
    });

    test('the entire place filter removes hosted homestays', () async {
      final List<Property> results = await repository.searchProperties(
        criteriaFor(goa, entirePlaceOnly: true),
      );

      expect(
        results.any((Property p) => p.type == PropertyType.homestay),
        isFalse,
      );
    });

    test('stays too small for the party are filtered out', () async {
      final List<Property> results = await repository.searchProperties(
        criteriaFor(goa, guests: const GuestSelection(adults: 9)),
      );

      expect(results, isNotEmpty);
      expect(
        results.every((Property property) => property.maxGuests >= 9),
        isTrue,
      );
    });

    test('travelling with pets only returns pet friendly stays', () async {
      final List<Property> results = await repository.searchProperties(
        criteriaFor(goa, guests: const GuestSelection(pets: 1)),
      );

      expect(results, isNotEmpty);
      expect(
        results.every((Property property) => property.petFriendly),
        isTrue,
      );
    });
  });

  group('PropertySort', () {
    test('sorts by price without mutating the source list', () async {
      final List<Property> results =
          await repository.searchProperties(criteriaFor(goa));
      final List<String> originalOrder =
          results.map((Property property) => property.id).toList();

      final List<Property> cheapestFirst =
          PropertySort.priceLowToHigh.apply(results);
      final List<Property> dearestFirst =
          PropertySort.priceHighToLow.apply(results);

      expect(
        cheapestFirst.first.pricePerNight,
        lessThanOrEqualTo(cheapestFirst.last.pricePerNight),
      );
      expect(
        dearestFirst.first.pricePerNight,
        greaterThanOrEqualTo(dearestFirst.last.pricePerNight),
      );
      expect(
        results.map((Property property) => property.id).toList(),
        originalOrder,
      );
    });

    test('top rated puts the highest rating first', () async {
      final List<Property> results = PropertySort.topRated
          .apply(await repository.searchProperties(criteriaFor(goa)));

      expect(
        results.first.rating,
        greaterThanOrEqualTo(results.last.rating),
      );
    });
  });

  group('Property pricing', () {
    test('multiplies the nightly price by the number of nights', () {
      final Property property =
          kCuratedSample.copyWith(id: 'sample', city: 'Goa');

      expect(property.totalPriceFor(6), property.pricePerNight * 6);
      // Guards against a zero-night total while dates are being changed.
      expect(property.totalPriceFor(0), property.pricePerNight);
      expect(property.hasDiscount, isTrue);
      expect(property.discountPercent, greaterThan(0));
    });
  });
}

const Property kCuratedSample = Property(
  id: 'sample',
  name: 'Sample Villa',
  city: 'Goa',
  country: 'India',
  neighbourhood: 'Candolim',
  type: PropertyType.villa,
  rating: 4.8,
  reviewCount: 12,
  pricePerNight: 8500,
  originalPricePerNight: 11200,
  maxGuests: 8,
  bedrooms: 3,
  imageAsset: 'assets/images/property_01.png',
  description: 'Sample',
);
