import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatPrice(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)} K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  static String formatFull(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
