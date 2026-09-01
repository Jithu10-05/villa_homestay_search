/// Local asset paths.
///
/// These bundled illustrations are the offline fallbacks for the remote
/// photography in `AppImages`: they are shown while a photo downloads and
/// whenever it cannot be loaded at all.
class AppAssets {
  const AppAssets._();

  static const String _base = 'assets/images';

  /// Prefix used by the mock data when referencing property illustrations,
  /// e.g. `'${AppAssets.propertyImagePrefix}property_01.png'`.
  static const String propertyImagePrefix = '$_base/';

  static const String hero = '$_base/hero_villas.png';

  static const String collectionBeach = '$_base/collection_beach.png';
  static const String collectionMountain = '$_base/collection_mountain.png';
  static const String collectionCity = '$_base/collection_city.png';
}
