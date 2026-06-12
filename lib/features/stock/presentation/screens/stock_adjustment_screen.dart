// lib/features/stock/presentation/screens/stock_adjustment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../domain/entities/stock_entity.dart';
import '../providers/stock_provider.dart';

/// Parameter yang diterima via GoRouter `extra`.
/// `productId` null → tampilkan product picker di dalam screen.
class StockAdjustmentScreen extends ConsumerStatefulWidget {
  const StockAdjustmentScreen({
    super.key,
    this.productId,
    this.productName,
  });

  final String? productId;
  final String? productName;

  @override
  ConsumerState<StockAdjustmentScreen> createState() =>
      _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState
    extends ConsumerState<StockAdjustmentScreen> {
  // ── State ────────────────────────────────────────────────────────────────
  String? _selectedProductId;

  bool _isAdding = true; // true = tambah stok, false = kurang stok
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _reason = 'RESTOCK';

  // Dropdown item: tampilkan label tapi simpan reason
  String _reasonLabel = 'Restock / Stok Masuk';

  static const _reasonItems = [
    ('RESTOCK', 'Restock / Stok Masuk'),
    ('ADJUSTMENT', 'Koreksi / Selisih Stok'),
    ('ADJUSTMENT', 'Barang Rusak'),
    ('ADJUSTMENT', 'Barang Hilang'),
    ('ADJUSTMENT', 'Lainnya'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.productId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;
  double get _changeAmount => _isAdding ? _amount : -_amount;

  bool get _noteRequired =>
      _reason == 'ADJUSTMENT' || _reasonLabel != 'Restock / Stok Masuk';

  String? _validate() {
    if (_selectedProductId == null) return 'Pilih produk terlebih dahulu';
    if (_amount <= 0) return 'Jumlah harus lebih dari 0';
    if (_noteRequired && _noteController.text.trim().isEmpty) {
      return 'Catatan wajib diisi untuk alasan ini';
    }
    return null;
  }

  Future<void> _submit(StockEntity currentStock) async {
    final error = _validate();
    if (error != null) {
      ErrorSnackbar.showError(context, error);
      return;
    }

    final notifier = ref.read(stockAdjustmentNotifierProvider.notifier);
    notifier.reset();

    final ok = await notifier.adjust(
      productId: _selectedProductId!,
      changeAmount: _changeAmount,
      reason: _reason,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stok berhasil diperbarui: ${_formatStock(currentStock.currentStock)} → ${_formatStock(currentStock.currentStock + _changeAmount)} ${currentStock.productUnit}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final errMsg = ref.read(stockAdjustmentNotifierProvider.notifier).errorMessage;
      ErrorSnackbar.showError(context, errMsg ?? 'Gagal menyesuaikan stok');
    }
  }

  String _formatStock(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Adjustment Stok'),
      ),
      body: _selectedProductId == null
          ? _ProductPickerBody(
              onSelected: (stock) {
                setState(() {
                  _selectedProductId = stock.productId;
                });
              },
            )
          : _buildAdjustmentForm(theme),
    );
  }

  Widget _buildAdjustmentForm(ThemeData theme) {
    final stockAsync = ref.watch(stockByProductProvider(_selectedProductId!));
    final notifierState = ref.watch(stockAdjustmentNotifierProvider);

    return stockAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (stock) {
        final preview = stock.currentStock + _changeAmount;
        final isNegativePreview = preview < 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Product info card ───────────────────────────────────────
              _ProductInfoCard(stock: stock),
              const SizedBox(height: AppSpacing.lg),

              // ── Mode: Tambah / Kurang ───────────────────────────────────
              Text(
                'Mode Adjustment',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: '+ Tambah',
                      icon: Icons.add_circle_outline_rounded,
                      isActive: _isAdding,
                      activeColor: AppColors.success,
                      onTap: () {
                        setState(() {
                          _isAdding = true;
                          if (_reasonLabel == 'Barang Rusak' ||
                              _reasonLabel == 'Barang Hilang') {
                            _reasonLabel = 'Restock / Stok Masuk';
                            _reason = 'RESTOCK';
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ModeButton(
                      label: '− Kurang',
                      icon: Icons.remove_circle_outline_rounded,
                      isActive: !_isAdding,
                      activeColor: AppColors.danger,
                      onTap: () {
                        setState(() {
                          _isAdding = false;
                          if (_reasonLabel == 'Restock / Stok Masuk') {
                            _reasonLabel = 'Koreksi / Selisih Stok';
                            _reason = 'ADJUSTMENT';
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Jumlah ─────────────────────────────────────────────────
              Text('Jumlah', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: stock.productUnit,
                  prefixIcon: Icon(
                    _isAdding
                        ? Icons.add_circle_outline_rounded
                        : Icons.remove_circle_outline_rounded,
                    color: _isAdding ? AppColors.success : AppColors.danger,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Alasan ─────────────────────────────────────────────────
              Text('Alasan', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _reasonLabel,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _reasonItems
                    .where((item) {
                      if (_isAdding) {
                        return item.$2 == 'Restock / Stok Masuk' ||
                            item.$2 == 'Koreksi / Selisih Stok' ||
                            item.$2 == 'Lainnya';
                      } else {
                        return item.$2 == 'Koreksi / Selisih Stok' ||
                            item.$2 == 'Barang Rusak' ||
                            item.$2 == 'Barang Hilang' ||
                            item.$2 == 'Lainnya';
                      }
                    })
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.$2,
                        child: Text(item.$2),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  final match = _reasonItems.firstWhere((e) => e.$2 == val);
                  setState(() {
                    _reasonLabel = val;
                    _reason = match.$1;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Catatan ────────────────────────────────────────────────
              Row(
                children: [
                  Text('Catatan', style: theme.textTheme.titleSmall),
                  if (_noteRequired) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(wajib)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _noteController,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Preview stok setelah ────────────────────────────────────
              if (_amount > 0)
                _StockPreviewCard(
                  current: stock.currentStock,
                  changeAmount: _changeAmount,
                  preview: preview,
                  unit: stock.productUnit,
                  isNegative: isNegativePreview,
                ),
              if (_amount > 0) const SizedBox(height: AppSpacing.lg),

              // ── Submit button ───────────────────────────────────────────
              AppButton(
                label: 'Simpan Adjustment',
                isLoading: notifierState.isLoading,
                onPressed: () => _submit(stock),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({required this.stock});
  final StockEntity stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.productName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'SKU: ${stock.productSku}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Stok saat ini',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '${stock.currentStock == stock.currentStock.roundToDouble() ? stock.currentStock.toInt() : stock.currentStock.toStringAsFixed(2)} ${stock.productUnit}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withOpacity(0.12)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isActive ? activeColor : AppColors.outlineVariant,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? activeColor : AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isActive ? activeColor : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }
}

class _StockPreviewCard extends StatelessWidget {
  const _StockPreviewCard({
    required this.current,
    required this.changeAmount,
    required this.preview,
    required this.unit,
    required this.isNegative,
  });

  final double current;
  final double changeAmount;
  final double preview;
  final String unit;
  final bool isNegative;

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isNegative
            ? AppColors.dangerLight
            : AppColors.successLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isNegative ? AppColors.danger : AppColors.success,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PreviewItem(
            label: 'Sebelum',
            value: '${_fmt(current)} $unit',
            color: AppColors.onSurface,
            theme: theme,
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.onSurfaceVariant,
          ),
          _PreviewItem(
            label: 'Perubahan',
            value: '${changeAmount >= 0 ? '+' : ''}${_fmt(changeAmount)} $unit',
            color: changeAmount >= 0 ? AppColors.success : AppColors.danger,
            theme: theme,
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.onSurfaceVariant,
          ),
          _PreviewItem(
            label: 'Sesudah',
            value: '${_fmt(preview)} $unit',
            color: isNegative ? AppColors.danger : AppColors.success,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  const _PreviewItem({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── Product picker body (ketika productId belum dipilih) ─────────────────────

class _ProductPickerBody extends ConsumerStatefulWidget {
  const _ProductPickerBody({required this.onSelected});
  final ValueChanged<StockEntity> onSelected;

  @override
  ConsumerState<_ProductPickerBody> createState() => _ProductPickerBodyState();
}

class _ProductPickerBodyState extends ConsumerState<_ProductPickerBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stocksAsync = ref.watch(stockListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Produk',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Cari nama atau SKU...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: stocksAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (stocks) {
              final filtered = _query.isEmpty
                  ? stocks
                  : stocks
                      .where(
                        (s) =>
                            s.productName
                                .toLowerCase()
                                .contains(_query) ||
                            s.productSku.toLowerCase().contains(_query),
                      )
                      .toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('Produk tidak ditemukan'));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (_, i) {
                  final s = filtered[i];
                  return ListTile(
                    title: Text(s.productName),
                    subtitle: Text('SKU: ${s.productSku}'),
                    trailing: Text(
                      '${s.currentStock == s.currentStock.roundToDouble() ? s.currentStock.toInt() : s.currentStock.toStringAsFixed(2)} ${s.productUnit}',
                      style: TextStyle(
                        color: s.isLowStock
                            ? AppColors.danger
                            : AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => widget.onSelected(s),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
