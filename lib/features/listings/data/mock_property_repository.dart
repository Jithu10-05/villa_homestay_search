import '../../search/domain/models/search_criteria.dart';
import '../domain/models/property.dart';
import '../domain/repositories/property_repository.dart';
import 'mock_properties.dart';

/// In-memory [PropertyRepository].
///
/// Curated listings are returned for destinations that have them; every other
/// destination gets believable generated stays so the flow can be explored
/// end-to-end without a backend.
class MockPropertyRepository implements PropertyRepository {
  const MockPropertyRepository({
    this.latency = const Duration(milliseconds: 450),
  });

  final Duration latency;

  @override
  Future<List<Property>> searchProperties(SearchCriteria criteria) async {
    await Future<void>.delayed(latency);

    final String? city = criteria.location?.city;
    if (city == null) return const <Property>[];

    final String country = criteria.location!.country;
    final List<Property> all = _forCity(city, country);

    return all.where((Property property) {
      if (criteria.entirePlaceOnly && !property.type.isEntirePlace) {
        return false;
      }
      if (property.maxGuests < criteria.guests.totalGuests) return false;
      if (criteria.guests.pets > 0 && !property.petFriendly) return false;
      return true;
    }).toList(growable: false);
  }

  List<Property> _forCity(String city, String country) {
    final String key = city.toLowerCase();
    final List<Property>? curated = kCuratedProperties[key];
    if (curated != null && curated.isNotEmpty) {
      return List<Property>.unmodifiable(curated);
    }

    final List<String> areas = kNeighbourhoods[key] ?? kFallbackNeighbourhoods;

    // Offset the photo pool per city so two destinations do not show the same
    // set of pictures.
    final int offset =
        key.codeUnits.fold<int>(0, (int sum, int unit) => sum + unit);

    return List<Property>.unmodifiable(
      kTemplateProperties.asMap().entries.map(
        (MapEntry<int, Property> entry) => entry.value.copyWith(
          id: '$key-${entry.key + 1}',
          city: city,
          country: country,
          neighbourhood: areas[entry.key % areas.length],
          imageUrl:
              kStayPhotoPool[(offset + entry.key) % kStayPhotoPool.length],
        ),
      ),
    );
  }
}
