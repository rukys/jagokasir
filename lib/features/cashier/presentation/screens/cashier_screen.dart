import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../shared/widgets/currency_display.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/providers/app_lifecycle_provider.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/category_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../stock/domain/entities/stock_entity.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../../tax_discount/domain/entities/discount_preset_entity.dart'
    as preset;
import '../../../tax_discount/presentation/providers/discount_provider.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_provider.dart';

class CashierScreen extends ConsumerStatefulWidget {
  const CashierScreen({super.key});

  @override
  ConsumerState<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends ConsumerState<CashierScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  Timer? _debounce;
  Timer? _idleTimer;
  bool _isLocked = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startIdleTimer();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _idleTimer?.cancel();
    _searchController.dispose();
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
        return _IdleLockDialog(
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

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(appLifecycleProvider, (previous, next) {
      _resetIdleTimer();
    });

    final isTablet = MediaQuery.of(context).size.width >= 720;

    return Listener(
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
            child: _buildCatalogSection(),
          ),
        ),
        // Right Panel: Cart
        const Expanded(
          flex: 2,
          child: _CartPanel(),
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
            child: _buildCatalogSection(),
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
                    color: Colors.black.withOpacity(0.15),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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

  // Main catalog section with filters, search, and products grid
  Widget _buildCatalogSection() {
    final categoriesAsync = ref.watch(categoryListProvider);
    final productsAsync = ref.watch(
      filteredProductsProvider(
        searchQuery: _searchQuery,
        categoryId: _selectedCategoryId,
      ),
    );
    final stocksAsync = ref.watch(stockListProvider);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.md,
            AppSpacing.pagePadding,
            0,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari nama produk atau SKU...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        // Categories Filter Chips
        categoriesAsync.when(
          loading: () => const SizedBox(height: 56),
          error: (_, __) => const SizedBox(height: 56),
          data: (categories) {
            final activeCats = categories.where((c) => !c.isDeleted).toList();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding),
                  itemCount: activeCats.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final category = isAll ? null : activeCats[index - 1];
                    final isSelected = isAll
                        ? _selectedCategoryId == null
                        : _selectedCategoryId == category?.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(isAll ? 'Semua Kategori' : category!.name),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = isAll ? null : category!.id;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        // Products Catalog Grid
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => Center(
              child: Text('Gagal memuat produk: $e'),
            ),
            data: (products) {
              final activeProducts =
                  products.where((p) => p.isActive && !p.isDeleted).toList();

              if (activeProducts.isEmpty) {
                return const EmptyState(
                  title: 'Produk Tidak Ditemukan',
                  subtitle:
                      'Silakan tambah produk baru atau bersihkan pencarian.',
                  icon: Icons.inventory_2_outlined,
                );
              }

              return stocksAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text('Gagal memuat stok: $e'),
                ),
                data: (stocks) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.76,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    itemCount: activeProducts.length,
                    itemBuilder: (context, index) {
                      final product = activeProducts[index];
                      final stock = _getStockForProduct(product, stocks);

                      return _ProductGridCard(
                        product: product,
                        stock: stock,
                        onTap: () async {
                          await HapticFeedback.lightImpact();
                          final err = await ref
                              .read(cartNotifierProvider.notifier)
                              .addItem(product, stock);
                          if (err != null && context.mounted) {
                            ErrorSnackbar.showError(context, err);
                          }
                        },
                        onLongPress: () {
                          _showProductDetailDialog(context, product, stock);
                        },
                      );
                    },
                  );
                },
              );
            },
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _CartPanel(scrollController: scrollController);
          },
        );
      },
    );
  }

  StockEntity _getStockForProduct(
      ProductEntity product, List<StockEntity> stocks) {
    return stocks.cast<StockEntity>().firstWhere(
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
            productImagePath: product.imagePath,
          ),
        );
  }

  void _showProductDetailDialog(
      BuildContext context, ProductEntity product, StockEntity stock) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.imagePath != null && product.imagePath!.isNotEmpty)
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      image: DecorationImage(
                        image: NetworkImage(
                            product.imagePath!), // placeholder or local image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              _buildDetailRow('SKU', product.sku),
              _buildDetailRow('Satuan', product.unit),
              _buildDetailRow(
                  'Kategori', product.categoryName ?? 'Uncategorized'),
              _buildDetailRow(
                  'Harga Jual', product.sellingPrice.formatRupiah()),
              if (stock.trackStock) ...[
                _buildDetailRow('Stok Saat Ini',
                    '${_formatStock(stock.currentStock)} ${stock.productUnit}'),
                _buildDetailRow('Stok Minimum',
                    '${_formatStock(stock.minimumStock)} ${stock.productUnit}'),
              ] else
                _buildDetailRow('Pantau Stok', 'Nonaktif'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.outline),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _formatStock(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

// Product display card in grid catalog
class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({
    required this.product,
    required this.stock,
    required this.onTap,
    required this.onLongPress,
  });

  final ProductEntity product;
  final StockEntity stock;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image / placeholder
            Expanded(
              child: Container(
                color: AppColors.primaryContainer.withOpacity(0.15),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            // Info info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    product.sku,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  CurrencyDisplay(
                    amount: product.sellingPrice,
                    style: CurrencyDisplayStyle.small,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Stock alert badge
                  if (stock.trackStock)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm - 2,
                          vertical: AppSpacing.xs / 2),
                      decoration: BoxDecoration(
                        color: stock.isLowStock
                            ? AppColors.stockLowBg
                            : AppColors.stockOkBg,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        stock.isLowStock
                            ? 'Stok Rendah: ${_formatStock(stock.currentStock)}'
                            : 'Stok: ${_formatStock(stock.currentStock)}',
                        style: TextStyle(
                          color: stock.isLowStock
                              ? AppColors.stockLow
                              : AppColors.stockOk,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm - 2,
                          vertical: AppSpacing.xs / 2),
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withOpacity(0.3),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: const Text(
                        'Tanpa Stok',
                        style: TextStyle(
                          color: AppColors.outline,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Side-by-side or sliding bottom sheet Cart Panel
class _CartPanel extends ConsumerWidget {
  const _CartPanel({this.scrollController});
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    final stocksAsync = ref.watch(stockListProvider);
    final theme = Theme.of(context);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Keranjang Belanja',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (cartState.items.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                    label: const Text('Bersihkan'),
                    style:
                        TextButton.styleFrom(foregroundColor: AppColors.danger),
                    onPressed: () {
                      _showClearConfirm(context, ref);
                    },
                  ),
              ],
            ),
          ),
          const Divider(),
          // Cart Items List
          Expanded(
            child: cartState.items.isEmpty
                ? const EmptyState(
                    title: 'Keranjang Kosong',
                    subtitle:
                        'Ketuk produk di katalog untuk menambahkan ke keranjang.',
                    icon: Icons.shopping_cart_outlined,
                  )
                : stocksAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Gagal sinkronisasi stok: $e')),
                    data: (stocks) {
                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        itemCount: cartState.items.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = cartState.items[index];
                          final stock = stocks.cast<StockEntity>().firstWhere(
                                (s) => s.productId == item.productId,
                                orElse: () => StockEntity(
                                  id: '',
                                  productId: item.productId,
                                  currentStock: 0,
                                  minimumStock: 0,
                                  trackStock: false,
                                  productName: item.productName,
                                  productSku: item.productSku,
                                  productUnit: 'pcs',
                                ),
                              );

                          return Dismissible(
                            key: Key(item.productId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: AppColors.danger,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            onDismissed: (_) {
                              ref
                                  .read(cartNotifierProvider.notifier)
                                  .removeItem(item.productId);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Row(
                                          children: [
                                            Text(
                                              item.sellingPrice.formatRupiah(),
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.outline,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (item.discountType != null &&
                                                item.discountValue != null) ...[
                                              const SizedBox(
                                                  width: AppSpacing.sm),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        AppSpacing.sm - 2,
                                                    vertical:
                                                        AppSpacing.xs / 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.warningLight,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.discountType ==
                                                          DiscountType
                                                              .percentage
                                                      ? '-${item.discountValue!.toStringAsFixed(0)}%'
                                                      : '-${item.discountValue!.formatRupiahCompact()}',
                                                  style: const TextStyle(
                                                    color: AppColors.warning,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.lineTotal.formatRupiah(),
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.local_offer_outlined,
                                          color: item.discountType != null
                                              ? AppColors.warning
                                              : AppColors.outline,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _showItemDiscountDialog(
                                                context, ref, item),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: AppColors.primary),
                                        onPressed: () async {
                                          final err = await ref
                                              .read(
                                                  cartNotifierProvider.notifier)
                                              .updateQuantity(item.productId,
                                                  item.quantity - 1, stock);
                                          if (err != null && context.mounted) {
                                            ErrorSnackbar.showError(
                                                context, err);
                                          }
                                        },
                                      ),
                                      GestureDetector(
                                        onTap: () => _showQtyEditDialog(
                                            context, ref, item, stock),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xs),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    AppColors.outlineVariant),
                                            borderRadius: BorderRadius.circular(
                                                AppSpacing.radiusSm),
                                          ),
                                          child: Text(
                                            item.quantity % 1 == 0
                                                ? item.quantity
                                                    .toStringAsFixed(0)
                                                : item.quantity
                                                    .toStringAsFixed(1),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: AppColors.primary),
                                        onPressed: () async {
                                          final err = await ref
                                              .read(
                                                  cartNotifierProvider.notifier)
                                              .updateQuantity(item.productId,
                                                  item.quantity + 1, stock);
                                          if (err != null && context.mounted) {
                                            ErrorSnackbar.showError(
                                                context, err);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          const Divider(),
          // Summary calculations & checkout
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _buildSummarySection(context, ref, cartState),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirm(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kosongkan Keranjang?'),
          content: const Text(
              'Apakah Anda yakin ingin menghapus semua item dari keranjang belanja?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () {
                ref.read(cartNotifierProvider.notifier).clearCart();
                Navigator.pop(context);
              },
              child: const Text('Ya, Bersihkan'),
            ),
          ],
        );
      },
    );
  }

  void _showQtyEditDialog(BuildContext context, WidgetRef ref,
      CartItemEntity item, StockEntity stock) {
    final controller = TextEditingController(text: item.quantity.toString());
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Jumlah ${item.productName}'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: item.unit,
              hintText: 'Masukkan jumlah',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final qty = double.tryParse(controller.text);
                if (qty == null || qty < 0) {
                  ErrorSnackbar.showError(context, 'Jumlah tidak valid');
                  return;
                }
                final err = await ref
                    .read(cartNotifierProvider.notifier)
                    .updateQuantity(item.productId, qty, stock);
                if (err != null) {
                  if (context.mounted) ErrorSnackbar.showError(context, err);
                } else {
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showItemDiscountDialog(
      BuildContext context, WidgetRef ref, CartItemEntity item) {
    DiscountType selectedType = item.discountType ?? DiscountType.percentage;
    final valueController = TextEditingController(
      text: item.discountValue != null ? item.discountValue.toString() : '',
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Diskon Item: ${item.productName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<DiscountType>(
                    segments: const [
                      ButtonSegment(
                          value: DiscountType.percentage,
                          label: Text('% Persen')),
                      ButtonSegment(
                          value: DiscountType.nominal,
                          label: Text('Rp Nominal')),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (typeSet) {
                      setState(() {
                        selectedType = typeSet.first;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: selectedType == DiscountType.percentage
                          ? 'Contoh: 10 (%)'
                          : 'Contoh: 5000 (Rupiah)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref
                        .read(cartNotifierProvider.notifier)
                        .setItemDiscount(item.productId, null, null);
                    Navigator.pop(context);
                  },
                  child: const Text('Hapus Diskon',
                      style: TextStyle(color: AppColors.danger)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(valueController.text);
                    if (val == null || val < 0) {
                      ErrorSnackbar.showError(
                          context, 'Nilai diskon tidak valid');
                      return;
                    }

                    final err = ref
                        .read(cartNotifierProvider.notifier)
                        .setItemDiscount(item.productId, selectedType, val);
                    if (err != null) {
                      ErrorSnackbar.showError(context, err);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummarySection(
      BuildContext context, WidgetRef ref, CartState cartState) {
    final presetsAsync = ref.watch(activeDiscountPresetsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Collapsible Transaction Discount Preset Dropdown / Manual Input
          ExpansionTile(
            title:
                const Text('Diskon Transaksi', style: TextStyle(fontSize: 14)),
            dense: true,
            shape: const Border(),
            collapsedShape: const Border(),
            trailing: cartState.txnDiscountType != null
                ? Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm - 2,
                        vertical: AppSpacing.xs / 2),
                    decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      cartState.txnDiscountType == DiscountType.percentage
                          ? '-${cartState.txnDiscountValue!.toStringAsFixed(0)}%'
                          : '-${cartState.txnDiscountValue!.formatRupiahCompact()}',
                      style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : const Icon(Icons.add_rounded),
            children: [
              presetsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Gagal presets: $e'),
                data: (presets) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (presets.isNotEmpty) ...[
                          const Text('Presets aktif:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: presets.map((p) {
                              final isSelected =
                                  cartState.txnDiscountValue == p.value;
                              return ChoiceChip(
                                label: Text(
                                    '${p.name} (${p.type == preset.DiscountType.percentage ? '${p.value.toStringAsFixed(0)}%' : p.value.formatRupiahCompact()})'),
                                selected: isSelected,
                                onSelected: (selected) {
                                  ref
                                      .read(cartNotifierProvider.notifier)
                                      .setTransactionDiscount(
                                        selected
                                            ? (p.type ==
                                                    preset
                                                        .DiscountType.percentage
                                                ? DiscountType.percentage
                                                : DiscountType.nominal)
                                            : null,
                                        selected ? p.value : null,
                                      );
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        // Manual input button
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('Input Manual Diskon Transaksi'),
                          onPressed: () => _showManualTxnDiscountDialog(
                              context, ref, cartState),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Price summary list
          _buildSummaryRow(
              'Subtotal', cartState.summary.subtotal.formatRupiah()),
          if (cartState.summary.txnDiscountAmount > 0)
            _buildSummaryRow(
              'Diskon Transaksi',
              '- ${cartState.summary.txnDiscountAmount.formatRupiah()}',
              valueColor: AppColors.warning,
            ),
          if (cartState.summary.taxAmount > 0)
            _buildSummaryRow(
              'Pajak (${cartState.summary.grandTotal == cartState.summary.afterDiscount ? 'Inclusive' : 'Exclusive'})',
              cartState.summary.taxAmount.formatRupiah(),
            ),
          const SizedBox(height: AppSpacing.sm),
          // Grand total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL AKHIR',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              CurrencyDisplay(
                amount: cartState.summary.grandTotal,
                style: CurrencyDisplayStyle.medium,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Bayar button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            onPressed: cartState.items.isEmpty
                ? null
                : () {
                    // Close dialog if phone sheet
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    context.push(AppRoutes.payment);
                  },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment_rounded),
                SizedBox(width: AppSpacing.sm),
                Text('PROSES PEMBAYARAN',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.outline, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? AppColors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showManualTxnDiscountDialog(
      BuildContext context, WidgetRef ref, CartState cartState) {
    DiscountType selectedType =
        cartState.txnDiscountType ?? DiscountType.percentage;
    final valueController = TextEditingController(
      text: cartState.txnDiscountValue != null
          ? cartState.txnDiscountValue.toString()
          : '',
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Diskon Transaksi Manual'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<DiscountType>(
                    segments: const [
                      ButtonSegment(
                          value: DiscountType.percentage,
                          label: Text('% Persen')),
                      ButtonSegment(
                          value: DiscountType.nominal,
                          label: Text('Rp Nominal')),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (typeSet) {
                      setState(() {
                        selectedType = typeSet.first;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: selectedType == DiscountType.percentage
                          ? 'Contoh: 15 (%)'
                          : 'Contoh: 10000 (Rupiah)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref
                        .read(cartNotifierProvider.notifier)
                        .setTransactionDiscount(null, null);
                    Navigator.pop(context);
                  },
                  child: const Text('Hapus Diskon',
                      style: TextStyle(color: AppColors.danger)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(valueController.text);
                    if (val == null || val < 0) {
                      ErrorSnackbar.showError(
                          context, 'Nilai diskon tidak valid');
                      return;
                    }

                    final err = ref
                        .read(cartNotifierProvider.notifier)
                        .setTransactionDiscount(selectedType, val);
                    if (err != null) {
                      ErrorSnackbar.showError(context, err);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Full-screen overlay requested when inactivity triggers
class _IdleLockDialog extends StatefulWidget {
  const _IdleLockDialog({required this.staff, required this.onUnlocked});

  final StaffEntity staff;
  final VoidCallback onUnlocked;

  @override
  State<_IdleLockDialog> createState() => _IdleLockDialogState();
}

class _IdleLockDialogState extends State<_IdleLockDialog> {
  final _shakeController = ShakeController();
  String _pin = '';
  bool _isLoading = false;

  void _onKeyPress(String val) {
    if (_isLoading || _pin.length >= 6) return;
    setState(() {
      _pin += val;
    });
  }

  void _onBackspace() {
    if (_isLoading || _pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog.fullscreen(
      backgroundColor: AppColors.background,
      child: Consumer(
        builder: (context, ref, _) {
          Future<void> onSubmit() async {
            if (_isLoading || _pin.length < 4) return;

            setState(() {
              _isLoading = true;
            });

            final authNotifier = ref.read(authNotifierProvider.notifier);
            final success = await authNotifier.login(widget.staff.id, _pin);

            if (!mounted) return;

            if (success) {
              widget.onUnlocked();
              Navigator.pop(context);
            } else {
              _shakeController.shake();
              setState(() {
                _pin = '';
                _isLoading = false;
              });
              ErrorSnackbar.showError(context, 'PIN yang Anda masukkan salah');
            }
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Layar Terkunci',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Masukkan PIN untuk membuka sesi kasir ${widget.staff.name}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.outline),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // PIN Dots
                  ShakeWidget(
                    controller: _shakeController,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final hasValue = index < _pin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: hasValue
                                ? AppColors.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.outline, width: 2),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  // Numpad 4x3
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (var i = 1; i <= 9; i++)
                          _NumpadButton(
                            label: '$i',
                            onPressed: () => _onKeyPress('$i'),
                          ),
                        IconButton(
                          icon: const Icon(Icons.backspace_outlined),
                          onPressed: _onBackspace,
                        ),
                        _NumpadButton(
                          label: '0',
                          onPressed: () => _onKeyPress('0'),
                        ),
                        TextButton(
                          onPressed: _pin.length >= 4 ? onSubmit : null,
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _pin.length >= 4
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const LinearProgressIndicator(color: AppColors.primary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  const _NumpadButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    super.key,
    required this.child,
    required this.controller,
  });

  final Widget child;
  final ShakeController controller;

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 12.0), weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 12.0, end: -12.0), weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: -12.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 8.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -8.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(_animController);

    widget.controller._state = this;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void shake() {
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class ShakeController {
  _ShakeWidgetState? _state;
  void shake() {
    _state?.shake();
  }
}
