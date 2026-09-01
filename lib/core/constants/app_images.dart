/// Remote demo photography.
///
/// The app loads real photographs from the Unsplash CDN and falls back to the
/// bundled illustrations in [AppAssets] whenever a photo cannot be loaded
/// (no connection, blocked network, slow link).
///
/// To move to your own photography later, replace these URLs - or the
/// `imageUrl` values in the mock data - with your own CDN links.
class AppImages {
  const AppImages._();

  /// Every Unsplash photo URL starts with this.
  static const String photoPrefix = 'https://images.unsplash.com/photo-';

  /// Query strings that ask the CDN for an already-resized, compressed image.
  static const String cardParams = '?auto=format&fit=crop&w=800&q=70';
  static const String wideParams = '?auto=format&fit=crop&w=1200&q=70';
  static const String thumbParams = '?auto=format&fit=crop&w=500&q=70';

  /// Home screen hero: friends around a villa pool.
  static const String hero =
      '${photoPrefix}1523301343968-6a6ebf63c672$wideParams';
}
