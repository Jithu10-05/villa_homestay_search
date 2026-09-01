import '../models/app_location.dart';
import '../models/travel_collection.dart';

/// Contract the UI depends on. A real HTTP implementation can replace the
/// in-memory one without touching a single widget.
abstract class LocationRepository {
  /// Free-text destination search. An empty [query] returns everything.
  Future<List<AppLocation>> searchLocations(String query);

  /// Looks up a destination by id; returns `null` when it does not exist.
  Future<AppLocation?> findById(String id);

  /// Curated shortcuts shown on the home screen.
  Future<List<TravelCollection>> collections();
}
