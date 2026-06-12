import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_provider.dart';

part 'auto_backup_provider.g.dart';

@riverpod
class AutoBackupService extends _$AutoBackupService {
  static const _channel = MethodChannel('com.disinidev/storage');

  @override
  void build() {}

  /// Membaca sisa penyimpanan dalam byte (kembali -1 jika error/tidak didukung)
  Future<int> getFreeSpace() async {
    try {
      final int? freeBytes = await _channel.invokeMethod<int>('getFreeSpace');
      return freeBytes ?? -1;
    } catch (e) {
      debugPrint('Gagal mengambil sisa ruang penyimpanan: $e');
      return -1;
    }
  }

  /// Mengecek dan menjalankan auto backup jika memenuhi syarat
  Future<void> checkAndRunAutoBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Cek apakah auto backup diaktifkan
      final autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? false;
      if (!autoBackupEnabled) return;

      // 2. Cek frekuensi (daily atau weekly) dan waktu backup terakhir
      final frequency = prefs.getString('backup_frequency') ?? 'daily';
      final lastBackupStr = prefs.getString('last_auto_backup_at');

      final now = DateTime.now();
      if (lastBackupStr != null) {
        final lastBackup = DateTime.tryParse(lastBackupStr);
        if (lastBackup != null) {
          final difference = now.difference(lastBackup);
          if (frequency == 'daily' && difference.inHours < 24) {
            return; // Belum 24 jam
          }
          if (frequency == 'weekly' && difference.inDays < 7) {
            return; // Belum 7 hari
          }
        }
      }

      // 3. Cek apakah ada perubahan data sejak backup terakhir
      final localDatasource = ref.read(backupLocalDatasourceProvider);
      final lastUpdateTimeStr = await localDatasource.getLastDataUpdateTime();
      
      if (lastUpdateTimeStr == null) {
        // Tidak ada data sama sekali (produk atau transaksi kosong)
        return;
      }

      if (lastBackupStr != null) {
        final lastBackup = DateTime.tryParse(lastBackupStr);
        final lastUpdate = DateTime.tryParse(lastUpdateTimeStr);
        
        if (lastBackup != null && lastUpdate != null) {
          if (!lastUpdate.isAfter(lastBackup)) {
            // Tidak ada perubahan data baru sejak backup terakhir
            debugPrint('Auto backup dilewati: Tidak ada perubahan data baru.');
            return;
          }
        }
      }

      // 4. Jalankan backup
      debugPrint('Menjalankan auto backup...');
      final backupNotifier = ref.read(backupNotifierProvider.notifier);
      final backupResult = await backupNotifier.executeBackup(isAutoBackup: true);

      if (backupResult != null) {
        // Catat waktu sukses auto-backup
        await prefs.setString('last_auto_backup_at', now.toIso8601String());
        debugPrint('Auto backup sukses dijalankan.');
      }
    } catch (e) {
      debugPrint('Gagal menjalankan auto backup: $e');
    }
  }
}
