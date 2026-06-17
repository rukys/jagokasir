import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/category_provider.dart';

class CategoryManagerScreen extends ConsumerWidget {
  const CategoryManagerScreen({super.key});

  // 8 preset warna kategori
  static const List<String> _presetColors = [
    '#4CAF50', // hijau
    '#2196F3', // biru
    '#FF9800', // oranye
    '#E91E63', // pink
    '#9C27B0', // ungu
    '#00BCD4', // cyan
    '#FF5722', // merah-oranye
    '#795548', // cokelat
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kategori')),
      body: categoriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyState(
              icon: Icons.category_outlined,
              title: 'Belum ada kategori',
              subtitle: 'Tap tombol + untuk menambah kategori',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) {
              final cat = categories[i];
              final isDefault = cat.id == 'cat-uncategorized';
              return _CategoryTile(
                category: cat,
                isDefault: isDefault,
                presetColors: _presetColors,
                onEdit: () => _showCategoryDialog(
                  context,
                  ref,
                  existing: cat,
                  presetColors: _presetColors,
                ),
                onDelete: () => _confirmDelete(context, ref, cat),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_add_category',
        onPressed: () => _showCategoryDialog(
          context,
          ref,
          presetColors: _presetColors,
        ),
        tooltip: 'Tambah Kategori',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  static Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    CategoryEntity? existing,
    required List<String> presetColors,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _CategoryDialog(
        existing: existing,
        presetColors: presetColors,
        ref: ref,
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity cat,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Hapus Kategori?',
      message:
          'Produk di kategori "${cat.name}" akan dipindah ke Uncategorized.',
      confirmText: 'Hapus',
      isDestructive: true,
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    LoadingOverlay.show(context);
    final success = await ref.read(categoryNotifierProvider.notifier).delete(cat.id);
    if (!context.mounted) return;
    LoadingOverlay.hide(context);

    if (success) {
      ErrorSnackbar.showSuccess(context, 'Kategori berhasil dihapus');
    } else {
      final msg = ref.read(categoryNotifierProvider.notifier).errorMessage;
      ErrorSnackbar.showError(context, msg ?? 'Gagal menghapus kategori');
    }
  }
}

// ── Category tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.isDefault,
    required this.presetColors,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryEntity category;
  final bool isDefault;
  final List<String> presetColors;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _parseColor(String? hex) {
    if (hex == null) return AppColors.surfaceVariant;
    try {
      return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return AppColors.surfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = _parseColor(category.colorHex);

    return Dismissible(
      key: ValueKey(category.id),
      direction:
          isDefault ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // biarkan dialog yang handle delete
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            // Color dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: chipColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(category.name, style: theme.textTheme.titleSmall),
            ),
            if (isDefault)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text(
                  'Default',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            if (!isDefault)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: AppSpacing.iconSizeMd),
                onPressed: onEdit,
                color: AppColors.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Category Dialog ───────────────────────────────────────────────────────────

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({
    required this.presetColors,
    required this.ref,
    this.existing,
  });

  final CategoryEntity? existing;
  final List<String> presetColors;
  final WidgetRef ref;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _nameCtrl;
  String? _selectedColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _selectedColor = widget.existing?.colorHex;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return AppColors.surfaceVariant;
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ErrorSnackbar.showError(context, 'Nama kategori tidak boleh kosong');
      return;
    }
    setState(() => _isLoading = true);

    bool success;
    if (widget.existing == null) {
      success = await widget.ref.read(categoryNotifierProvider.notifier).create(
        name: _nameCtrl.text.trim(),
        colorHex: _selectedColor,
      );
    } else {
      success = await widget.ref.read(categoryNotifierProvider.notifier).update(
        id: widget.existing!.id,
        name: _nameCtrl.text.trim(),
        colorHex: _selectedColor,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ErrorSnackbar.showSuccess(
        // ignore: use_build_context_synchronously
        context,
        widget.existing == null
            ? 'Kategori berhasil ditambahkan'
            : 'Kategori berhasil diperbarui',
      );
    } else {
      final msg = widget.ref.read(categoryNotifierProvider.notifier).errorMessage;
      // ignore: use_build_context_synchronously
      ErrorSnackbar.showError(context, msg ?? 'Gagal menyimpan kategori');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.existing == null ? 'Tambah Kategori' : 'Edit Kategori'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nama Kategori'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Warna', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: widget.presetColors.map((hex) {
              final isSelected = _selectedColor == hex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _parseColor(hex),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _parseColor(hex).withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        AppButton(
          label: _isLoading ? 'Menyimpan...' : 'Simpan',
          isLoading: _isLoading,
          onPressed: _save,
          isExpanded: false,
        ),
      ],
    );
  }
}
