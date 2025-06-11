// lib/utils/currency_formatter.dart
class CurrencyFormatter {
  /// Formats amount to Indonesian Rupiah currency format
  /// Example: 1500000 -> "Rp 1.500.000"
  static String formatToRupiah(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Formats amount to Rupiah with decimal places
  /// Example: 1500000.50 -> "Rp 1.500.000,50"
  static String formatToRupiahWithDecimal(double amount) {
    final wholePart = amount.floor();
    final decimalPart = ((amount - wholePart) * 100).round();

    final formattedWhole = wholePart.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    if (decimalPart > 0) {
      return 'Rp $formattedWhole,${decimalPart.toString().padLeft(2, '0')}';
    }
    return 'Rp $formattedWhole';
  }

  /// Formats amount to compact Rupiah format
  /// Example: 1500000 -> "Rp 1.5M", 1500 -> "Rp 1.5K"
  static String formatToCompactRupiah(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatToRupiah(amount);
  }

  /// Formats amount with sign for transaction display
  /// Positive amounts get '+' prefix, negative amounts get '-' prefix
  static String formatToRupiahWithSign(double amount) {
    final formattedAmount = formatToRupiah(amount.abs());
    if (amount >= 0) {
      return '+$formattedAmount';
    }
    return '-$formattedAmount';
  }
}
