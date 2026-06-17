import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../printer/presentation/providers/printer_provider.dart';
import '../../../printer/presentation/providers/store_config_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/cart_provider.dart';
import '../providers/transaction_provider.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool _isAutoPrinted = false;

  void _showNoDefaultPrinterDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Printer Belum Diketahui'),
        content: const Text(
          'Belum ada printer default yang dikonfigurasi. Apakah Anda ingin mengonfigurasinya sekarang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.printerConfig);
            },
            child: const Text('Konfigurasi Printer'),
          ),
        ],
      ),
    );
  }

  void _showPrintFailedDialog(BuildContext context, TransactionEntity transaction) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Printer Tidak Dapat Dihubungi'),
        content: const Text(
          'Gagal mengirim data ke printer. Pastikan printer menyala, memiliki kertas, dan terhubung.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lewati'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(printNotifierProvider.notifier).printReceipt(transaction);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Struk berhasil dicetak!')),
                );
              } else if (context.mounted) {
                _showPrintFailedDialog(context, transaction);
              }
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txnAsync = ref.watch(transactionDetailProvider(widget.transactionId));
    final printState = ref.watch(printNotifierProvider);
    final theme = Theme.of(context);

    // Auto-print integration via ref.listen
    ref.listen(transactionDetailProvider(widget.transactionId), (previous, next) async {
      next.whenData((txn) async {
        if (!_isAutoPrinted) {
          _isAutoPrinted = true;
          try {
            final config = await ref.read(storeConfigProvider.future);
            if (config.autoPrint) {
              final defaultPrn = await ref.read(defaultPrinterProvider.future);
              if (defaultPrn == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cetak otomatis dilewati: Tidak ada printer default')),
                  );
                }
                return;
              }
              await ref.read(printNotifierProvider.notifier).printReceipt(txn);
            }
          } catch (_) {
            // Siletly ignore auto print initialization errors
          }
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Struk Belanja'),
        automaticallyImplyLeading: false, // Menghilangkan back button bawaan agar terarah
      ),
      body: txnAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Gagal memuat struk: $e', style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
        data: (txn) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                // Success Badge
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 64,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Pembayaran Berhasil',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),

                // Receipt Paper Container
                Card(
                  elevation: AppSpacing.elevationSm,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
                    side: BorderSide(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Store Header Mock
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'TOKO SAYA',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs / 2),
                              const Text(
                                'JagoKasir Offline UMKM',
                                style: TextStyle(color: AppColors.outline, fontSize: 11),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                          ),
                        ),
                        const _DottedDivider(),
                        const SizedBox(height: AppSpacing.md),

                        // Metadata (Invoice, Date, Cashier)
                        _buildMetaRow('No. Invoice', txn.invoiceNumber),
                        _buildMetaRow(
                          'Tanggal',
                          '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year} ${txn.createdAt.hour.toString().padLeft(2, '0')}:${txn.createdAt.minute.toString().padLeft(2, '0')}',
                        ),
                        _buildMetaRow('Kasir', txn.staffName ?? 'Staff'),
                        const SizedBox(height: AppSpacing.md),
                        const _DottedDivider(),
                        const SizedBox(height: AppSpacing.md),

                        // Item List Header
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Items list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: txn.items.length,
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
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        item.lineTotal.formatRupiah(),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs / 2),
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
                        const SizedBox(height: AppSpacing.md),
                        const _DottedDivider(),
                        const SizedBox(height: AppSpacing.md),

                        // Totals summary
                        _buildTotalRow('Subtotal', txn.subtotal.formatRupiah()),
                        if (txn.discountAmount > 0)
                          _buildTotalRow(
                            'Diskon Transaksi',
                            '- ${txn.discountAmount.formatRupiah()}',
                            valueColor: AppColors.warning,
                          ),
                        if (txn.taxAmount > 0)
                          _buildTotalRow(
                            'Pajak (${txn.taxIsInclusive ? 'Inclusive' : 'Exclusive'})',
                            txn.taxAmount.formatRupiah(),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              txn.total.formatRupiah(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const _DottedDivider(),
                        const SizedBox(height: AppSpacing.md),

                        // Payment Details
                        _buildTotalRow('Metode Pembayaran', txn.paymentMethod.name.toUpperCase()),
                        if (txn.paymentMethod == PaymentMethod.cash) ...[
                          _buildTotalRow(
                            'Uang Diterima',
                            txn.paymentReceived?.formatRupiah() ?? 'Rp 0',
                          ),
                          _buildTotalRow(
                            'Kembalian',
                            txn.changeAmount?.formatRupiah() ?? 'Rp 0',
                            valueColor: AppColors.success,
                          ),
                        ],
                        if (txn.note != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          const Text('Catatan:', style: TextStyle(color: AppColors.outline, fontSize: 11)),
                          Text(txn.note!, style: const TextStyle(fontSize: 12)),
                        ],
                        const SizedBox(height: AppSpacing.xl),

                        // Footer Text
                        const Center(
                          child: Text(
                            'Terima Kasih Atas Kunjungan Anda\nSesi Pembelian Selesai',
                            style: TextStyle(color: AppColors.outline, fontSize: 10, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Cetak Struk Button
                if (printState is AsyncLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                    ),
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Cetak Struk Fisik'),
                    onPressed: () async {
                      final defaultPrn = await ref.read(defaultPrinterProvider.future);
                      if (defaultPrn == null) {
                        if (context.mounted) {
                          _showNoDefaultPrinterDialog(context);
                        }
                        return;
                      }

                      final success = await ref.read(printNotifierProvider.notifier).printReceipt(txn);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Struk berhasil dicetak!')),
                        );
                      } else if (context.mounted) {
                        _showPrintFailedDialog(context, txn);
                      }
                    },
                  ),
                    ],
                  ),
                ),
              ),
              // Transaksi Baru Button (Docked at the bottom)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                    ),
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text('Transaksi Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      // Reset keranjang belanja & navigasi kembali ke Beranda/Kasir
                      ref.read(cartNotifierProvider.notifier).clearCart();
                      context.go(AppRoutes.home);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 11)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        150,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : AppColors.outlineVariant,
            height: 1,
          ),
        ),
      ),
    );
  }
}
