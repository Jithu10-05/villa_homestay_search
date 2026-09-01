/// A searchable destination.
///
/// Named [AppLocation] instead of `Location` to avoid clashing with the
/// `Location` type Flutter/dart:ui exposes.
class AppLocation {
  const AppLocation({
    required this.id,
    required this.city,
    required this.country,
    this.region,
    this.isPopular = false,
  });

  final String id;
  final String city;
  final String country;

  /// Optional state/region, e.g. `Karnataka`.
  final String? region;

  /// Whether the destination shows up under "Popular searches".
  final bool isPopular;

  String get displayName => '$city, $country';

  /// Text used when matching a user query.
  String get searchIndex =>
      '$city $country ${region ?? ''}'.toLowerCase().trim();

  bool matches(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return searchIndex.contains(q);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AppLocation && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AppLocation($id)';
}
