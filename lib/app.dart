// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/backup/presentation/providers/auto_backup_provider.dart';
import 'shared/providers/app_lifecycle_provider.dart';

/// Root widget aplikasi POS Kasir.
class PosKasirApp extends ConsumerStatefulWidget {
  const PosKasirApp({super.key});

  @override
  ConsumerState<PosKasirApp> createState() => _PosKasirAppState();
}

class _PosKasirAppState extends ConsumerState<PosKasirApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(autoBackupServiceProvider.notifier).checkAndRunAutoBackup();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(autoBackupServiceProvider.notifier).checkAndRunAutoBackup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return Listener(
      onPointerDown: (_) {
        // Reset idle timer on any pointer down event (tap, scroll, etc.)
        ref.read(appLifecycleProvider.notifier).resetTimer();
      },
      child: MaterialApp.router(
        title: 'JagoKasir',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }
}
