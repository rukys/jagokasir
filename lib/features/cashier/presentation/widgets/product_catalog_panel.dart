import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/category_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../stock/domain/entities/stock_entity.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../providers/cart_provider.dart';
import 'product_item_card.dart';

class ProductCatalogPanel extends ConsumerStatefulWidget {
  const ProductCatalogPanel({super.key});

  @override
  ConsumerState<ProductCatalogPanel> createState() => _ProductCatalogPanelState();
}

class _ProductCatalogPanelState extends ConsumerState<ProductCatalogPanel> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  Timer? _debounce;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  StockEntity _getStockForProduct(ProductEntity product, List<StockEntity> stocks) {
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

  String _formatStock(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
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
              final activeProducts = products.where((p) => p.isActive && !p.isDeleted).toList();

              if (activeProducts.isEmpty) {
                return const EmptyState(
                  title: 'Produk Tidak Ditemukan',
                  subtitle: 'Silakan tambah produk baru atau bersihkan pencarian.',
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
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.76,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    itemCount: activeProducts.length,
                    itemBuilder: (context, index) {
                      final product = activeProducts[index];
                      final stock = _getStockForProduct(product, stocks);

                      return ProductItemCard(
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

  void _showProductDetailDialog(
    BuildContext context,
    ProductEntity product,
    StockEntity stock,
  ) {
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
                        image: FileImage(File(product.imagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              _buildDetailRow('SKU', product.sku),
              _buildDetailRow('Satuan', product.unit),
              _buildDetailRow('Kategori', product.categoryName ?? 'Uncategorized'),
              _buildDetailRow('Harga Jual', product.sellingPrice.formatRupiah()),
              if (stock.trackStock) ...[
                _buildDetailRow('Stok Saat Ini', '${_formatStock(stock.currentStock)} ${stock.productUnit}'),
                _buildDetailRow('Stok Minimum', '${_formatStock(stock.minimumStock)} ${stock.productUnit}'),
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
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.outline),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
