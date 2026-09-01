import '../../../search/domain/models/search_criteria.dart';
import '../models/property.dart';

/// Contract for fetching stays that match a [SearchCriteria].
abstract class PropertyRepository {
  Future<List<Property>> searchProperties(SearchCriteria criteria);
}
