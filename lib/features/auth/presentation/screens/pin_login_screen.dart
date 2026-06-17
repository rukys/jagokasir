// lib/features/auth/presentation/screens/pin_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../domain/entities/staff_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/staff_provider.dart';

class PinLoginScreen extends ConsumerWidget {
  const PinLoginScreen({super.key});

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

  String _getRoleLabel(StaffRole role) {
    return role.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final staffsAsync = ref.watch(staffListProvider);

    // Auto lock pre-selection check
    staffsAsync.whenData((staffs) {
      final lockedId = ref.read(lockedStaffIdProvider);
      if (lockedId != null) {
        final staff = staffs.where((s) => s.id == lockedId).firstOrNull;
        if (staff != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final currentLockedId = ref.read(lockedStaffIdProvider);
            if (currentLockedId != null) {
              ref.read(lockedStaffIdProvider.notifier).state = null;
              _showPinPadDialog(context, ref, staff);
            }
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header Info
            Image.asset(
              'assets/images/jagokasirlogo.png',
              width: 80,
              height: 80,
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
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Pilih profil untuk masuk',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),

            // Profile List
            Expanded(
              child: staffsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text('Gagal memuat data staff: $e'),
                ),
                data: (staffs) {
                  final activeStaffs = staffs.where((s) => s.isActive).toList();
                  
                  if (activeStaffs.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada staff aktif. Harap hubungi Owner.'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.md,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.lg,
                      mainAxisSpacing: AppSpacing.lg,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: activeStaffs.length,
                    itemBuilder: (context, index) {
                      final staff = activeStaffs[index];
                      final roleBg = _getRoleBgColor(staff.role);
                      final roleText = _getRoleTextColor(staff.role);

                      return InkWell(
                        onTap: () {
                          _showPinPadDialog(context, ref, staff);
                        },
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        child: Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Avatar circle with role-colored background and initials
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: roleBg.withValues(alpha: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    staff.name.isNotEmpty
                                        ? staff.name[0].toUpperCase()
                                        : '?',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: roleText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  staff.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.xs),
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
                                    _getRoleLabel(staff.role),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: roleText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinPadDialog(BuildContext context, WidgetRef ref, StaffEntity staff) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _PinPadDialog(staff: staff);
      },
    );
  }
}

class _PinPadDialog extends ConsumerStatefulWidget {
  const _PinPadDialog({required this.staff});
  final StaffEntity staff;

  @override
  ConsumerState<_PinPadDialog> createState() => _PinPadDialogState();
}

class _PinPadDialogState extends ConsumerState<_PinPadDialog> {
  final _shakeController = ShakeController();
  String _pin = '';
  bool _isLoading = false;

  void _onKeyPress(String val) {
    if (_isLoading) return;
    if (_pin.length >= 6) return;
    setState(() {
      _pin += val;
    });
  }

  void _onBackspace() {
    if (_isLoading || _pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _onSubmit() async {
    if (_isLoading || _pin.length < 4) return;
    
    setState(() {
      _isLoading = true;
    });

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.login(widget.staff.id, _pin);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      context.go(AppRoutes.home);
    } else {
      // Shake animation
      _shakeController.shake();
      setState(() {
        _pin = '';
        _isLoading = false;
      });
      ErrorSnackbar.showError(context, 'PIN yang Anda masukkan salah');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: size.height * 0.75),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button header
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            // Staff Info
            Text(
              'Masukkan PIN',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.staff.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // PIN Dots (Shake widget)
            ShakeWidget(
              controller: _shakeController,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final hasValue = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: hasValue ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.outline,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Numpad 4x3
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 1; i <= 9; i++)
                    _NumpadButton(
                      label: '$i',
                      onPressed: () => _onKeyPress('$i'),
                    ),
                  // Bottom Row (Backspace, 0, OK)
                  IconButton(
                    icon: const Icon(Icons.backspace_outlined, color: AppColors.onSurfaceVariant),
                    onPressed: _onBackspace,
                  ),
                  _NumpadButton(
                    label: '0',
                    onPressed: () => _onKeyPress('0'),
                  ),
                  TextButton(
                    onPressed: _pin.length >= 4 ? _onSubmit : null,
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _pin.length >= 4 ? AppColors.primary : AppColors.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const LinearProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  const _NumpadButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Custom Shake Animation Widget ───────────────────────────────────────────

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    super.key,
    required this.child,
    required this.controller,
  });

  final Widget child;
  final ShakeController controller;

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 12.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 12.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -12.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 8.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -8.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(_animController);

    widget.controller._state = this;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void shake() {
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class ShakeController {
  _ShakeWidgetState? _state;
  void shake() {
    _state?.shake();
  }
}
