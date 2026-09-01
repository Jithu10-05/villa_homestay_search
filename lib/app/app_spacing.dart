/// Spacing and radius scale used across the app so padding stays consistent.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;

  /// Maximum content width. Keeps the layout in a phone-sized, centred column
  /// when the app runs in Chrome on a desktop screen.
  static const double maxContentWidth = 460;
}

/// Corner radii used across cards, sheets and inputs.
class AppRadius {
  const AppRadius._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;
}
