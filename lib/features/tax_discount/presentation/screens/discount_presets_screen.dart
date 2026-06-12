// lib/features/tax_discount/presentation/screens/discount_presets_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../domain/entities/discount_preset_entity.dart';
import '../providers/discount_provider.dart';

class DiscountPresetsScreen extends ConsumerWidget {
  const DiscountPresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final discountListAsync = ref.watch(discountListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: discountListAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('Gagal memuat preset diskon: $err'),
        ),
        data: (discountList) {
          if (discountList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.percent_rounded,
                    size: 64,
                    color: AppColors.outlineVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Belum ada preset diskon',
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
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            itemCount: discountList.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final discount = discountList[index];
              final isPercentage = discount.type == DiscountType.percentage;
              final displayValue = isPercentage
                  ? '${discount.value}%'
                  : discount.value.formatRupiah();

              return Dismissible(
                key: Key(discount.id),
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
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus Preset Diskon?'),
                      content: Text(
                        'Apakah Anda yakin ingin menghapus preset "${discount.name}"?',
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
                      .read(discountNotifierProvider.notifier)
                      .delete(discount.id);
                  return success;
                },
                child: Card(
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    onTap: () => _showDiscountBottomSheet(context, ref, discount),
                    leading: CircleAvatar(
                      backgroundColor: isPercentage
                          ? AppColors.primaryContainer
                          : AppColors.secondaryContainer,
                      child: Icon(
                        isPercentage ? Icons.percent_rounded : Icons.money_rounded,
                        color: isPercentage ? AppColors.primary : AppColors.secondary,
                      ),
                    ),
                    title: Text(
                      discount.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Nilai Diskon: $displayValue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: discount.isActive,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) async {
                            final success = await ref
                                .read(discountNotifierProvider.notifier)
                                .toggleActive(id: discount.id, isActive: val);
                            if (!success && context.mounted) {
                              final errorMsg = ref.read(discountNotifierProvider).error?.toString() ?? 'Gagal mengubah status diskon';
                              ErrorSnackbar.showError(context, errorMsg);
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Preset Diskon',
        onPressed: () => _showDiscountBottomSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDiscountBottomSheet(BuildContext context, WidgetRef ref, [DiscountPresetEntity? discount]) {
    final isEdit = discount != null;
    final nameController = TextEditingController(text: discount?.name);
    final valueController = TextEditingController(
      text: discount != null
          ? (discount.type == DiscountType.percentage
              ? discount.value.toString()
              : discount.value.toInt().toString())
          : '',
    );
    DiscountType selectedType = discount?.type ?? DiscountType.percentage;

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
            final isPercentage = selectedType == DiscountType.percentage;

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
                    isEdit ? 'Ubah Preset Diskon' : 'Tambah Preset Diskon',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Nama Diskon
                  Text('Nama Diskon / Promo', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Diskon Member 10%',
                      prefixIcon: Icon(Icons.discount_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Jenis Diskon (Segmented Button)
                  Text('Jenis Diskon', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<DiscountType>(
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: AppColors.primaryContainer,
                        selectedForegroundColor: AppColors.onPrimaryContainer,
                      ),
                      segments: const [
                        ButtonSegment<DiscountType>(
                          value: DiscountType.percentage,
                          label: Text('Persentase (%)'),
                          icon: Icon(Icons.percent_rounded),
                        ),
                        ButtonSegment<DiscountType>(
                          value: DiscountType.nominal,
                          label: Text('Nominal (Rp)'),
                          icon: Icon(Icons.money_rounded),
                        ),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          selectedType = newSelection.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Nilai Diskon
                  Text(
                    isPercentage ? 'Nilai Persentase (%)' : 'Nilai Nominal (Rupiah)',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      if (isPercentage)
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                      else
                        FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: isPercentage
                          ? 'Masukkan angka (0 - 100)'
                          : 'Masukkan nominal rupiah (misal: 10000)',
                      prefixIcon: Icon(
                        isPercentage ? Icons.percent_rounded : Icons.payments_outlined,
                      ),
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
                            final valueStr = valueController.text;
                            final value = double.tryParse(valueStr) ?? -1.0;

                            if (name.trim().isEmpty) {
                              ErrorSnackbar.showError(ctx, 'Nama diskon tidak boleh kosong');
                              return;
                            }
                            if (value < 0) {
                              ErrorSnackbar.showError(ctx, 'Nilai diskon tidak boleh negatif');
                              return;
                            }
                            if (selectedType == DiscountType.percentage && value > 100) {
                              ErrorSnackbar.showError(ctx, 'Persentase diskon tidak boleh melebihi 100%');
                              return;
                            }

                            bool success;
                            if (isEdit) {
                              success = await ref.read(discountNotifierProvider.notifier).update(
                                    id: discount.id,
                                    name: name,
                                    type: selectedType,
                                    value: value,
                                    isActive: discount.isActive,
                                    createdAt: discount.createdAt,
                                  );
                            } else {
                              success = await ref.read(discountNotifierProvider.notifier).create(
                                    name: name,
                                    type: selectedType,
                                    value: value,
                                  );
                            }

                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEdit
                                        ? 'Preset diskon berhasil diperbarui'
                                        : 'Preset diskon baru berhasil ditambahkan',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else if (ctx.mounted) {
                              final errorMsg = ref.read(discountNotifierProvider).error?.toString() ?? 'Gagal menyimpan diskon';
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
