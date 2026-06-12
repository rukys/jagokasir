import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../shared/widgets/currency_display.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_provider.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends ConsumerState<TransactionDetailScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _showVoidDialog(BuildContext context, String txnId) {
    _reasonController.clear();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Batalkan Transaksi (Void)?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Transaksi akan dibatalkan, dan stok barang akan dikembalikan ke database. Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Pembatalan (Wajib)',
                  hintText: 'Misal: Salah input barang, batal beli, dll.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () async {
                final reason = _reasonController.text.trim();
                if (reason.isEmpty) {
                  ErrorSnackbar.showError(context, 'Alasan pembatalan wajib diisi');
                  return;
                }

                Navigator.pop(context); // Close dialog

                final success = await ref
                    .read(voidNotifierProvider.notifier)
                    .executeVoid(transactionId: txnId, reason: reason);

                if (success && context.mounted) {
                  // Invalidate detail provider so it updates
                  ref.invalidate(transactionDetailProvider(txnId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaksi berhasil dibatalkan (void)')),
                  );
                } else if (context.mounted) {
                  final voidState = ref.read(voidNotifierProvider);
                  final errorMsg = voidState.maybeWhen(
                    error: (failure, _) => failure.toString(),
                    orElse: () => 'Gagal membatalkan transaksi',
                  );
                  ErrorSnackbar.showError(context, errorMsg);
                }
              },
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final txnAsync = ref.watch(transactionDetailProvider(widget.transactionId));
    final voidState = ref.watch(voidNotifierProvider);
    final currentStaff = ref.watch(currentStaffProvider);
    final theme = Theme.of(context);

    final isOwnerOrAdmin =
        currentStaff?.role == StaffRole.owner || currentStaff?.role == StaffRole.admin;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Rincian Transaksi'),
          ),
          body: txnAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => Center(
              child: Text('Gagal memuat detail transaksi: $e', style: const TextStyle(color: AppColors.danger)),
            ),
            data: (txn) {
              final isCompleted = txn.status == TransactionStatus.completed;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Status Info Card
                          Card(
                            color: isCompleted ? AppColors.successLight.withOpacity(0.3) : AppColors.dangerLight.withOpacity(0.3),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        txn.invoiceNumber,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs / 2),
                                        decoration: BoxDecoration(
                                          color: isCompleted ? AppColors.successLight : AppColors.dangerLight,
                                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                        ),
                                        child: Text(
                                          isCompleted ? 'COMPLETED' : 'VOIDED',
                                          style: TextStyle(
                                            color: isCompleted ? AppColors.success : AppColors.danger,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildDetailRow(
                                    'Tanggal',
                                    '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year} ${txn.createdAt.hour.toString().padLeft(2, '0')}:${txn.createdAt.minute.toString().padLeft(2, '0')}',
                                  ),
                                  _buildDetailRow('Kasir', txn.staffName ?? 'Staff'),
                                  if (!isCompleted && txn.voidReason != null) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    const Divider(),
                                    const SizedBox(height: AppSpacing.xs),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.info_outline_rounded, color: AppColors.danger, size: 16),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Alasan Void:',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.danger),
                                              ),
                                              Text(
                                                txn.voidReason!,
                                                style: const TextStyle(fontSize: 12, color: AppColors.danger),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Item Lists
                          Text(
                            'Item Belanja',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Card(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: txn.items.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final item = txn.items[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.productName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                          Text(
                                            item.lineTotal.formatRupiah(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: AppSpacing.xs / 2),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${item.quantity.toStringAsFixed(0)} x ${item.sellingPrice.formatRupiah()}',
                                            style: const TextStyle(color: AppColors.outline, fontSize: 11),
                                          ),
                                          if (item.itemDiscountAmount > 0)
                                            Text(
                                              'Diskon: -${item.itemDiscountAmount.formatRupiah()}',
                                              style: const TextStyle(color: AppColors.warning, fontSize: 11),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Calculation Summary Card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                children: [
                                  _buildSummaryRow('Subtotal', txn.subtotal.formatRupiah()),
                                  if (txn.discountAmount > 0)
                                    _buildSummaryRow(
                                      'Diskon Transaksi',
                                      '- ${txn.discountAmount.formatRupiah()}',
                                      valueColor: AppColors.warning,
                                    ),
                                  if (txn.taxAmount > 0)
                                    _buildSummaryRow(
                                      'Pajak (${txn.taxIsInclusive ? 'Inclusive' : 'Exclusive'})',
                                      txn.taxAmount.formatRupiah(),
                                    ),
                                  const Divider(),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total Akhir', style: TextStyle(fontWeight: FontWeight.bold)),
                                      CurrencyDisplay(
                                        amount: txn.total,
                                        style: CurrencyDisplayStyle.normal,
                                        color: isCompleted ? AppColors.primary : AppColors.outline,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Payment Info Card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                children: [
                                  _buildSummaryRow('Metode Pembayaran', txn.paymentMethod.name.toUpperCase()),
                                  if (txn.paymentMethod == PaymentMethod.cash) ...[
                                    _buildSummaryRow('Uang Diterima', txn.paymentReceived?.formatRupiah() ?? 'Rp 0'),
                                    _buildSummaryRow('Kembalian', txn.changeAmount?.formatRupiah() ?? 'Rp 0', valueColor: AppColors.success),
                                  ],
                                  if (txn.note != null) ...[
                                    const Divider(),
                                    _buildSummaryRow('Catatan', txn.note!),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions panel (Void button)
                  if (isCompleted && isOwnerOrAdmin)
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                          ),
                          icon: const Icon(Icons.cancel_rounded),
                          label: const Text('BATALKAN TRANSAKSI (VOID)', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () => _showVoidDialog(context, txn.id),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (voidState is AsyncLoading)
          const LoadingOverlay(message: 'Membatalkan transaksi...'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
          Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
