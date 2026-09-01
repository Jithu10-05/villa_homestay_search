import 'package:flutter/material.dart';

/// Central colour palette for the app.
///
/// Everything visual should read from here so the product keeps a single,
/// cohesive travel-app identity (no default Flutter purple anywhere).
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF1266E3);
  static const Color primaryDark = Color(0xFF0B4CB0);
  static const Color primarySoft = Color(0xFFE8F1FE);

  static const Color accent = Color(0xFFFF7A45);
  static const Color accentSoft = Color(0xFFFFF1EA);

  static const Color ink = Color(0xFF10233B);
  static const Color inkMuted = Color(0xFF5B6B80);
  static const Color inkFaint = Color(0xFF98A6B8);

  static const Color canvas = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE3E8F0);

  static const Color success = Color(0xFF1B8A4B);
  static const Color successSoft = Color(0xFFEAF7EF);
  static const Color danger = Color(0xFFD14343);
  static const Color star = Color(0xFFF5A524);

  /// Used for the primary call-to-action button.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF2E8CF0), Color(0xFF0F5FD6)],
  );

  /// Scrim placed over hero illustrations so white text stays readable.
  static const LinearGradient heroScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0x33000000), Color(0xAA0A1A2B)],
  );
}
