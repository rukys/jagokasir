import 'dart:math' as math;

/// Extension double untuk rounding dan format Rupiah.
extension DoubleExt on double {
  /// Pembulatan half-up ke [decimals] desimal.
  ///
  /// Contoh: 1.005.roundHalfUp(2) → 1.01
  /// Berbeda dengan Dart default yang menggunakan banker's rounding.
  double roundHalfUp(int decimals) {
    final factor = math.pow(10, decimals).toDouble();
    return (this * factor + 0.5).floorToDouble() / factor;
  }

  /// Format ke string Rupiah.
  ///
  /// Contoh:
  /// - 10000.0    → "Rp 10.000"
  /// - 10000.5    → "Rp 10.000,50"
  /// - 1000000.0  → "Rp 1.000.000"
  String formatRupiah() {
    final isNegative = this < 0;
    final absValue = isNegative ? -this : this;

    // Pisahkan integer dan desimal
    final intPart = absValue.truncate();
    final decPart = ((absValue - intPart) * 100).round();

    // Format integer dengan separator ribuan (titik)
    final intStr = _formatThousands(intPart);

    String result;
    if (decPart > 0) {
      final decStr = decPart.toString().padLeft(2, '0');
      result = 'Rp $intStr,$decStr';
    } else {
      result = 'Rp $intStr';
    }

    return isNegative ? '-$result' : result;
  }

  /// Format kompak Rupiah (tanpa desimal, dengan suffix rb/jt/m).
  ///
  /// Contoh:
  /// - 10000.0       → "Rp 10rb"
  /// - 1500000.0     → "Rp 1,5jt"
  /// - 2000000000.0  → "Rp 2m"
  String formatRupiahCompact() {
    final absValue = abs();

    if (absValue >= 1e9) {
      final val = absValue / 1e9;
      return 'Rp ${_compactNum(val)}m';
    } else if (absValue >= 1e6) {
      final val = absValue / 1e6;
      return 'Rp ${_compactNum(val)}jt';
    } else if (absValue >= 1e3) {
      final val = absValue / 1e3;
      return 'Rp ${_compactNum(val)}rb';
    } else {
      return 'Rp ${absValue.truncate()}';
    }
  }

  /// Format angka kompak: hilangkan desimal jika .0
  String _compactNum(double val) {
    if (val == val.truncate()) {
      return val.truncate().toString();
    }
    // Satu desimal jika ada sisa
    return val.toStringAsFixed(1).replaceAll('.', ',');
  }

  /// Format integer dengan separator ribuan menggunakan titik.
  String _formatThousands(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    var counter = 0;

    for (var i = str.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
      counter++;
    }

    return buffer.toString().split('').reversed.join('');
  }

  /// Apakah bernilai nol atau negatif?
  bool get isNonPositive => this <= 0;

  /// Apakah bernilai positif?
  bool get isPositive => this > 0;
}
