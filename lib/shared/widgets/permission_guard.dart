// lib/shared/widgets/permission_guard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../features/auth/domain/entities/staff_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class PermissionGuard extends ConsumerWidget {
  const PermissionGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  final List<StaffRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffProvider);
    
    if (staff == null || !allowedRoles.contains(staff.role)) {
      return fallback ?? const PermissionDeniedWidget();
    }

    return child;
  }
}

class PermissionDeniedWidget extends StatelessWidget {
  const PermissionDeniedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: AppSpacing.iconSizeLg,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Akses Ditolak',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Anda tidak memiliki izin untuk mengakses halaman atau fitur ini.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
