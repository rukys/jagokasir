import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import 'app_button.dart';

/// Dialog konfirmasi reusable.
///
/// Contoh:
/// ```dart
/// final confirmed = await ConfirmationDialog.show(
///   context: context,
///   title: 'Hapus Produk?',
///   message: 'Produk tidak bisa dikembalikan setelah dihapus.',
///   confirmText: 'Hapus',
///   isDestructive: true,
/// );
/// if (confirmed == true) { /* hapus */ }
/// ```
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Ya',
    this.cancelText = 'Batal',
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  /// Jika true, tombol konfirmasi akan berwarna merah (error).
  final bool isDestructive;

  /// Tampilkan dialog dan return true jika user konfirmasi, false/null jika batal.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      actions: [
        AppButton.outlined(
          label: cancelText,
          onPressed: () => Navigator.of(context).pop(false),
          isExpanded: false,
        ),
        const SizedBox(width: AppSpacing.sm),
        isDestructive
            ? AppButton.destructive(
                label: confirmText,
                onPressed: () => Navigator.of(context).pop(true),
                isExpanded: false,
              )
            : AppButton(
                label: confirmText,
                onPressed: () => Navigator.of(context).pop(true),
                isExpanded: false,
              ),
      ],
    );
  }
}
