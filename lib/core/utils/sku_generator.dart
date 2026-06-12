/// Generator SKU (Stock Keeping Unit) produk.
///
/// Format: `[PREFIX]-[TIMESTAMP]`
/// - PREFIX: 3 huruf pertama nama produk (uppercase, alphanumeric only)
/// - TIMESTAMP: milliseconds since epoch (6 digit terakhir)
///
/// Contoh: nama "Aqua Botol 600ml" → `AQU-483291`
class SkuGenerator {
  SkuGenerator._();

  /// Generate SKU dari nama produk.
  static String generate(String productName) {
    final prefix = _buildPrefix(productName);
    final timestamp = (DateTime.now().millisecondsSinceEpoch % 1000000)
        .toString()
        .padLeft(6, '0');
    return '$prefix-$timestamp';
  }

  /// Buat prefix 3 karakter dari nama produk.
  static String _buildPrefix(String name) {
    // Ambil hanya huruf & angka, uppercase
    final cleaned = name
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (cleaned.isEmpty) return 'PRD';

    // Pad dengan 'X' jika kurang dari 3 karakter
    return cleaned.substring(0, cleaned.length.clamp(0, 3)).padRight(3, 'X');
  }
}
