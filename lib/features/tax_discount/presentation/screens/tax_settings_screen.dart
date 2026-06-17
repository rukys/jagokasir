// lib/features/tax_discount/presentation/screens/tax_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../domain/entities/tax_config_entity.dart';
import '../providers/tax_provider.dart';

class TaxSettingsScreen extends ConsumerWidget {
  const TaxSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final taxListAsync = ref.watch(taxListProvider);
    final activeTaxAsync = ref.watch(activeTaxProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Active Tax Banner ──────────────────────────────────────────────
          activeTaxAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (activeTax) {
              final hasActive = activeTax != null;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(AppSpacing.pagePadding),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: hasActive ? AppColors.successLight : AppColors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: hasActive ? AppColors.success : AppColors.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasActive ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      color: hasActive ? AppColors.success : AppColors.outline,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasActive ? 'Pajak Aktif Saat Ini' : 'Tidak Ada Pajak Aktif',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: hasActive ? AppColors.success : AppColors.onSurfaceVariant,
                            ),
                          ),
                          if (hasActive) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${activeTax.name} (${activeTax.rate}%) — ${activeTax.isInclusive ? 'Harga Termasuk Pajak (Inclusive)' : 'Pajak Ditambahkan (Exclusive)'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Tax Configurations List ────────────────────────────────────────
          Expanded(
            child: taxListAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Text('Gagal memuat konfigurasi pajak: $err'),
              ),
              data: (taxList) {
                if (taxList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: AppColors.outlineVariant,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Belum ada konfigurasi pajak',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Tap tombol + di bawah untuk membuat baru',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                  ),
                  itemCount: taxList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final tax = taxList[index];

                    return Dismissible(
                      key: Key(tax.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (tax.isActive) {
                          ErrorSnackbar.showError(
                            context,
                            'Nonaktifkan pajak terlebih dahulu sebelum menghapus',
                          );
                          return false;
                        }

                        // Konfirmasi hapus
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Hapus Pajak?'),
                            content: Text(
                              'Apakah Anda yakin ingin menghapus konfigurasi "${tax.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Batal'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.danger,
                                ),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return false;

                        final success = await ref
                            .read(taxNotifierProvider.notifier)
                            .delete(tax.id);
                        return success;
                      },
                      child: Card(
                        elevation: 0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          onTap: () => _showTaxBottomSheet(context, ref, tax),
                          leading: Radio<bool>(
                            value: true,
                            groupValue: tax.isActive ? true : null,
                            activeColor: AppColors.primary,
                            onChanged: (_) async {
                              if (!tax.isActive) {
                                await ref
                                    .read(taxNotifierProvider.notifier)
                                    .setActive(tax.id);
                              }
                            },
                          ),
                          title: Row(
                            children: [
                              Text(
                                tax.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tax.isInclusive
                                      ? AppColors.infoLight
                                      : AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                ),
                                child: Text(
                                  tax.isInclusive ? 'INCLUSIVE' : 'EXCLUSIVE',
                                  style: TextStyle(
                                    color: tax.isInclusive
                                        ? AppColors.info
                                        : AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Persentase Pajak: ${tax.rate}%',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Pajak Baru',
        onPressed: () => _showTaxBottomSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTaxBottomSheet(BuildContext context, WidgetRef ref, [TaxConfigEntity? tax]) {
    final isEdit = tax != null;
    final nameController = TextEditingController(text: tax?.name);
    final rateController = TextEditingController(text: tax != null ? tax.rate.toString() : '');
    bool isInclusive = tax?.isInclusive ?? false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);

        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xl,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Ubah Pajak' : 'Tambah Pajak Baru',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Nama Pajak
                  Text('Nama Pajak', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: PPN 11%',
                      prefixIcon: Icon(Icons.receipt_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Persentase
                  Text('Tarif Pajak (%)', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Masukkan angka (0 - 100)',
                      prefixIcon: Icon(Icons.percent_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Inclusive vs Exclusive Toggle
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pajak Inklusif (Inclusive)',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isInclusive
                                        ? 'Harga produk sudah termasuk pajak.'
                                        : 'Harga produk belum termasuk pajak.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isInclusive,
                              onChanged: (val) {
                                setState(() {
                                  isInclusive = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(height: AppSpacing.lg),
                        Text(
                          isInclusive
                              ? 'ℹ️ PPN Inclusive (Inklusif): Harga jual produk tetap. Nilai pajak dikalkulasikan mundur dari harga jual (misal Rp 10.000 sudah include PPN).'
                              : 'ℹ️ PPN Exclusive (Eksklusif): Harga jual produk akan ditambahkan pajak di kasir (misal Rp 10.000 + PPN 11% = Rp 11.100).',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Aksi Tombol
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          label: 'Simpan',
                          onPressed: () async {
                            final name = nameController.text;
                            final rateStr = rateController.text;
                            final rate = double.tryParse(rateStr) ?? -1.0;

                            if (name.trim().isEmpty) {
                              ErrorSnackbar.showError(ctx, 'Nama pajak tidak boleh kosong');
                              return;
                            }
                            if (rate < 0.0 || rate > 100.0) {
                              ErrorSnackbar.showError(ctx, 'Tarif pajak harus antara 0.0% dan 100.0%');
                              return;
                            }

                            bool success;
                            if (isEdit) {
                              success = await ref.read(taxNotifierProvider.notifier).update(
                                    id: tax.id,
                                    name: name,
                                    rate: rate,
                                    isInclusive: isInclusive,
                                    isActive: tax.isActive,
                                    createdAt: tax.createdAt,
                                  );
                            } else {
                              success = await ref.read(taxNotifierProvider.notifier).create(
                                    name: name,
                                    rate: rate,
                                    isInclusive: isInclusive,
                                  );
                            }

                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEdit
                                        ? 'Pajak berhasil diperbarui'
                                        : 'Pajak baru berhasil ditambahkan',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else if (ctx.mounted) {
                              final errorMsg = ref.read(taxNotifierProvider).error?.toString() ?? 'Gagal menyimpan pajak';
                              ErrorSnackbar.showError(ctx, errorMsg);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
