import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'app_button.dart';

/// Widget empty state — ditampilkan saat list kosong.
///
/// Contoh:
/// ```dart
/// EmptyState(
///   icon: Icons.inventory_2_outlined,
///   title: 'Belum ada produk',
///   subtitle: 'Tambah produk pertamamu sekarang.',
///   actionLabel: 'Tambah Produk',
///   onAction: () => context.push(AppRoutes.productAdd),
/// );
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.icon = Icons.inbox_outlined,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Icon(
                icon,
                size: AppSpacing.iconSizeLg,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isExpanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
