// lib/features/stock/presentation/screens/stock_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/stock_entity.dart';
import '../../domain/entities/stock_ledger_entity.dart';
import '../providers/stock_provider.dart';

class StockHistoryScreen extends ConsumerStatefulWidget {
  const StockHistoryScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends ConsumerState<StockHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stockAsync = ref.watch(stockByProductProvider(widget.productId));
    final ledgerAsync = ref.watch(stockLedgerProvider(widget.productId));
    final settingsNotifier = ref.watch(stockSettingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: stockAsync.maybeWhen(
          data: (s) => Text(s.productName, overflow: TextOverflow.ellipsis),
          orElse: () => const Text('Riwayat Stok'),
        ),
        actions: [
          IconButton(
            tooltip: 'Adjustment Stok',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              final stock = stockAsync.valueOrNull;
              context.push(
                AppRoutes.stockAdjustment,
                extra: {
                  'productId': widget.productId,
                  'productName': stock?.productName,
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stock summary header ─────────────────────────────────────────
          stockAsync.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => Container(
              color: AppColors.errorContainer,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Error loading stock: $e', style: const TextStyle(color: AppColors.error)),
            ),
            data: (stock) => _StockHeaderCard(
              stock: stock,
              onEditSettings: () async {
                await _showEditSettingsDialog(
                  context,
                  stock.minimumStock,
                  stock.trackStock,
                  (minStock, track) async {
                    final ok = await settingsNotifier.updateSettings(
                      productId: widget.productId,
                      minimumStock: minStock,
                      trackStock: track,
                    );
                    if (ok && context.mounted) {
                      ref.invalidate(stockByProductProvider(widget.productId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Setting stok berhasil disimpan'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: Text(
              'Riwayat Mutasi (100 terbaru)',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Ledger list ──────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(stockLedgerProvider(widget.productId));
                ref.invalidate(stockByProductProvider(widget.productId));
              },
              child: ledgerAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (entries) {
                  if (entries.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.only(top: 80),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        EmptyState(
                          icon: Icons.history_rounded,
                          title: 'Belum ada mutasi',
                          subtitle: 'Riwayat pergerakan stok akan tampil di sini',
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (_, i) => _LedgerEntry(entry: entries[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSettingsDialog(
    BuildContext context,
    double currentMin,
    bool currentTrack,
    Future<void> Function(double, bool) onSave,
  ) async {
    final minController = TextEditingController(
      text: currentMin == currentMin.roundToDouble()
          ? currentMin.toInt().toString()
          : currentMin.toStringAsFixed(2),
    );
    bool isTrackStock = currentTrack;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Setting Stok'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stok minimum
              TextField(
                controller: minController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Stok Minimum',
                  helperText: 'Peringatan muncul jika stok ≤ nilai ini',
                  prefixIcon: Icon(Icons.warning_amber_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Toggle track stock
              InkWell(
                onTap: () => setSt(() => isTrackStock = !isTrackStock),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                    horizontal: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pantau Stok'),
                            Text(
                              'Aktifkan untuk tracking stok rendah',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isTrackStock,
                        onChanged: (v) => setSt(() => isTrackStock = v),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final min = double.tryParse(minController.text) ?? 0;
                Navigator.pop(ctx);
                await onSave(min, isTrackStock);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stock header card ─────────────────────────────────────────────────────────

class _StockHeaderCard extends StatelessWidget {
  const _StockHeaderCard({required this.stock, required this.onEditSettings});

  final StockEntity stock;
  final VoidCallback onEditSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = stock;
    final isLow = s.isLowStock;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLow
              ? [
                  AppColors.dangerLight,
                  AppColors.dangerLight.withValues(alpha: 0.6),
                ]
              : [
                  AppColors.primaryContainer,
                  AppColors.primaryContainer.withValues(alpha: 0.6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isLow
              ? AppColors.danger.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SKU: ${s.productSku}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          s.currentStock == s.currentStock.roundToDouble()
                              ? s.currentStock.toInt().toString()
                              : s.currentStock.toStringAsFixed(2),
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: isLow ? AppColors.danger : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            s.productUnit,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isLow)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.stockLowBg,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          '⚠️ STOK RENDAH',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.stockLow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Track stock toggle
                  Row(
                    children: [
                      Text(
                        'Pantau',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        s.trackStock
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 14,
                        color: s.trackStock
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Min: ${s.minimumStock == s.minimumStock.roundToDouble() ? s.minimumStock.toInt() : s.minimumStock.toStringAsFixed(2)} ${s.productUnit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Edit settings button
                  OutlinedButton.icon(
                    onPressed: onEditSettings,
                    icon: const Icon(Icons.settings_outlined, size: 14),
                    label: const Text('Setting'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      textStyle: const TextStyle(fontSize: 12),
                      side: BorderSide(
                        color: isLow ? AppColors.danger : AppColors.primary,
                      ),
                      foregroundColor:
                          isLow ? AppColors.danger : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Ledger entry card ─────────────────────────────────────────────────────────

class _LedgerEntry extends StatelessWidget {
  const _LedgerEntry({required this.entry});
  final StockLedgerEntity entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIn = entry.isIncoming;
    final entryColor = isIn ? AppColors.success : AppColors.danger;
    final entryBgColor = isIn ? AppColors.successLight : AppColors.dangerLight;
    final reasonInfo = _reasonInfo(entry.reason);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: entryBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIn ? Icons.add_rounded : Icons.remove_rounded,
              color: entryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Reason badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: reasonInfo.$2.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        reasonInfo.$1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: reasonInfo.$2,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Tanggal
                    Text(
                      _formatDate(entry.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Stok setelah + jumlah perubahan
                Row(
                  children: [
                    Text(
                      '${isIn ? '+' : ''}${_fmtStock(entry.changeAmount)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: entryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '  →  stok: ${_fmtStock(entry.stockAfter)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                // Note
                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Staff
                if (entry.staffName != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        entry.staffName!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _reasonInfo(String reason) {
    return switch (reason) {
      'SALE' => ('PENJUALAN', AppColors.primary),
      'RESTOCK' => ('RESTOCK', AppColors.success),
      'ADJUSTMENT' => ('KOREKSI', AppColors.warning),
      'VOID' => ('VOID', AppColors.danger),
      _ => (reason, AppColors.onSurfaceVariant),
    };
  }

  String _fmtStock(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
