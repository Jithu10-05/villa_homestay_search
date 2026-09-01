import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../search/domain/models/search_criteria.dart';
import '../../data/mock_property_repository.dart';
import '../../domain/models/property.dart';
import '../../domain/models/property_sort.dart';
import '../../domain/repositories/property_repository.dart';

/// Swap this single override to move from mock data to a real API.
final Provider<PropertyRepository> propertyRepositoryProvider =
    Provider<PropertyRepository>((Ref ref) => const MockPropertyRepository());

/// The criteria that were actually submitted with the SEARCH button.
///
/// Keeping this separate from the editable criteria means the listings screen
/// keeps showing the search the traveller ran, even if they go back and start
/// editing the form again.
class SubmittedSearchNotifier extends Notifier<SearchCriteria?> {
  @override
  SearchCriteria? build() => null;

  void submit(SearchCriteria criteria) => state = criteria;

  void clear() => state = null;
}

final NotifierProvider<SubmittedSearchNotifier, SearchCriteria?>
    submittedSearchProvider =
    NotifierProvider<SubmittedSearchNotifier, SearchCriteria?>(
  SubmittedSearchNotifier.new,
);

/// Currently selected sort option on the listings screen.
class PropertySortNotifier extends AutoDisposeNotifier<PropertySort> {
  @override
  PropertySort build() => PropertySort.recommended;

  void select(PropertySort sort) => state = sort;
}

final AutoDisposeNotifierProvider<PropertySortNotifier, PropertySort>
    propertySortProvider =
    AutoDisposeNotifierProvider<PropertySortNotifier, PropertySort>(
  PropertySortNotifier.new,
);

/// Stays matching the submitted search, in repository order.
final AutoDisposeFutureProvider<List<Property>> propertySearchProvider =
    FutureProvider.autoDispose<List<Property>>((Ref ref) async {
  final SearchCriteria? criteria = ref.watch(submittedSearchProvider);
  if (criteria == null) return const <Property>[];
  return ref.watch(propertyRepositoryProvider).searchProperties(criteria);
});

/// The same stays, ordered by the selected sort option.
///
/// Sorting is a separate provider so changing the sort re-orders the cached
/// results instead of triggering another search.
final AutoDisposeProvider<AsyncValue<List<Property>>> propertyResultsProvider =
    Provider.autoDispose<AsyncValue<List<Property>>>((Ref ref) {
  final PropertySort sort = ref.watch(propertySortProvider);
  return ref.watch(propertySearchProvider).whenData(sort.apply);
});
