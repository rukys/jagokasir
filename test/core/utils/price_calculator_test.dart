import 'package:flutter_test/flutter_test.dart';
import 'package:pos_kasir/core/utils/price_calculator.dart';

void main() {
  group('PriceCalculator - Item Discount', () {
    test('calculateItemDiscountAmount - no discount', () {
      final amount = PriceCalculator.calculateItemDiscountAmount(
        price: 10000,
        quantity: 2,
        type: null,
        value: null,
      );
      expect(amount, 0.0);
    });

    test('calculateItemDiscountAmount - percentage discount', () {
      final amount = PriceCalculator.calculateItemDiscountAmount(
        price: 10000,
        quantity: 2.5, // 25000 gross
        type: DiscountType.percentage,
        value: 10, // 10%
      );
      expect(amount, 2500.0);
    });

    test('calculateItemDiscountAmount - nominal discount within range', () {
      final amount = PriceCalculator.calculateItemDiscountAmount(
        price: 15000,
        quantity: 2, // 30000 gross
        type: DiscountType.nominal,
        value: 5000,
      );
      expect(amount, 5000.0);
    });

    test('calculateItemDiscountAmount - nominal discount exceeding gross', () {
      final amount = PriceCalculator.calculateItemDiscountAmount(
        price: 5000,
        quantity: 2, // 10000 gross
        type: DiscountType.nominal,
        value: 15000, // Exceeds gross
      );
      expect(amount, 10000.0); // Clamped to gross
    });
  });

  group('PriceCalculator - Line Total', () {
    test('calculateLineTotal - standard calculations', () {
      final lineTotal = PriceCalculator.calculateLineTotal(
        price: 10000,
        quantity: 3,
        discountAmount: 2000,
      );
      expect(lineTotal, 28000.0);
    });

    test('calculateLineTotal - discount matches gross', () {
      final lineTotal = PriceCalculator.calculateLineTotal(
        price: 10000,
        quantity: 2,
        discountAmount: 20000,
      );
      expect(lineTotal, 0.0);
    });
  });

  group('PriceCalculator - Summary Calculations', () {
    final testItems = [
      const CartItemInput(
        sellingPrice: 10000,
        quantity: 2, // 20000 gross, no item discount
      ),
      const CartItemInput(
        sellingPrice: 15000,
        quantity: 1,
        itemDiscountType: DiscountType.percentage,
        itemDiscountValue: 10, // 15000 gross, 1500 discount -> 13500 line total
      ),
      const CartItemInput(
        sellingPrice: 8000,
        quantity: 3,
        itemDiscountType: DiscountType.nominal,
        itemDiscountValue: 4000, // 24000 gross, 4000 discount -> 20000 line total
      ),
    ];

    test('calculateSummary - no transaction discount, no tax', () {
      // subtotal = 20000 + 13500 + 20000 = 53500
      final summary = PriceCalculator.calculateSummary(
        items: testItems,
        txnDiscountType: null,
        txnDiscountValue: 0,
        taxRate: 0,
        isTaxInclusive: false,
      );

      expect(summary.subtotal, 53500.0);
      expect(summary.txnDiscountAmount, 0.0);
      expect(summary.afterDiscount, 53500.0);
      expect(summary.taxAmount, 0.0);
      expect(summary.grandTotal, 53500.0);
    });

    test('calculateSummary - percentage transaction discount, no tax', () {
      // subtotal = 53500. 10% discount = 5350. afterDiscount = 48150
      final summary = PriceCalculator.calculateSummary(
        items: testItems,
        txnDiscountType: DiscountType.percentage,
        txnDiscountValue: 10,
        taxRate: 0,
        isTaxInclusive: false,
      );

      expect(summary.subtotal, 53500.0);
      expect(summary.txnDiscountAmount, 5350.0);
      expect(summary.afterDiscount, 48150.0);
      expect(summary.taxAmount, 0.0);
      expect(summary.grandTotal, 48150.0);
    });

    test('calculateSummary - nominal transaction discount, exclusive tax', () {
      // subtotal = 53500. discount = 3500. afterDiscount = 50000.
      // tax exclusive 11% of 50000 = 5500.
      // grandTotal = 50000 + 5500 = 55500
      final summary = PriceCalculator.calculateSummary(
        items: testItems,
        txnDiscountType: DiscountType.nominal,
        txnDiscountValue: 3500,
        taxRate: 11,
        isTaxInclusive: false,
      );

      expect(summary.subtotal, 53500.0);
      expect(summary.txnDiscountAmount, 3500.0);
      expect(summary.afterDiscount, 50000.0);
      expect(summary.taxAmount, 5500.0);
      expect(summary.grandTotal, 55500.0);
    });

    test('calculateSummary - nominal transaction discount, inclusive tax', () {
      // subtotal = 53500. discount = 3500. afterDiscount = 50000.
      // tax inclusive 11% -> 50000 - (50000 / 1.11) = 50000 - 45045.05 = 4954.95
      // grandTotal = 50000
      final summary = PriceCalculator.calculateSummary(
        items: testItems,
        txnDiscountType: DiscountType.nominal,
        txnDiscountValue: 3500,
        taxRate: 11,
        isTaxInclusive: true,
      );

      expect(summary.subtotal, 53500.0);
      expect(summary.txnDiscountAmount, 3500.0);
      expect(summary.afterDiscount, 50000.0);
      expect(summary.taxAmount, 4954.95); // rounded
      expect(summary.grandTotal, 50000.0);
    });
  });
}
