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
  final List<CartItemEntity> _items = [];
  DiscountType? _txnDiscountType;
  double? _txnDiscountValue;

  @override
  CartState build() {
    // Watch active tax agar secara otomatis ter-recalculate saat setelan pajak aktif berubah
    final activeTax = ref.watch(activeTaxProvider).valueOrNull;

    return CartState(
      items: List.unmodifiable(_items),
      txnDiscountType: _txnDiscountType,
      txnDiscountValue: _txnDiscountValue,
      summary: _calculateSummary(activeTax),
    );
  }

  /// Menambah produk ke keranjang belanja
  Future<String?> addItem(ProductEntity product, StockEntity stock, {double qty = 1.0}) async {
    final prefs = await SharedPreferences.getInstance();
    final allowNegative = prefs.getBool('allow_negative_stock') ?? false;

    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    final currentQty = existingIndex != -1 ? _items[existingIndex].quantity : 0.0;
    final targetQty = currentQty + qty;

    // Cek batas stok jika track_stock aktif dan negative stock dilarang
    if (stock.trackStock && !allowNegative && stock.currentStock < targetQty) {
      return 'Stok ${product.name} tidak mencukupi. Tersisa: ${stock.currentStock} ${stock.productUnit}';
    }

    if (existingIndex != -1) {
      _items[existingIndex] = _items[existingIndex].copyWith(quantity: targetQty);
    } else {
      _items.add(
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

    _updateState();
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

    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _updateState();
    }
    return null;
  }

  /// Menghapus item dari keranjang
  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    _updateState();
  }

  /// Menyetel diskon item tertentu
  String? setItemDiscount(String productId, DiscountType? type, double? value) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index == -1) return 'Produk tidak ditemukan di keranjang';

    if (type == null || value == null || value <= 0) {
      _items[index] = _items[index].copyWith(clearDiscount: true);
      _updateState();
      return null;
    }

    final item = _items[index];
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

    _items[index] = _items[index].copyWith(
      discountType: type,
      discountValue: value,
    );
    _updateState();
    return null;
  }

  /// Menyetel diskon transaksi
  String? setTransactionDiscount(DiscountType? type, double? value) {
    if (type == null || value == null || value <= 0) {
      _txnDiscountType = null;
      _txnDiscountValue = null;
      _updateState();
      return null;
    }

    final subtotal = _items.fold<double>(
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

    _txnDiscountType = type;
    _txnDiscountValue = value;
    _updateState();
    return null;
  }

  /// Mengosongkan keranjang belanja
  void clearCart() {
    _items.clear();
    _txnDiscountType = null;
    _txnDiscountValue = null;
    _updateState();
  }

  PriceSummary _calculateSummary(TaxConfigEntity? activeTax) {
    final inputItems = _items.map((e) {
      return CartItemInput(
        sellingPrice: e.sellingPrice,
        quantity: e.quantity,
        itemDiscountType: e.discountType,
        itemDiscountValue: e.discountValue,
      );
    }).toList();

    return PriceCalculator.calculateSummary(
      items: inputItems,
      txnDiscountType: _txnDiscountType,
      txnDiscountValue: _txnDiscountValue ?? 0.0,
      taxRate: activeTax?.rate ?? 0.0,
      isTaxInclusive: activeTax?.isInclusive ?? false,
    );
  }

  void _updateState() {
    final activeTax = ref.read(activeTaxProvider).valueOrNull;
    state = CartState(
      items: List.unmodifiable(_items),
      txnDiscountType: _txnDiscountType,
      txnDiscountValue: _txnDiscountValue,
      summary: _calculateSummary(activeTax),
    );
  }
}
