// lib/shared/providers/app_lifecycle_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

part 'app_lifecycle_provider.g.dart';

@riverpod
class AppLifecycle extends _$AppLifecycle {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    _loadSettings();
    return 5; // Default value before loading from SharedPreferences
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final minutes = prefs.getInt('idle_timeout_minutes') ?? 5;
      state = minutes;
      resetTimer();
    } catch (_) {
      state = 5;
      resetTimer();
    }
  }

  void resetTimer() {
    _timer?.cancel();

    final isLoggedIn = ref.read(isLoggedInProvider);
    if (!isLoggedIn) return; // Jangan jalankan timer jika belum login

    final minutes = state;
    if (minutes <= 0) return; // Tidak pernah kunci otomatis jika <= 0

    _timer = Timer(Duration(minutes: minutes), () {
      debugPrint('Idle timeout reached ($minutes minutes). Locking screen...');
      final current = ref.read(currentStaffProvider);
      if (current != null) {
        ref.read(lockedStaffIdProvider.notifier).state = current.id;
      }
      ref.read(authNotifierProvider.notifier).clearSession();
    });
  }

  Future<void> updateTimeoutMinutes(int minutes) async {
    if (minutes < 0 || minutes > 60) return;
    state = minutes;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('idle_timeout_minutes', minutes);
    } catch (_) {}
    resetTimer();
  }
}
