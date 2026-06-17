import 'package:flutter/material.dart';
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
import '../../../stock/domain/entities/stock_entity.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../../tax_discount/domain/entities/discount_preset_entity.dart' as preset;
import '../../../tax_discount/presentation/providers/discount_provider.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_provider.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key, this.scrollController});
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
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
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
                    subtitle: 'Ketuk produk di katalog untuk menambahkan ke keranjang.',
                    icon: Icons.shopping_cart_outlined,
                  )
                : stocksAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Gagal sinkronisasi stok: $e')),
                    data: (stocks) {
                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                              ref.read(cartNotifierProvider.notifier).removeItem(item.productId);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Row(
                                          children: [
                                            Text(
                                              item.sellingPrice.formatRupiah(),
                                              style: TextStyle(
                                                color: theme.colorScheme.outline,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (item.discountType != null && item.discountValue != null) ...[
                                              const SizedBox(width: AppSpacing.sm),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: AppSpacing.sm - 2,
                                                  vertical: AppSpacing.xs / 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.warningLight,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.discountType == DiscountType.percentage
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
                                          color: item.discountType != null ? AppColors.warning : AppColors.outline,
                                          size: 20,
                                        ),
                                        onPressed: () => _showItemDiscountDialog(context, ref, item),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: AppColors.primary,
                                        ),
                                        onPressed: () async {
                                          final err = await ref
                                              .read(cartNotifierProvider.notifier)
                                              .updateQuantity(item.productId, item.quantity - 1, stock);
                                          if (err != null && context.mounted) {
                                            ErrorSnackbar.showError(context, err);
                                          }
                                        },
                                      ),
                                      GestureDetector(
                                        onTap: () => _showQtyEditDialog(context, ref, item, stock),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                            vertical: AppSpacing.xs,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.outlineVariant),
                                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                          ),
                                          child: Text(
                                            item.quantity % 1 == 0
                                                ? item.quantity.toStringAsFixed(0)
                                                : item.quantity.toStringAsFixed(1),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: AppColors.primary,
                                        ),
                                        onPressed: () async {
                                          final err = await ref
                                              .read(cartNotifierProvider.notifier)
                                              .updateQuantity(item.productId, item.quantity + 1, stock);
                                          if (err != null && context.mounted) {
                                            ErrorSnackbar.showError(context, err);
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
                  color: Colors.black.withValues(alpha: 0.05),
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
          content: const Text('Apakah Anda yakin ingin menghapus semua item dari keranjang belanja?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
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

  void _showQtyEditDialog(
    BuildContext context,
    WidgetRef ref,
    CartItemEntity item,
    StockEntity stock,
  ) {
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
    BuildContext context,
    WidgetRef ref,
    CartItemEntity item,
  ) {
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
                        label: Text('% Persen'),
                      ),
                      ButtonSegment(
                        value: DiscountType.nominal,
                        label: Text('Rp Nominal'),
                      ),
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
                  child: const Text(
                    'Hapus Diskon',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(valueController.text);
                    if (val == null || val < 0) {
                      ErrorSnackbar.showError(context, 'Nilai diskon tidak valid');
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
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    final presetsAsync = ref.watch(activeDiscountPresetsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Collapsible Transaction Discount Preset Dropdown / Manual Input
          ExpansionTile(
            title: const Text('Diskon Transaksi', style: TextStyle(fontSize: 14)),
            dense: true,
            shape: const Border(),
            collapsedShape: const Border(),
            trailing: cartState.txnDiscountType != null
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm - 2,
                      vertical: AppSpacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      cartState.txnDiscountType == DiscountType.percentage
                          ? '-${cartState.txnDiscountValue!.toStringAsFixed(0)}%'
                          : '-${cartState.txnDiscountValue!.formatRupiahCompact()}',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
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
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (presets.isNotEmpty) ...[
                          const Text(
                            'Presets aktif:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: presets.map((p) {
                              final isSelected = cartState.txnDiscountValue == p.value;
                              return ChoiceChip(
                                label: Text(
                                  '${p.name} (${p.type == preset.DiscountType.percentage ? '${p.value.toStringAsFixed(0)}%' : p.value.formatRupiahCompact()})',
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  ref.read(cartNotifierProvider.notifier).setTransactionDiscount(
                                        selected
                                            ? (p.type == preset.DiscountType.percentage
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
                          onPressed: () => _showManualTxnDiscountDialog(context, ref, cartState),
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
          _buildSummaryRow('Subtotal', cartState.summary.subtotal.formatRupiah()),
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
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                Text(
                  'PROSES PEMBAYARAN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
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
          Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showManualTxnDiscountDialog(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    DiscountType selectedType = cartState.txnDiscountType ?? DiscountType.percentage;
    final valueController = TextEditingController(
      text: cartState.txnDiscountValue != null ? cartState.txnDiscountValue.toString() : '',
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
                        label: Text('% Persen'),
                      ),
                      ButtonSegment(
                        value: DiscountType.nominal,
                        label: Text('Rp Nominal'),
                      ),
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
                  child: const Text(
                    'Hapus Diskon',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(valueController.text);
                    if (val == null || val < 0) {
                      ErrorSnackbar.showError(context, 'Nilai diskon tidak valid');
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
