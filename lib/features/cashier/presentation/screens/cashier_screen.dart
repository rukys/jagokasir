import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/app_lifecycle_provider.dart';
import '../../../../shared/widgets/currency_display.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../stock/domain/entities/stock_entity.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/barcode_scanner_listener.dart';
import '../widgets/cart_panel.dart';
import '../widgets/idle_lock_dialog.dart';
import '../widgets/product_catalog_panel.dart';

class CashierScreen extends ConsumerStatefulWidget {
  const CashierScreen({super.key});

  @override
  ConsumerState<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends ConsumerState<CashierScreen> {
  Timer? _idleTimer;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _startIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  // Resets the inactivity timer upon user interactions
  void _resetIdleTimer() {
    if (_isLocked) return;
    _idleTimer?.cancel();
    _startIdleTimer();
  }

  void _startIdleTimer() {
    final timeoutMinutes = ref.read(appLifecycleProvider);
    if (timeoutMinutes <= 0) return; // "Never" / Tidak Pernah

    _idleTimer = Timer(Duration(minutes: timeoutMinutes), () {
      _lockScreen();
    });
  }

  void _lockScreen() {
    final currentStaff = ref.read(currentStaffProvider);
    if (currentStaff == null || _isLocked || !mounted) return;

    setState(() {
      _isLocked = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return IdleLockDialog(
          staff: currentStaff,
          onUnlocked: () {
            setState(() {
              _isLocked = false;
            });
            _resetIdleTimer();
          },
        );
      },
    );
  }

  void _handleBarcodeScanned(String barcode) async {
    final products = ref.read(productListProvider).valueOrNull;
    final stocks = ref.read(stockListProvider).valueOrNull;

    if (products == null || stocks == null) {
      if (mounted) {
        ErrorSnackbar.showError(context, 'Data produk atau stok sedang dimuat...');
      }
      return;
    }

    try {
      final product = products.firstWhere(
        (p) => p.isActive && !p.isDeleted && (p.barcode == barcode || p.sku == barcode),
      );

      final stock = stocks.firstWhere(
            (s) => s.productId == product.id,
            orElse: () => StockEntity(
              id: '',
              productId: product.id,
              currentStock: 0,
              minimumStock: 0,
              trackStock: false,
              productName: product.name,
              productSku: product.sku,
              productUnit: product.unit,
            ),
          );

      await HapticFeedback.mediumImpact();
      final error = await ref.read(cartNotifierProvider.notifier).addItem(product, stock);

      if (error != null && mounted) {
        ErrorSnackbar.showError(context, error);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil menambahkan ${product.name} ke keranjang'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ErrorSnackbar.showError(context, 'Produk dengan barcode/SKU "$barcode" tidak ditemukan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(appLifecycleProvider, (previous, next) {
      _resetIdleTimer();
    });

    // Watch providers to preload cache and react to updates
    ref.watch(productListProvider);
    ref.watch(stockListProvider);

    final isTablet = MediaQuery.of(context).size.width >= 720;

    return BarcodeScannerListener(
      onBarcodeScanned: _handleBarcodeScanned,
      child: Listener(
        onPointerDown: (_) => _resetIdleTimer(),
        onPointerMove: (_) => _resetIdleTimer(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Kasir'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: 'Riwayat Transaksi',
                onPressed: () => context.push(AppRoutes.transactions),
              ),
              IconButton(
                icon: const Icon(Icons.lock_outline_rounded),
                tooltip: 'Kunci Layar',
                onPressed: _lockScreen,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
        ),
      ),
    );
  }

  // Split panel layout for tablets
  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Panel: Product Catalog
        Expanded(
          flex: 3,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            child: const ProductCatalogPanel(),
          ),
        ),
        // Right Panel: Cart
        const Expanded(
          flex: 2,
          child: CartPanel(),
        ),
      ],
    );
  }

  // Stacks Catalog and displays a floating Cart bar that slides up on phones
  Widget _buildPhoneLayout() {
    final cartState = ref.watch(cartNotifierProvider);

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: cartState.items.isNotEmpty ? 64.0 : 0.0,
            ),
            child: const ProductCatalogPanel(),
          ),
        ),
        if (cartState.items.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showCartBottomSheet(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${cartState.items.fold<double>(0, (sum, i) => sum + i.quantity).toStringAsFixed(0)} Item',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Lihat Keranjang',
                              style: TextStyle(
                                color: AppColors.primaryContainer,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            CurrencyDisplay(
                              amount: cartState.summary.grandTotal,
                              style: CurrencyDisplayStyle.normal,
                              color: Colors.white,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Slide up bottom sheet for phones
  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return CartPanel(scrollController: scrollController);
          },
        );
      },
    );
  }
}
