/// A curated shortcut shown under "Explore collections" on the home screen.
class TravelCollection {
  const TravelCollection({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.locationId,
    this.imageUrl,
  });

  final String title;
  final String subtitle;

  /// Bundled illustration, used while the photo loads or if it fails.
  final String imageAsset;

  /// Remote photograph shown on the collection card.
  final String? imageUrl;

  /// Id of the destination this collection jumps to.
  final String locationId;
}
