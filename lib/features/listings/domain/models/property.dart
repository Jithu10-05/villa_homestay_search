/// The kind of stay shown on a listing card.
enum PropertyType {
  villa('Entire villa'),
  homestay('Homestay'),
  apartment('Serviced apartment'),
  cottage('Cottage'),
  bungalow('Private bungalow');

  const PropertyType(this.label);

  final String label;

  /// True when the traveller gets the whole property to themselves, which is
  /// everything except a hosted homestay.
  bool get isEntirePlace =>
      this == PropertyType.villa ||
      this == PropertyType.apartment ||
      this == PropertyType.bungalow ||
      this == PropertyType.cottage;
}

/// A bookable stay. Immutable, UI-framework free.
class Property {
  const Property({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.neighbourhood,
    required this.type,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.originalPricePerNight,
    required this.maxGuests,
    required this.bedrooms,
    required this.imageAsset,
    required this.description,
    this.imageUrl,
    this.tags = const <String>[],
    this.isStarHost = false,
    this.freeCancellation = true,
    this.petFriendly = false,
    this.breakfastIncluded = false,
  });

  final String id;
  final String name;
  final String city;
  final String country;

  /// Area within the city, e.g. `Candolim`.
  final String neighbourhood;
  final PropertyType type;

  /// 0.0 - 5.0
  final double rating;
  final int reviewCount;

  /// Nightly price in INR.
  final int pricePerNight;

  /// Pre-discount nightly price in INR.
  final int originalPricePerNight;

  final int maxGuests;
  final int bedrooms;

  /// Bundled illustration, used while the photo loads or if it fails.
  final String imageAsset;

  /// Remote photograph shown on the listing card.
  final String? imageUrl;
  final String description;
  final List<String> tags;
  final bool isStarHost;
  final bool freeCancellation;
  final bool petFriendly;
  final bool breakfastIncluded;

  String get location => '$city, $country';

  bool get hasDiscount => originalPricePerNight > pricePerNight;

  /// Percentage saved, e.g. `24` for 24% off.
  int get discountPercent => hasDiscount
      ? (((originalPricePerNight - pricePerNight) / originalPricePerNight) * 100)
          .round()
      : 0;

  /// `4.8` formatted for the rating badge.
  String get ratingLabel => rating.toStringAsFixed(1);

  /// Human friendly rating word shown next to the score.
  String get ratingWord {
    if (rating >= 4.7) return 'Exceptional';
    if (rating >= 4.4) return 'Excellent';
    if (rating >= 4.0) return 'Very good';
    return 'Good';
  }

  int totalPriceFor(int nights) => pricePerNight * (nights <= 0 ? 1 : nights);

  Property copyWith({
    String? id,
    String? name,
    String? city,
    String? country,
    String? neighbourhood,
    String? imageAsset,
    String? imageUrl,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      country: country ?? this.country,
      neighbourhood: neighbourhood ?? this.neighbourhood,
      type: type,
      rating: rating,
      reviewCount: reviewCount,
      pricePerNight: pricePerNight,
      originalPricePerNight: originalPricePerNight,
      maxGuests: maxGuests,
      bedrooms: bedrooms,
      imageAsset: imageAsset ?? this.imageAsset,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description,
      tags: tags,
      isStarHost: isStarHost,
      freeCancellation: freeCancellation,
      petFriendly: petFriendly,
      breakfastIncluded: breakfastIncluded,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Property && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
