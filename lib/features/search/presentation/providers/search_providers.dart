import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_location_repository.dart';
import '../../domain/models/app_location.dart';
import '../../domain/models/guest_selection.dart';
import '../../domain/models/search_criteria.dart';
import '../../domain/models/stay_dates.dart';
import '../../domain/models/travel_collection.dart';
import '../../domain/repositories/location_repository.dart';

/// Swap this single override to move from mock data to a real API.
final Provider<LocationRepository> locationRepositoryProvider =
    Provider<LocationRepository>((Ref ref) => const MockLocationRepository());

/// The single source of truth for everything the traveller has selected.
class SearchCriteriaNotifier extends Notifier<SearchCriteria> {
  @override
  SearchCriteria build() => const SearchCriteria();

  void selectLocation(AppLocation location) {
    state = state.copyWith(location: location);
  }

  /// Used by the home-screen collections, which only know a destination id.
  Future<void> selectLocationById(String id) async {
    final AppLocation? location =
        await ref.read(locationRepositoryProvider).findById(id);
    if (location != null) selectLocation(location);
  }

  void setDates(StayDates dates) {
    state = state.copyWith(dates: dates);
  }

  void clearDates() {
    state = state.copyWith(dates: const StayDates.empty());
  }

  void setGuests(GuestSelection guests) {
    state = state.copyWith(guests: guests);
  }

  void setEntirePlaceOnly({required bool value}) {
    state = state.copyWith(entirePlaceOnly: value);
  }

  void reset() {
    state = const SearchCriteria();
  }
}

final NotifierProvider<SearchCriteriaNotifier, SearchCriteria>
    searchCriteriaProvider =
    NotifierProvider<SearchCriteriaNotifier, SearchCriteria>(
  SearchCriteriaNotifier.new,
);

/// Destinations the traveller picked earlier in this session, newest first.
class RecentLocationsNotifier extends Notifier<List<AppLocation>> {
  static const int _maxEntries = 4;

  @override
  List<AppLocation> build() => const <AppLocation>[];

  void remember(AppLocation location) {
    final List<AppLocation> next = <AppLocation>[
      location,
      ...state.where((AppLocation item) => item.id != location.id),
    ];
    state = next.take(_maxEntries).toList(growable: false);
  }

  void clear() => state = const <AppLocation>[];
}

final NotifierProvider<RecentLocationsNotifier, List<AppLocation>>
    recentLocationsProvider =
    NotifierProvider<RecentLocationsNotifier, List<AppLocation>>(
  RecentLocationsNotifier.new,
);

/// Live text typed on the location search screen.
class LocationQueryNotifier extends AutoDisposeNotifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final AutoDisposeNotifierProvider<LocationQueryNotifier, String>
    locationQueryProvider =
    AutoDisposeNotifierProvider<LocationQueryNotifier, String>(
  LocationQueryNotifier.new,
);

/// Results for the current query. Empty query returns the full catalogue.
final AutoDisposeFutureProvider<List<AppLocation>> locationResultsProvider =
    FutureProvider.autoDispose<List<AppLocation>>((Ref ref) {
  final String query = ref.watch(locationQueryProvider);
  return ref.watch(locationRepositoryProvider).searchLocations(query);
});

/// Curated shortcuts shown under "Explore collections" on the home screen.
final FutureProvider<List<TravelCollection>> collectionsProvider =
    FutureProvider<List<TravelCollection>>(
  (Ref ref) => ref.watch(locationRepositoryProvider).collections(),
);
