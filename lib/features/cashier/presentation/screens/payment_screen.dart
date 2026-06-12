import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/currency_display.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../tax_discount/presentation/providers/tax_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/cart_provider.dart';
import '../providers/transaction_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  String _cashInput = ''; // Input nominal uang diterima (dalam string)
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Generate dynamic cash suggestions based on total
  List<double> _getCashSuggestions(double total) {
    final List<double> suggestions = [];
    suggestions.add(total); // Uang pas

    // round up to next 10k, 20k, 50k, 100k
    final List<double> denoms = [10000, 20000, 50000, 100000];
    for (final denom in denoms) {
      final val = ((total / denom).ceil() * denom).toDouble();
      if (val > total && !suggestions.contains(val)) {
        suggestions.add(val);
      }
    }

    // Jika total kecil, pastikan denominasi standard Rp 20.000 / Rp 50.000 / Rp 100.000 masuk jika lebih besar dari total
    final List<double> standardDenoms = [20000, 50000, 100000];
    for (final denom in standardDenoms) {
      if (denom > total && !suggestions.contains(denom)) {
        suggestions.add(denom);
      }
    }

    suggestions.sort();
    return suggestions.take(4).toList(); // Ambil max 4 saran
  }

  void _onKeyPress(String val) {
    setState(() {
      _cashInput += val;
    });
  }

  void _onBackspace() {
    if (_cashInput.isEmpty) return;
    setState(() {
      _cashInput = _cashInput.substring(0, _cashInput.length - 1);
    });
  }

  void _onClear() {
    setState(() {
      _cashInput = '';
    });
  }

  Future<void> _processPayment(double grandTotal) async {
    final cartState = ref.read(cartNotifierProvider);
    final activeTax = ref.read(activeTaxProvider).valueOrNull;

    double? paymentReceived;
    double? changeAmount;

    if (_selectedMethod == PaymentMethod.cash) {
      paymentReceived = double.tryParse(_cashInput) ?? 0.0;
      if (paymentReceived < grandTotal) {
        ErrorSnackbar.showError(context, 'Uang yang diterima kurang dari total pembayaran');
        return;
      }
      changeAmount = paymentReceived - grandTotal;
    }

    final notifier = ref.read(checkoutNotifierProvider.notifier);
    final txn = await notifier.executeCheckout(
      cartItems: cartState.items,
      subtotal: cartState.summary.subtotal,
      discountType: cartState.txnDiscountType,
      discountValue: cartState.txnDiscountValue,
      discountAmount: cartState.summary.txnDiscountAmount,
      taxRate: activeTax?.rate ?? 0.0,
      taxIsInclusive: activeTax?.isInclusive ?? false,
      taxAmount: cartState.summary.taxAmount,
      total: grandTotal,
      paymentMethod: _selectedMethod,
      paymentReceived: paymentReceived,
      changeAmount: changeAmount,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );

    if (txn != null && mounted) {
      // Navigasi ke Receipt screen
      context.go(AppRoutes.receipt.replaceAll(':transactionId', txn.id));
    } else if (mounted) {
      // Tampilkan error
      final checkoutState = ref.read(checkoutNotifierProvider);
      final errorMsg = checkoutState.maybeWhen(
        error: (failure, _) => failure.toString(),
        orElse: () => 'Terjadi kesalahan sistem saat checkout',
      );
      ErrorSnackbar.showError(context, errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final theme = Theme.of(context);

    final grandTotal = cartState.summary.grandTotal;
    final parsedCashInput = double.tryParse(_cashInput) ?? 0.0;
    final changeAmount = parsedCashInput >= grandTotal ? parsedCashInput - grandTotal : 0.0;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Pembayaran'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grand Total Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Text(
                      'TOTAL PEMBAYARAN',
                      style: TextStyle(
                        color: AppColors.outline,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    CurrencyDisplay(
                      amount: grandTotal,
                      style: CurrencyDisplayStyle.large,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Content area
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Payment Method Selection
                        Text(
                          'Metode Pembayaran',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: PaymentMethod.values.map((method) {
                            final isSelected = _selectedMethod == method;
                            IconData icon;
                            String label;

                            switch (method) {
                              case PaymentMethod.cash:
                                icon = Icons.payments_rounded;
                                label = 'CASH';
                                break;
                              case PaymentMethod.transfer:
                                icon = Icons.account_balance_rounded;
                                label = 'TRANSFER';
                                break;
                              case PaymentMethod.qris:
                                icon = Icons.qr_code_2_rounded;
                                label = 'QRIS';
                                break;
                              case PaymentMethod.debit:
                                icon = Icons.credit_card_rounded;
                                label = 'DEBIT';
                                break;
                              case PaymentMethod.credit:
                                icon = Icons.credit_card_off_rounded;
                                label = 'KREDIT';
                                break;
                            }

                            return SizedBox(
                              width: (MediaQuery.of(context).size.width - AppSpacing.lg * 2 - AppSpacing.md) / 2,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isSelected ? AppColors.primaryContainer : Colors.white,
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  foregroundColor: isSelected ? AppColors.primary : AppColors.onSurface,
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                ),
                                icon: Icon(icon),
                                label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  setState(() {
                                    _selectedMethod = method;
                                    if (method != PaymentMethod.cash) {
                                      _cashInput = ''; // clear cash input
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Cash Payment details (Virtual Numpad)
                        if (_selectedMethod == PaymentMethod.cash) ...[
                          _buildCashSection(grandTotal, changeAmount),
                        ],

                        // Note / Catatan Transaksi
                        TextField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'Catatan Transaksi (Opsional)',
                            hintText: 'Misal: Meja 5, bungkus, dll.',
                            prefixIcon: Icon(Icons.note_alt_outlined),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Process Payment Button (Docked at the bottom)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    onPressed: (checkoutState is AsyncLoading)
                        ? null
                        : () => _processPayment(grandTotal),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _selectedMethod == PaymentMethod.cash ? 'BAYAR & SELESAI' : 'PROSES TRANSAKSI',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Global Loading overlay during checkout
        if (checkoutState is AsyncLoading)
          const LoadingOverlay(message: 'Memproses transaksi...'),
      ],
    );
  }

  Widget _buildCashSection(double grandTotal, double changeAmount) {
    final suggestions = _getCashSuggestions(grandTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cash Input Display & Kembalian
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Diterima', style: TextStyle(color: AppColors.outline, fontWeight: FontWeight.bold)),
                    Text(
                      _cashInput.isEmpty ? 'Rp 0' : (double.tryParse(_cashInput) ?? 0.0).formatRupiah(),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kembalian', style: TextStyle(color: AppColors.outline)),
                    Text(
                      changeAmount.formatRupiah(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: changeAmount > 0 ? AppColors.success : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Quick Cash Suggestions
        const Text('Uang Pas / Cepat:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: suggestions.map((val) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                  ),
                  onPressed: () {
                    setState(() {
                      _cashInput = val.truncate().toString();
                    });
                  },
                  child: Text(
                    val == grandTotal ? 'Uang Pas' : val.formatRupiahCompact(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Virtual Numpad 4x3
        SizedBox(
          height: 280,
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1.8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 1; i <= 9; i++)
                _NumpadButton(
                  label: '$i',
                  onPressed: () => _onKeyPress('$i'),
                ),
              TextButton(
                onPressed: _onClear,
                child: const Text('C', style: TextStyle(fontSize: 20, color: AppColors.danger, fontWeight: FontWeight.bold)),
              ),
              _NumpadButton(
                label: '0',
                onPressed: () => _onKeyPress('0'),
              ),
              // Backspace
              IconButton(
                icon: const Icon(Icons.backspace_outlined),
                onPressed: _onBackspace,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
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
