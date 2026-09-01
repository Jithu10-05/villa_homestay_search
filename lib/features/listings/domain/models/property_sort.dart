import 'property.dart';

/// Sort options offered on the listings screen.
enum PropertySort {
  recommended('Recommended'),
  priceLowToHigh('Price: low to high'),
  priceHighToLow('Price: high to low'),
  topRated('Top rated');

  const PropertySort(this.label);

  final String label;

  Comparator<Property> get _comparator {
    switch (this) {
      case PropertySort.recommended:
        return (Property a, Property b) {
          final int byHost = (b.isStarHost ? 1 : 0) - (a.isStarHost ? 1 : 0);
          if (byHost != 0) return byHost;
          return b.rating.compareTo(a.rating);
        };
      case PropertySort.priceLowToHigh:
        return (Property a, Property b) =>
            a.pricePerNight.compareTo(b.pricePerNight);
      case PropertySort.priceHighToLow:
        return (Property a, Property b) =>
            b.pricePerNight.compareTo(a.pricePerNight);
      case PropertySort.topRated:
        return (Property a, Property b) {
          final int byRating = b.rating.compareTo(a.rating);
          if (byRating != 0) return byRating;
          return b.reviewCount.compareTo(a.reviewCount);
        };
    }
  }

  /// Returns a new sorted list; the input list is never mutated.
  List<Property> apply(List<Property> properties) {
    final List<Property> sorted = List<Property>.of(properties);
    sorted.sort(_comparator);
    return sorted;
  }
}
