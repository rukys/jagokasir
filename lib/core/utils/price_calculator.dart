import '../extensions/double_ext.dart';

/// Tipe diskon yang dipakai di item dan transaksi.
enum DiscountType { percentage, nominal }

/// Tipe pajak.
enum TaxType { exclusive, inclusive }

/// Hasil kalkulasi harga transaksi.
class PriceSummary {
  /// SUM(line_total) — setelah diskon item, sebelum diskon transaksi.
  final double subtotal;

  /// Nominal diskon transaksi yang diaplikasikan.
  final double txnDiscountAmount;

  /// Subtotal setelah diskon transaksi.
  final double afterDiscount;

  /// Nominal pajak.
  final double taxAmount;

  /// Total akhir yang harus dibayar pelanggan.
  final double grandTotal;

  const PriceSummary({
    required this.subtotal,
    required this.txnDiscountAmount,
    required this.afterDiscount,
    required this.taxAmount,
    required this.grandTotal,
  });

  @override
  String toString() =>
      'PriceSummary(subtotal: $subtotal, discount: $txnDiscountAmount, '
      'afterDiscount: $afterDiscount, tax: $taxAmount, grandTotal: $grandTotal)';
}

/// Item kasir yang dipakai sebagai input kalkulasi.
class CartItemInput {
  final double sellingPrice;
  final double quantity;
  final DiscountType? itemDiscountType;
  final double? itemDiscountValue;

  const CartItemInput({
    required this.sellingPrice,
    required this.quantity,
    this.itemDiscountType,
    this.itemDiscountValue,
  });
}

/// Kalkulator harga POS Kasir.
///
/// Urutan kalkulasi (WAJIB, sesuai CONTEXT_GLOBAL section 8):
/// 1. line_total per item = (selling_price × qty) - item_discount_amount
/// 2. subtotal            = SUM(semua line_total)
/// 3. txn_discount_amount = kalkulasi dari subtotal
/// 4. after_discount      = subtotal - txn_discount_amount
/// 5. tax_amount          = kalkulasi dari after_discount
/// 6. grand_total         = after_discount + tax_amount (exclusive)
///                        = after_discount (inclusive)
///
/// Pembulatan: roundHalfUp(2) di setiap step.
class PriceCalculator {
  PriceCalculator._();

  /// Hitung nominal diskon per item.
  /// [price] harga satuan, [qty] jumlah, [type] tipe diskon, [value] nilai diskon.
  /// Diskon NOMINAL tidak boleh melebihi `price * qty`.
  static double calculateItemDiscountAmount({
    required double price,
    required double quantity,
    DiscountType? type,
    double? value,
  }) {
    if (type == null || value == null || value <= 0) return 0.0;

    final gross = (price * quantity).roundHalfUp(2);

    if (type == DiscountType.percentage) {
      return (gross * value / 100).toDouble().roundHalfUp(2);
    } else {
      // Nominal: jangan melebihi gross
      return value.clamp(0, gross).toDouble().roundHalfUp(2);
    }
  }

  /// Hitung line total satu item.
  /// line_total = (price × qty) - discountAmount
  static double calculateLineTotal({
    required double price,
    required double quantity,
    required double discountAmount,
  }) {
    final gross = (price * quantity).roundHalfUp(2);
    return (gross - discountAmount).clamp(0.0, double.infinity).roundHalfUp(2);
  }

  /// Hitung summary lengkap transaksi.
  ///
  /// [items] daftar item di keranjang.
  /// [txnDiscountType] tipe diskon level transaksi (null = tidak ada diskon).
  /// [txnDiscountValue] nilai diskon level transaksi.
  /// [taxRate] rate pajak dalam persen (0 = tidak ada pajak).
  /// [isTaxInclusive] true = inclusive tax, false = exclusive tax.
  static PriceSummary calculateSummary({
    required List<CartItemInput> items,
    DiscountType? txnDiscountType,
    double txnDiscountValue = 0,
    double taxRate = 0,
    bool isTaxInclusive = false,
  }) {
    // Step 1 & 2: Hitung line_total tiap item, lalu sum → subtotal
    double subtotal = 0;
    for (final item in items) {
      final discountAmount = calculateItemDiscountAmount(
        price: item.sellingPrice,
        quantity: item.quantity,
        type: item.itemDiscountType,
        value: item.itemDiscountValue,
      );
      final lineTotal = calculateLineTotal(
        price: item.sellingPrice,
        quantity: item.quantity,
        discountAmount: discountAmount,
      );
      subtotal += lineTotal;
    }
    subtotal = subtotal.roundHalfUp(2);

    // Step 3: Hitung diskon transaksi dari subtotal
    double txnDiscountAmount = 0;
    if (txnDiscountType != null && txnDiscountValue > 0) {
      if (txnDiscountType == DiscountType.percentage) {
        txnDiscountAmount = (subtotal * txnDiscountValue / 100).roundHalfUp(2);
      } else {
        txnDiscountAmount = txnDiscountValue.clamp(0.0, subtotal).roundHalfUp(2);
      }
    }

    // Step 4: after_discount = subtotal - txn_discount
    final afterDiscount = (subtotal - txnDiscountAmount).roundHalfUp(2);

    // Step 5: Hitung pajak dari after_discount
    double taxAmount = 0;
    if (taxRate > 0) {
      if (!isTaxInclusive) {
        // Exclusive: after_discount × rate / 100
        taxAmount = (afterDiscount * taxRate / 100).toDouble().roundHalfUp(2);
      } else {
        // Inclusive: after_discount - (after_discount / (1 + rate/100))
        taxAmount =
            (afterDiscount - (afterDiscount / (1 + taxRate / 100)))
                .toDouble()
                .roundHalfUp(2);
      }
    }

    // Step 6: grand_total
    final grandTotal =
        isTaxInclusive
            ? afterDiscount.roundHalfUp(2)
            : (afterDiscount + taxAmount).roundHalfUp(2);

    return PriceSummary(
      subtotal: subtotal,
      txnDiscountAmount: txnDiscountAmount,
      afterDiscount: afterDiscount,
      taxAmount: taxAmount,
      grandTotal: grandTotal,
    );
  }
}
