import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Helper functions untuk menampilkan SnackBar error dan success.
///
/// Contoh:
/// ```dart
/// ErrorSnackbar.showError(context, 'Gagal menyimpan produk');
/// ErrorSnackbar.showSuccess(context, 'Produk berhasil disimpan');
/// ErrorSnackbar.showWarning(context, 'Stok hampir habis');
/// ```
class ErrorSnackbar {
  ErrorSnackbar._();

  /// Tampilkan snackbar error (background merah).
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.danger,
      icon: Icons.error_outline_rounded,
    );
  }

  /// Tampilkan snackbar sukses (background hijau).
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Tampilkan snackbar warning (background amber).
  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// Tampilkan snackbar info (background teal).
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline_rounded,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: AppColors.surface, size: AppSpacing.iconSizeMd),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.surface,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
