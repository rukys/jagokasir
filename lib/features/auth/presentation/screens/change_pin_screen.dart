// lib/features/auth/presentation/screens/change_pin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/staff_provider.dart';

class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _obscureOldPin = true;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentStaff = ref.read(currentStaffProvider);
    if (currentStaff == null) {
      ErrorSnackbar.showError(context, 'Data sesi tidak ditemukan');
      return;
    }

    final success = await ref.read(staffNotifierProvider.notifier).changePin(
          staffId: currentStaff.id,
          oldPin: _oldPinController.text,
          newPin: _newPinController.text,
          confirmPin: _confirmPinController.text,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Anda berhasil diperbarui'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      final errorMsg = ref.read(staffNotifierProvider).error?.toString() ?? 'Gagal memperbarui PIN';
      ErrorSnackbar.showError(context, errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staffState = ref.watch(staffNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ubah PIN'),
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
                      // Current PIN (PIN Lama)
                      Text('PIN Lama', style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _oldPinController,
                        keyboardType: TextInputType.number,
                        obscureText: _obscureOldPin,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Masukkan PIN lama Anda',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureOldPin
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureOldPin = !_obscureOldPin;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'PIN lama tidak boleh kosong';
                          }
                          if (val.length < 4 || val.length > 6) {
                            return 'PIN harus 4 sampai 6 digit';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // New PIN (PIN Baru)
                      Text('PIN Baru (4-6 digit)', style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _newPinController,
                        keyboardType: TextInputType.number,
                        obscureText: _obscureNewPin,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Masukkan PIN baru',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPin
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPin = !_obscureNewPin;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'PIN baru tidak boleh kosong';
                          }
                          if (val.length < 4 || val.length > 6) {
                            return 'PIN baru harus 4 sampai 6 digit';
                          }
                          if (val == _oldPinController.text) {
                            return 'PIN baru tidak boleh sama dengan PIN lama';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Confirm New PIN (Konfirmasi PIN Baru)
                      Text('Konfirmasi PIN Baru', style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _confirmPinController,
                        keyboardType: TextInputType.number,
                        obscureText: _obscureConfirmPin,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Ketik ulang PIN baru',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPin
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPin = !_obscureConfirmPin;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Konfirmasi PIN baru tidak boleh kosong';
                          }
                          if (val != _newPinController.text) {
                            return 'Konfirmasi PIN tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Submit Button
                      AppButton(
                        label: 'Simpan PIN Baru',
                        isLoading: staffState.isLoading,
                        onPressed: _submit,
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
