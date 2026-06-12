import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/double_ext.dart';

/// Widget display harga Rupiah dengan typography yang konsisten.
///
/// Contoh:
/// ```dart
/// CurrencyDisplay(amount: 50000, style: CurrencyDisplayStyle.large);
/// CurrencyDisplay.compact(amount: 150000);
/// ```
enum CurrencyDisplayStyle {
  /// displaySmall (36sp) — untuk grand total di payment screen
  large,

  /// headlineSmall (24sp) — untuk total di cart
  medium,

  /// titleMedium (16sp) — untuk harga produk di card
  normal,

  /// bodyMedium (14sp) — untuk sub-item, perincian
  small,

  /// labelSmall (11sp) — untuk metadata harga kecil
  tiny,
}

class CurrencyDisplay extends StatelessWidget {
  const CurrencyDisplay({
    super.key,
    required this.amount,
    this.style = CurrencyDisplayStyle.normal,
    this.color,
    this.strikethrough = false,
    this.compact = false,
  });

  /// Constructor untuk tampilan kompak (rb/jt).
  const CurrencyDisplay.compact({
    super.key,
    required this.amount,
    this.style = CurrencyDisplayStyle.small,
    this.color,
    this.strikethrough = false,
  }) : compact = true;

  final double amount;
  final CurrencyDisplayStyle style;
  final Color? color;

  /// Tampilkan dengan strikethrough (harga coret).
  final bool strikethrough;

  /// Gunakan format kompak (Rp 10rb, Rp 1jt).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = _resolveStyle(theme);
    final effectiveColor = color ?? _resolveColor(amount);
    final text = compact ? amount.formatRupiahCompact() : amount.formatRupiah();

    return Text(
      text,
      style: textStyle.copyWith(
        color: effectiveColor,
        decoration: strikethrough ? TextDecoration.lineThrough : null,
        decorationColor: effectiveColor,
      ),
    );
  }

  TextStyle _resolveStyle(ThemeData theme) => switch (style) {
    CurrencyDisplayStyle.large  => theme.textTheme.displaySmall!,
    CurrencyDisplayStyle.medium => theme.textTheme.headlineSmall!,
    CurrencyDisplayStyle.normal => theme.textTheme.titleMedium!,
    CurrencyDisplayStyle.small  => theme.textTheme.bodyMedium!,
    CurrencyDisplayStyle.tiny   => theme.textTheme.labelSmall!,
  };

  /// Warna default: merah jika negatif, hijau jika positif, abu jika nol.
  Color _resolveColor(double val) {
    if (val < 0) return AppColors.danger;
    if (val == 0) return AppColors.onSurfaceVariant;
    return AppColors.onSurface;
  }
}
