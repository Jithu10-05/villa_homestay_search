import '../domain/models/app_location.dart';
import '../domain/models/travel_collection.dart';
import '../domain/repositories/location_repository.dart';
import 'mock_collections.dart';
import 'mock_locations.dart';

/// In-memory [LocationRepository]. The small artificial delay keeps the UI
/// honest about loading states, so wiring a real API later changes nothing.
class MockLocationRepository implements LocationRepository {
  const MockLocationRepository({
    this.latency = const Duration(milliseconds: 180),
  });

  final Duration latency;

  @override
  Future<List<AppLocation>> searchLocations(String query) async {
    await Future<void>.delayed(latency);
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return List<AppLocation>.unmodifiable(kMockLocations);
    }

    final List<AppLocation> matches = kMockLocations
        .where((AppLocation location) => location.matches(trimmed))
        .toList();

    // Cities whose name starts with the query feel more relevant, so they
    // bubble to the top of the list.
    final String lower = trimmed.toLowerCase();
    matches.sort((AppLocation a, AppLocation b) {
      final bool aStarts = a.city.toLowerCase().startsWith(lower);
      final bool bStarts = b.city.toLowerCase().startsWith(lower);
      if (aStarts != bStarts) return aStarts ? -1 : 1;
      return a.city.compareTo(b.city);
    });
    return matches;
  }

  @override
  Future<AppLocation?> findById(String id) async {
    for (final AppLocation location in kMockLocations) {
      if (location.id == id) return location;
    }
    return null;
  }

  @override
  Future<List<TravelCollection>> collections() async =>
      List<TravelCollection>.unmodifiable(kMockCollections);
}
