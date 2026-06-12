import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Variant tombol AppButton.
enum AppButtonVariant {
  /// Tombol primer — `ElevatedButton` dengan background primary.
  primary,

  /// Tombol sekunder — `OutlinedButton`.
  outlined,

  /// Tombol destruktif (hapus, void) — `ElevatedButton` dengan background error.
  destructive,

  /// Tombol teks — `TextButton`.
  text,
}

/// Tombol reusable POS Kasir dengan loading state dan variant.
///
/// Contoh:
/// ```dart
/// AppButton(
///   label: 'Simpan',
///   onPressed: () => doSomething(),
/// );
/// AppButton.destructive(
///   label: 'Hapus',
///   onPressed: () => confirmDelete(),
/// );
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.height = AppSpacing.buttonHeight,
  });

  /// Constructor shortcut untuk tombol destruktif.
  const AppButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.height = AppSpacing.buttonHeight,
  }) : variant = AppButtonVariant.destructive;

  /// Constructor shortcut untuk tombol outlined.
  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.height = AppSpacing.buttonHeight,
  }) : variant = AppButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final Widget? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = isLoading ? null : onPressed;

    // ignore: prefer_final_locals
    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getLoadingColor(variant),
            ),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              const SizedBox(width: AppSpacing.sm),
              Text(label),
            ],
          )
        : Text(label);

    // ignore: prefer_final_locals
    Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.destructive => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onError,
          minimumSize: Size(isExpanded ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    };

    if (!isExpanded &&
        variant != AppButtonVariant.destructive &&
        variant != AppButtonVariant.text) {
      button = SizedBox(height: height, child: button);
    }

    return SizedBox(
      width: isExpanded ? double.infinity : null,
      child: button,
    );
  }

  Color _getLoadingColor(AppButtonVariant v) => switch (v) {
    AppButtonVariant.primary => AppColors.onPrimary,
    AppButtonVariant.outlined => AppColors.primary,
    AppButtonVariant.destructive => AppColors.onError,
    AppButtonVariant.text => AppColors.primary,
  };
}
