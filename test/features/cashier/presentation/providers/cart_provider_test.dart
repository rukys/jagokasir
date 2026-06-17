import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_kasir/core/utils/price_calculator.dart';
import 'package:pos_kasir/features/cashier/presentation/providers/cart_provider.dart';
import 'package:pos_kasir/features/products/domain/entities/product_entity.dart';
import 'package:pos_kasir/features/stock/domain/entities/stock_entity.dart';
import 'package:pos_kasir/features/tax_discount/domain/entities/tax_config_entity.dart';
import 'package:pos_kasir/features/tax_discount/presentation/providers/tax_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProductEntity testProduct;
  late StockEntity testStock;

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    testProduct = ProductEntity(
      id: 'prod-1',
      name: 'Kopi Susu',
      sku: 'KOPI01',
      sellingPrice: 15000,
      costPrice: 8000,
      categoryId: 'cat-1',
      unit: 'pcs',
      isActive: true,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testStock = const StockEntity(
      id: 'stk-1',
      productId: 'prod-1',
      currentStock: 10,
      minimumStock: 2,
      trackStock: true,
      productName: 'Kopi Susu',
      productSku: 'KOPI01',
      productUnit: 'pcs',
    );
  });

  ProviderContainer createContainer({TaxConfigEntity? activeTax}) {
    final container = ProviderContainer(
      overrides: [
        if (activeTax != null)
          activeTaxProvider.overrideWith((ref) => activeTax)
        else
          activeTaxProvider.overrideWith((ref) => null),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('CartNotifier - Basic Operations', () {
    test('Initial state is empty', () {
      final container = createContainer();
      final state = container.read(cartNotifierProvider);

      expect(state.items, isEmpty);
      expect(state.summary.subtotal, 0.0);
      expect(state.summary.grandTotal, 0.0);
    });

    test('addItem - stock available', () async {
      final container = createContainer();
      final notifier = container.read(cartNotifierProvider.notifier);

      final error = await notifier.addItem(testProduct, testStock, qty: 2);
      expect(error, isNull);

      final state = container.read(cartNotifierProvider);
      expect(state.items, hasLength(1));
      expect(state.items.first.productId, 'prod-1');
      expect(state.items.first.quantity, 2.0);
      expect(state.summary.subtotal, 30000.0);
      expect(state.summary.grandTotal, 30000.0);
    });

    test('addItem - stock insufficient', () async {
      final container = createContainer();
      final notifier = container.read(cartNotifierProvider.notifier);

      // Try adding 12 items while stock is only 10
      final error = await notifier.addItem(testProduct, testStock, qty: 12);
      expect(error, contains('Stok Kopi Susu tidak mencukupi'));

      final state = container.read(cartNotifierProvider);
      expect(state.items, isEmpty);
    });

    test('addItem - stock insufficient but negative stock allowed', () async {
      SharedPreferences.setMockInitialValues({'allow_negative_stock': true});

      final container = createContainer();
      final notifier = container.read(cartNotifierProvider.notifier);

      final error = await notifier.addItem(testProduct, testStock, qty: 12);
      expect(error, isNull);

      final state = container.read(cartNotifierProvider);
      expect(state.items, hasLength(1));
      expect(state.items.first.quantity, 12.0);
    });

    test('updateQuantity - increase within stock limit', () async {
      final container = createContainer();
      final notifier = container.read(cartNotifierProvider.notifier);

      await notifier.addItem(testProduct, testStock, qty: 1);
      final error = await notifier.updateQuantity('prod-1', 5, testStock);
      expect(error, isNull);

      final state = container.read(cartNotifierProvider);
      expect(state.items.first.quantity, 5.0);
      expect(state.summary.subtotal, 75000.0);
    });

    test('updateQuantity - zero or negative removes item', () async {
      final container = createContainer();
      final notifier = container.read(cartNotifierProvider.notifier);

      await notifier.addItem(testProduct, testStock, qty: 2);
      final error = await notifier.updateQuantity('prod-1', 0, testStock);
      expect(error, isNull);

      final state = container.read(cartNotifierProvider);
      expect(state.items, isEmpty);
    });

    test('removeItem - deletes item completely', () async {
      final container = createContainer();
      final notifier = container.read(cartNotifierProvider.notifier);

      await notifier.addItem(testProduct, testStock, qty: 2);
      notifier.removeItem('prod-1');

      final state = container.read(cartNotifierProvider);
      expect(state.items, isEmpty);
    });

    test('clearCart - resets everything', () async {
      final container = createContainer();
      final notifier = container.read(cartNotifierProvider.notifier);

      await notifier.addItem(testProduct, testStock, qty: 2);
      notifier.setTransactionDiscount(DiscountType.percentage, 10);
      notifier.clearCart();

      final state = container.read(cartNotifierProvider);
      expect(state.items, isEmpty);
      expect(state.txnDiscountType, isNull);
      expect(state.summary.grandTotal, 0.0);
    });
  });

  group('CartNotifier - Discounts & Taxes', () {
    test('setItemDiscount - percentage', () async {
      final container = createContainer();
      final notifier = container.read(cartNotifierProvider.notifier);

      await notifier.addItem(testProduct, testStock, qty: 2); // 30000 gross
      final error = notifier.setItemDiscount(
          'prod-1', DiscountType.percentage, 10,); // 10%
      expect(error, isNull);

      final state = container.read(cartNotifierProvider);
      expect(state.items.first.itemDiscountAmount, 3000.0);
      expect(state.items.first.lineTotal, 27000.0);
      expect(state.summary.subtotal, 27000.0);
    });

    test('setTransactionDiscount - nominal', () async {
      final container = createContainer();
      final notifier = container.read(cartNotifierProvider.notifier);

      await notifier.addItem(testProduct, testStock, qty: 2); // subtotal 30000
      final error = notifier.setTransactionDiscount(DiscountType.nominal, 5000);
      expect(error, isNull);

      final state = container.read(cartNotifierProvider);
      expect(state.txnDiscountType, DiscountType.nominal);
      expect(state.txnDiscountValue, 5000.0);
      expect(state.summary.txnDiscountAmount, 5000.0);
      expect(state.summary.grandTotal, 25000.0);
    });

    test('calculateSummary with exclusive tax configuration', () async {
      final tax = TaxConfigEntity(
        id: 'tax-1',
        name: 'PPN 10%',
        rate: 10,
        isInclusive: false,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final container = createContainer(activeTax: tax);
      final notifier = container.read(cartNotifierProvider.notifier);

      await notifier.addItem(testProduct, testStock, qty: 2); // subtotal 30000

      final state = container.read(cartNotifierProvider);
      expect(state.summary.taxAmount, 3000.0);
      expect(state.summary.grandTotal, 33000.0);
    });
  });
}
