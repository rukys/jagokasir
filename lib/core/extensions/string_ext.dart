/// Extension String untuk utilitas umum.
extension StringExt on String {
  /// Capitalize huruf pertama.
  /// Contoh: "hello world" → "Hello world"
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize setiap kata.
  /// Contoh: "hello world" → "Hello World"
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Cek apakah string kosong atau hanya whitespace.
  bool get isBlank => trim().isEmpty;

  /// Cek apakah string tidak kosong dan bukan whitespace.
  bool get isNotBlank => !isBlank;

  /// Konversi ke snake_case.
  /// Contoh: "helloWorld" → "hello_world", "Hello World" → "hello_world"
  String get toSnakeCase {
    return replaceAllMapped(
          RegExp(r'([A-Z])'),
          (m) => '_${m.group(0)!.toLowerCase()}',
        )
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_'), '')
        .toLowerCase();
  }

  /// Hapus semua karakter selain huruf, angka, dan spasi.
  String get alphanumericOnly => replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');

  /// Cek apakah string adalah angka valid.
  bool get isNumeric => double.tryParse(this) != null;

  /// Konversi ke double, return null jika gagal.
  double? toDoubleOrNull() => double.tryParse(this);

  /// Konversi ke int, return null jika gagal.
  int? toIntOrNull() => int.tryParse(this);

  /// Truncate string dengan ellipsis jika melebihi [maxLength].
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
}

/// Extension nullable String.
extension NullableStringExt on String? {
  /// True jika null atau kosong.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// True jika tidak null dan tidak kosong.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Return string atau fallback jika null/kosong.
  String orDefault(String fallback) =>
      isNullOrEmpty ? fallback : this!;
}
