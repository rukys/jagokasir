// lib/features/auth/presentation/screens/staff_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/permission_guard.dart';
import '../../domain/entities/staff_entity.dart';
import '../providers/staff_provider.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PermissionGuard(
      allowedRoles: [StaffRole.owner],
      child: _StaffListContent(),
    );
  }
}

class _StaffListContent extends ConsumerWidget {
  const _StaffListContent();

  Color _getRoleBgColor(StaffRole role) {
    return switch (role) {
      StaffRole.owner => AppColors.roleOwnerBg,
      StaffRole.admin => AppColors.roleAdminBg,
      StaffRole.kasir => AppColors.roleKasirBg,
    };
  }

  Color _getRoleTextColor(StaffRole role) {
    return switch (role) {
      StaffRole.owner => AppColors.roleOwner,
      StaffRole.admin => AppColors.roleAdmin,
      StaffRole.kasir => AppColors.roleKasir,
    };
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Belum pernah login';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showResetPinDialog(BuildContext context, WidgetRef ref, StaffEntity staff) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset PIN - ${staff.name}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'PIN Baru (4-6 digit)',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'PIN tidak boleh kosong';
                  }
                  if (val.length < 4 || val.length > 6 || int.tryParse(val) == null) {
                    return 'PIN harus 4 sampai 6 digit angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi PIN Baru',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Konfirmasi PIN tidak boleh kosong';
                  }
                  if (val != pinController.text) {
                    return 'PIN konfirmasi tidak cocok';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              final notifier = ref.read(staffNotifierProvider.notifier);
              final success = await notifier.resetPin(
                targetStaffId: staff.id,
                newPin: pinController.text,
                confirmPin: confirmController.text,
              );

              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN staff berhasil direset!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  final errorMsg = ref.read(staffNotifierProvider).error?.toString() ?? 'Gagal mereset PIN';
                  ErrorSnackbar.showError(context, errorMsg);
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final staffsAsync = ref.watch(staffListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manajemen Staff'),
      ),
      body: staffsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text('Gagal memuat data staff: $e'),
        ),
        data: (staffs) {
          if (staffs.isEmpty) {
            return const Center(child: Text('Belum ada staff terdaftar.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            itemCount: staffs.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final staff = staffs[i];
              final roleBg = _getRoleBgColor(staff.role);
              final roleText = _getRoleTextColor(staff.role);

              return Card(
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: roleBg.withValues(alpha: 0.3),
                    child: Text(
                      staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: roleText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          staff.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: roleBg,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          staff.role.name.toUpperCase(),
                          style: TextStyle(
                            color: roleText,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Login terakhir: ${_formatDateTime(staff.lastLoginAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Active Switch Toggle
                      Switch(
                        value: staff.isActive,
                        onChanged: (v) async {
                          final success = await ref
                              .read(staffNotifierProvider.notifier)
                              .toggleActive(id: staff.id, active: v);
                          if (!success && context.mounted) {
                            final err = ref.read(staffNotifierProvider).error?.toString() ?? 'Gagal memperbarui status aktif';
                            ErrorSnackbar.showError(context, err);
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      // Action Menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (val) {
                          if (val == 'edit') {
                            context.push(
                              AppRoutes.staffEdit.replaceAll(':id', staff.id),
                            );
                          } else if (val == 'reset_pin') {
                            _showResetPinDialog(context, ref, staff);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Edit Profil'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'reset_pin',
                            child: Row(
                              children: [
                                Icon(Icons.lock_reset_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Reset PIN'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Staff Baru',
        onPressed: () {
          context.push(AppRoutes.staffAdd);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
