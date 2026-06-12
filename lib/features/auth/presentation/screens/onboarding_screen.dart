// lib/features/auth/presentation/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../domain/entities/staff_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/staff_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  bool _isValid = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final name = _nameController.text.trim();
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    final isValid = name.isNotEmpty &&
        pin.length >= 4 &&
        pin.length <= 6 &&
        int.tryParse(pin) != null &&
        pin == confirmPin;

    if (isValid != _isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_isValid) return;

    final name = _nameController.text.trim();
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    final staffNotifier = ref.read(staffNotifierProvider.notifier);
    
    // Panggil usecase via notifier (role Owner di-enforce di usecase)
    final success = await staffNotifier.create(
      name: name,
      role: StaffRole.owner,
      pin: pin,
      confirmPin: confirmPin,
    );

    if (!mounted) return;

    if (success) {
      // Ambil staff yang baru saja dibuat (Owner pertama)
      final staffsRes = await ref.read(staffRepositoryProvider).getAllStaffs();
      staffsRes.fold(
        (failure) => ErrorSnackbar.showError(context, failure.message),
        (staffs) {
          if (staffs.isNotEmpty) {
            // Set session agar otomatis login
            ref.read(authNotifierProvider.notifier).setSession(staffs.first);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Akun Owner berhasil dibuat! Selamat datang.'),
                backgroundColor: AppColors.success,
              ),
            );
            
            // Redirect ke home
            context.go(AppRoutes.home);
          }
        },
      );
    } else {
      final errorMsg = ref.read(staffNotifierProvider).error?.toString() ?? 'Gagal membuat akun owner';
      ErrorSnackbar.showError(context, errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staffState = ref.watch(staffNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Form(
              key: _formKey,
              onChanged: _validateForm,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & App Name
                  Image.asset(
                    'assets/images/jagokasirlogo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'JagoKasir',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Aplikasi Kasir Offline untuk UMKM',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Card Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang!',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Buat akun Owner untuk mulai menggunakan aplikasi.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Nama Lengkap
                          Text('Nama Lengkap', style: theme.textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan nama lengkap',
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

                          // PIN
                          Text('PIN (4-6 digit)', style: theme.textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            obscureText: _obscurePin,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: 'Masukkan PIN',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePin
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePin = !_obscurePin;
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

                          // Konfirmasi PIN
                          Text('Konfirmasi PIN', style: theme.textTheme.titleSmall),
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
                              hintText: 'Masukkan PIN kembali',
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
                                return 'Konfirmasi PIN tidak boleh kosong';
                              }
                              if (val != _pinController.text) {
                                return 'PIN konfirmasi tidak cocok';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Submit Button
                          AppButton(
                            label: 'Mulai',
                            isLoading: staffState.isLoading,
                            onPressed: _isValid ? _submit : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
