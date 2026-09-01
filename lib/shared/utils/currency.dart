import 'package:intl/intl.dart';

/// Formats prices consistently across the app.
class Currency {
  const Currency._();

  static final NumberFormat _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// `₹8,500`
  static String inr(int amount) => _inr.format(amount);
}
