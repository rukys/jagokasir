import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class IdleLockDialog extends StatefulWidget {
  const IdleLockDialog({
    super.key,
    required this.staff,
    required this.onUnlocked,
  });

  final StaffEntity staff;
  final VoidCallback onUnlocked;

  @override
  State<IdleLockDialog> createState() => _IdleLockDialogState();
}

class _IdleLockDialogState extends State<IdleLockDialog> {
  final _shakeController = ShakeController();
  String _pin = '';
  bool _isLoading = false;

  void _onKeyPress(String val) {
    if (_isLoading || _pin.length >= 6) return;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog.fullscreen(
      backgroundColor: AppColors.background,
      child: Consumer(
        builder: (context, ref, _) {
          Future<void> onSubmit() async {
            if (_isLoading || _pin.length < 4) return;

            setState(() {
              _isLoading = true;
            });

            final authNotifier = ref.read(authNotifierProvider.notifier);
            final success = await authNotifier.login(widget.staff.id, _pin);

            if (!mounted) return;

            if (success) {
              widget.onUnlocked();
              Navigator.pop(context);
            } else {
              _shakeController.shake();
              setState(() {
                _pin = '';
                _isLoading = false;
              });
              ErrorSnackbar.showError(context, 'PIN yang Anda masukkan salah');
            }
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Layar Terkunci',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Masukkan PIN untuk membuka sesi kasir ${widget.staff.name}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.outline),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // PIN Dots
                  ShakeWidget(
                    controller: _shakeController,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final hasValue = index < _pin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: hasValue
                                ? AppColors.primary
                                : Colors.transparent,
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
                        IconButton(
                          icon: const Icon(Icons.backspace_outlined),
                          onPressed: _onBackspace,
                        ),
                        _NumpadButton(
                          label: '0',
                          onPressed: () => _onKeyPress('0'),
                        ),
                        TextButton(
                          onPressed: _pin.length >= 4 ? onSubmit : null,
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _pin.length >= 4
                                  ? AppColors.primary
                                  : AppColors.outline,
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
        },
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

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

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
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
      TweenSequenceItem(
        tween: Tween<double>(begin: 12.0, end: -12.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -12.0, end: 8.0),
        weight: 1,
      ),
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
