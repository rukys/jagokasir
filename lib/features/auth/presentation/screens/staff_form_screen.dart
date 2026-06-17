// lib/features/auth/presentation/screens/staff_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/permission_guard.dart';
import '../../domain/entities/staff_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/staff_provider.dart';

class StaffFormScreen extends ConsumerWidget {
  const StaffFormScreen({super.key, this.staffId});
  final String? staffId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PermissionGuard(
      allowedRoles: const [StaffRole.owner],
      child: _StaffFormContent(staffId: staffId),
    );
  }
}

class _StaffFormContent extends ConsumerStatefulWidget {
  const _StaffFormContent({this.staffId});
  final String? staffId;

  @override
  ConsumerState<_StaffFormContent> createState() => _StaffFormContentState();
}

class _StaffFormContentState extends ConsumerState<_StaffFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  StaffRole _selectedRole = StaffRole.kasir;
  bool _isObscurePin = true;
  bool _isObscureConfirmPin = true;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.staffId != null;

  void _initializeFields(StaffEntity staff) {
    if (_isInitialized) return;
    _nameController.text = staff.name;
    _selectedRole = staff.role;
    _isInitialized = true;
  }

  Future<void> _submit(StaffEntity? originalStaff) async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final notifier = ref.read(staffNotifierProvider.notifier);

    bool success;
    if (_isEditMode) {
      success = await notifier.update(
        id: widget.staffId!,
        name: name,
        role: _selectedRole,
      );
    } else {
      success = await notifier.create(
        name: name,
        role: _selectedRole,
        pin: _pinController.text,
        confirmPin: _confirmPinController.text,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Profil staff berhasil diperbarui' : 'Staff baru berhasil terdaftar'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final errorMsg = ref.read(staffNotifierProvider).error?.toString() ?? 'Gagal menyimpan data staff';
      ErrorSnackbar.showError(context, errorMsg);
    }
  }

  void _showResetPinDialog(StaffEntity staff) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset PIN - ${staff.name}'),
        content: Form(
          key: dialogFormKey,
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
              if (!dialogFormKey.currentState!.validate()) return;
              
              final notifier = ref.read(staffNotifierProvider.notifier);
              final success = await notifier.resetPin(
                targetStaffId: staff.id,
                newPin: pinController.text,
                confirmPin: confirmController.text,
              );

              if (!mounted) return;
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staffNotifierState = ref.watch(staffNotifierProvider);

    if (_isEditMode) {
      final staffAsync = ref.watch(staffByIdProvider(widget.staffId!));
      return staffAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Staff')),
          body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Staff')),
          body: Center(child: Text(e.toString())),
        ),
        data: (staff) {
          _initializeFields(staff);
          return _buildForm(theme, staffNotifierState.isLoading, staff);
        },
      );
    }

    return _buildForm(theme, staffNotifierState.isLoading, null);
  }

  Widget _buildForm(ThemeData theme, bool isLoading, StaffEntity? staff) {
    final currentStaff = ref.watch(currentStaffProvider);
    final isOwner = currentStaff?.role == StaffRole.owner;

    final availableRoles = [
      if (isOwner) StaffRole.owner,
      StaffRole.admin,
      StaffRole.kasir,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Staff' : 'Tambah Staff Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Lengkap
                      Text('Nama Lengkap', style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama lengkap staff',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Role Dropdown
                      Text('Role / Jabatan', style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<StaffRole>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: availableRoles
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _selectedRole = val;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // PIN Fields (only in create mode)
                      if (!_isEditMode) ...[
                        Text('PIN (4-6 digit)', style: theme.textTheme.titleSmall),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                           obscureText: _isObscurePin,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(6),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'Tentukan PIN masuk',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscurePin
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscurePin = !_isObscurePin;
                                });
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'PIN tidak boleh kosong';
                            }
                            if (val.length < 4 || val.length > 6) {
                              return 'PIN harus 4 sampai 6 digit';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        Text('Konfirmasi PIN', style: theme.textTheme.titleSmall),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _confirmPinController,
                          keyboardType: TextInputType.number,
                           obscureText: _isObscureConfirmPin,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(6),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'Ketik ulang PIN',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscureConfirmPin
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscureConfirmPin = !_isObscureConfirmPin;
                                });
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Konfirmasi PIN tidak boleh kosong';
                            }
                            if (val != _pinController.text) {
                              return 'PIN konfirmasi tidak cocok';
                            }
                            return null;
                          },
                        ),
                      ],

                      // Reset PIN button (only in edit mode)
                      if (_isEditMode && staff != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: () => _showResetPinDialog(staff),
                          icon: const Icon(Icons.lock_reset_rounded),
                          label: const Text('Reset PIN Staff'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),

                      // Submit Button
                      AppButton(
                        label: _isEditMode ? 'Simpan Perubahan' : 'Daftarkan Staff',
                        isLoading: isLoading,
                        onPressed: () => _submit(staff),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
