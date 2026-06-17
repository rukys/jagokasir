import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Full-screen loading overlay dengan CircularProgressIndicator.
/// Gunakan di atas Stack atau sebagai modal barrier.
///
/// Contoh pakai dengan Stack:
/// ```dart
/// Stack(
///   children: [
///     // ... konten utama
///     if (isLoading) const LoadingOverlay(),
///   ],
/// );
/// ```
///
/// Atau tampilkan sebagai dialog:
/// ```dart
/// LoadingOverlay.show(context);
/// // ...
/// LoadingOverlay.hide(context);
/// ```
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor,
  });

  final String? message;
  final Color? backgroundColor;

  /// Tampilkan loading overlay sebagai dialog non-dismissable.
  static void show(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingOverlay(message: message),
    );
  }

  /// Sembunyikan loading overlay dialog.
  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
