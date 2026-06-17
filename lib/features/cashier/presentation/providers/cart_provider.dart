import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/price_calculator.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../stock/domain/entities/stock_entity.dart';
import '../../../tax_discount/domain/entities/tax_config_entity.dart';
import '../../../tax_discount/presentation/providers/tax_provider.dart';
import '../../domain/entities/cart_item_entity.dart';

part 'cart_provider.g.dart';

class CartState {
  final List<CartItemEntity> items;
  final DiscountType? txnDiscountType;
  final double? txnDiscountValue;
  final PriceSummary summary;

  const CartState({
    required this.items,
    this.txnDiscountType,
    this.txnDiscountValue,
    required this.summary,
  });

  factory CartState.empty() {
    return const CartState(
      items: [],
      txnDiscountType: null,
      txnDiscountValue: null,
      summary: PriceSummary(
        subtotal: 0,
        txnDiscountAmount: 0,
        afterDiscount: 0,
        taxAmount: 0,
        grandTotal: 0,
      ),
    );
  }

  CartState copyWith({
    List<CartItemEntity>? items,
    DiscountType? txnDiscountType,
    double? txnDiscountValue,
    PriceSummary? summary,
    bool clearDiscount = false,
  }) {
    return CartState(
      items: items ?? this.items,
      txnDiscountType: clearDiscount ? null : (txnDiscountType ?? this.txnDiscountType),
      txnDiscountValue: clearDiscount ? null : (txnDiscountValue ?? this.txnDiscountValue),
      summary: summary ?? this.summary,
    );
  }
}

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  CartState build() {
    // Watch active tax agar secara otomatis ter-recalculate saat setelan pajak aktif berubah
    final activeTax = ref.watch(activeTaxProvider).valueOrNull;

    List<CartItemEntity> items = [];
    DiscountType? discountType;
    double? discountValue;

    try {
      final oldState = state;
      items = oldState.items;
      discountType = oldState.txnDiscountType;
      discountValue = oldState.txnDiscountValue;
    } catch (_) {
      // First initialization, state is not yet initialized
    }

    return CartState(
      items: List.unmodifiable(items),
      txnDiscountType: discountType,
      txnDiscountValue: discountValue,
      summary: _calculateSummary(items, discountType, discountValue, activeTax),
    );
  }

  /// Menambah produk ke keranjang belanja
  Future<String?> addItem(ProductEntity product, StockEntity stock, {double qty = 1.0}) async {
    final prefs = await SharedPreferences.getInstance();
    final allowNegative = prefs.getBool('allow_negative_stock') ?? false;

    final existingIndex = state.items.indexWhere((item) => item.productId == product.id);
    final currentQty = existingIndex != -1 ? state.items[existingIndex].quantity : 0.0;
    final targetQty = currentQty + qty;

    // Cek batas stok jika track_stock aktif dan negative stock dilarang
    if (stock.trackStock && !allowNegative && stock.currentStock < targetQty) {
      return 'Stok ${product.name} tidak mencukupi. Tersisa: ${stock.currentStock} ${stock.productUnit}';
    }

    final newItems = List<CartItemEntity>.from(state.items);
    if (existingIndex != -1) {
      newItems[existingIndex] = newItems[existingIndex].copyWith(quantity: targetQty);
    } else {
      newItems.add(
        CartItemEntity(
          productId: product.id,
          productName: product.name,
          productSku: product.sku,
          sellingPrice: product.sellingPrice,
          costPrice: product.costPrice,
          unit: product.unit,
          trackStock: stock.trackStock,
          currentStock: stock.currentStock,
          quantity: qty,
        ),
      );
    }

    _updateState(items: newItems);
    return null;
  }

  /// Mengubah quantity item di keranjang
  Future<String?> updateQuantity(String productId, double quantity, StockEntity stock) async {
    if (quantity <= 0) {
      removeItem(productId);
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final allowNegative = prefs.getBool('allow_negative_stock') ?? false;

    // Cek batas stok jika track_stock aktif dan negative stock dilarang
    if (stock.trackStock && !allowNegative && stock.currentStock < quantity) {
      return 'Stok ${stock.productName} tidak mencukupi. Tersisa: ${stock.currentStock} ${stock.productUnit}';
    }

    final index = state.items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      final newItems = List<CartItemEntity>.from(state.items);
      newItems[index] = newItems[index].copyWith(quantity: quantity);
      _updateState(items: newItems);
    }
    return null;
  }

  /// Menghapus item dari keranjang
  void removeItem(String productId) {
    final newItems = List<CartItemEntity>.from(state.items)
      ..removeWhere((item) => item.productId == productId);
    _updateState(items: newItems);
  }

  /// Menyetel diskon item tertentu
  String? setItemDiscount(String productId, DiscountType? type, double? value) {
    final index = state.items.indexWhere((item) => item.productId == productId);
    if (index == -1) return 'Produk tidak ditemukan di keranjang';

    final newItems = List<CartItemEntity>.from(state.items);
    if (type == null || value == null || value <= 0) {
      newItems[index] = newItems[index].copyWith(clearDiscount: true);
      _updateState(items: newItems);
      return null;
    }

    final item = state.items[index];
    final gross = item.sellingPrice * item.quantity;

    if (type == DiscountType.percentage) {
      if (value < 0 || value > 100) {
        return 'Diskon persentase harus antara 0% - 100%';
      }
    } else {
      if (value < 0 || value > gross) {
        return 'Diskon nominal tidak boleh melebihi total harga item';
      }
    }

    newItems[index] = newItems[index].copyWith(
      discountType: type,
      discountValue: value,
    );
    _updateState(items: newItems);
    return null;
  }

  /// Menyetel diskon transaksi
  String? setTransactionDiscount(DiscountType? type, double? value) {
    if (type == null || value == null || value <= 0) {
      _updateState(clearDiscount: true);
      return null;
    }

    final subtotal = state.items.fold<double>(
      0.0,
      (sum, item) => sum + item.lineTotal,
    );

    if (type == DiscountType.percentage) {
      if (value < 0 || value > 100) {
        return 'Diskon persentase harus antara 0% - 100%';
      }
    } else {
      if (value < 0 || value > subtotal) {
        return 'Diskon nominal tidak boleh melebihi subtotal';
      }
    }

    _updateState(
      txnDiscountType: type,
      txnDiscountValue: value,
    );
    return null;
  }

  /// Mengosongkan keranjang belanja
  void clearCart() {
    _updateState(
      items: [],
      clearDiscount: true,
    );
  }

  PriceSummary _calculateSummary(
    List<CartItemEntity> items,
    DiscountType? txnDiscountType,
    double? txnDiscountValue,
    TaxConfigEntity? activeTax,
  ) {
    final inputItems = items.map((e) {
      return CartItemInput(
        sellingPrice: e.sellingPrice,
        quantity: e.quantity,
        itemDiscountType: e.discountType,
        itemDiscountValue: e.discountValue,
      );
    }).toList();

    return PriceCalculator.calculateSummary(
      items: inputItems,
      txnDiscountType: txnDiscountType,
      txnDiscountValue: txnDiscountValue ?? 0.0,
      taxRate: activeTax?.rate ?? 0.0,
      isTaxInclusive: activeTax?.isInclusive ?? false,
    );
  }

  void _updateState({
    List<CartItemEntity>? items,
    DiscountType? txnDiscountType,
    double? txnDiscountValue,
    bool clearDiscount = false,
  }) {
    final activeTax = ref.read(activeTaxProvider).valueOrNull;
    final finalItems = items ?? state.items;
    final finalDiscountType = clearDiscount ? null : (txnDiscountType ?? state.txnDiscountType);
    final finalDiscountValue = clearDiscount ? null : (txnDiscountValue ?? state.txnDiscountValue);

    state = CartState(
      items: List.unmodifiable(finalItems),
      txnDiscountType: finalDiscountType,
      txnDiscountValue: finalDiscountValue,
      summary: _calculateSummary(finalItems, finalDiscountType, finalDiscountValue, activeTax),
    );
  }
}
