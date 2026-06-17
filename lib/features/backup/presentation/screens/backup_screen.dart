// lib/features/backup/presentation/screens/backup_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/permission_guard.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../domain/entities/backup_history_entity.dart';
import '../providers/auto_backup_provider.dart';
import '../providers/backup_provider.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(backupHistoryProvider);
    final theme = Theme.of(context);

    return PermissionGuard(
      allowedRoles: const [StaffRole.owner],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Backup & Restore'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              tooltip: 'Pengaturan Backup',
              onPressed: () => context.push('/settings/backup/settings'),
            ),
          ],
        ),
        body: historyAsync.when(
          data: (historyList) => _buildContent(context, ref, historyList, theme),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const Gap(AppSpacing.md),
                  Text('Gagal memuat riwayat backup: $err', textAlign: TextAlign.center),
                  const Gap(AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(backupHistoryProvider),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<BackupHistoryEntity> historyList,
    ThemeData theme,
  ) {
    final lastBackup = historyList.firstOrNull;
    
    // Calculate total backup size
    double totalBytes = 0;
    for (final item in historyList) {
      totalBytes += item.fileSizeBytes;
    }
    final totalKb = totalBytes / 1024;
    final totalMb = totalKb / 1024;
    final totalSizeFormatted = totalMb >= 1.0
        ? '${totalMb.toStringAsFixed(2)} MB'
        : '${totalKb.toStringAsFixed(1)} KB';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info & Quick Action Card
          _buildHeroCard(context, ref, lastBackup, totalSizeFormatted, theme),
          const Gap(AppSpacing.xl),

          // Restore from External File Button
          _buildExternalRestoreSection(context, ref, theme),
          const Gap(AppSpacing.xl),

          // History Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Cadangan Lokal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
              if (historyList.isNotEmpty)
                Text(
                  '${historyList.length} Berkas',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.outline),
                ),
            ],
          ),
          const Gap(AppSpacing.sm),

          // List of History
          if (historyList.isEmpty)
            _buildEmptyHistory(theme)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: historyList.length,
              separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = historyList[index];
                return _buildHistoryItem(context, ref, item, theme);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    WidgetRef ref,
    BackupHistoryEntity? lastBackup,
    String totalSizeFormatted,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penyimpanan Awan Lokal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Riwayat: $totalSizeFormatted',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.xl),
          
          // Last backup details
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CADANGAN TERAKHIR:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const Gap(AppSpacing.xs),
                Text(
                  lastBackup != null
                      ? _formatDateTime(lastBackup.createdAt)
                      : 'Belum pernah dicadangkan',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (lastBackup != null) ...[
                  const Gap(AppSpacing.xs),
                  Text(
                    'Ukuran: ${lastBackup.fileSizeFormatted} • ${lastBackup.totalTransactions} Transaksi',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(AppSpacing.lg),

          // Action Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            onPressed: () => _performBackup(context, ref),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.backup_rounded, size: 20),
                Gap(AppSpacing.sm),
                Text(
                  'Buat Backup Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalRestoreSection(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.file_open_rounded, color: AppColors.secondary, size: 24),
                const Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pulihkan dari File Luar',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pilih file backup (.zip) dari folder unduhan / memori perangkat.',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.md),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              onPressed: () => _pickAndRestoreFile(context, ref),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.unarchive_rounded, size: 18),
                  Gap(AppSpacing.sm),
                  Text('Pilih File & Restore', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.outlineVariant,
            ),
            const Gap(AppSpacing.md),
            Text(
              'Belum Ada Riwayat Backup',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(AppSpacing.xs),
            Text(
              'Cadangan yang Anda buat secara manual atau otomatis akan muncul di sini.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    BackupHistoryEntity item,
    ThemeData theme,
  ) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.share_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Share
          _performShare(context, ref, item);
          return false; // Do not dismiss item visually
        } else {
          // Confirm Delete
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Hapus Cadangan?'),
              content: Text(
                'Apakah Anda yakin ingin menghapus berkas cadangan "${item.fileName}"?\nTindakan ini permanen.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            final success = await ref.read(backupNotifierProvider.notifier).executeDelete(item.id);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Berkas cadangan berhasil dihapus')),
              );
            }
            return success;
          }
          return false;
        }
      },
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.archive_rounded,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          title: Text(
            item.fileName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(2),
              Text(
                'Ukuran: ${item.fileSizeFormatted} • Transaksi: ${item.totalTransactions}',
                style: const TextStyle(fontSize: 11, color: AppColors.outline),
              ),
              const Gap(2),
              Text(
                _formatDateTime(item.createdAt),
                style: const TextStyle(fontSize: 10, color: AppColors.outline, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.outline),
            onSelected: (action) {
              if (action == 'restore') {
                _confirmRestoreDialog(context, ref, item);
              } else if (action == 'share') {
                _performShare(context, ref, item);
              } else if (action == 'delete') {
                _confirmDeleteDialog(context, ref, item);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.restore_rounded, color: AppColors.primary, size: 20),
                    Gap(AppSpacing.sm),
                    Text('Restore Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, color: AppColors.secondary, size: 20),
                    Gap(AppSpacing.sm),
                    Text('Bagikan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    Gap(AppSpacing.sm),
                    Text('Hapus'),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _confirmRestoreDialog(context, ref, item),
        ),
      ),
    );
  }

  // Aksi Backup
  Future<void> _performBackup(BuildContext context, WidgetRef ref) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Sedang mencadangkan data...'),
            ],
          ),
        ),
      ),
    );

    final history = await ref.read(backupNotifierProvider.notifier).executeBackup();
    
    if (context.mounted) {
      Navigator.pop(context); // Tutup dialog loading
      if (history != null) {
        final freeSpace = await ref.read(autoBackupServiceProvider.notifier).getFreeSpace();
        final isSpaceLow = freeSpace > 0 && freeSpace < 50 * 1024 * 1024; // < 50MB

        if (isSpaceLow) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pencadangan berhasil! Berkas: ${history.fileName}\n'
                '⚠️ Peringatan: Ruang penyimpanan hampir penuh (tersisa kurang dari 50 MB).',
              ),
              backgroundColor: AppColors.tertiary,
              duration: const Duration(seconds: 6),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pencadangan berhasil! Berkas: ${history.fileName}'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } else {
        final state = ref.read(backupNotifierProvider);
        final errorMsg = state.maybeWhen(
          error: (error, _) => error.toString(),
          orElse: () => 'Terjadi kesalahan tidak dikenal.',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pencadangan gagal: $errorMsg'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Aksi Share
  Future<void> _performShare(BuildContext context, WidgetRef ref, BackupHistoryEntity item) async {
    final success = await ref.read(backupNotifierProvider.notifier).executeShare(item.filePath);
    if (!success && context.mounted) {
      final state = ref.read(backupNotifierProvider);
      final errorMsg = state.maybeWhen(
        error: (error, _) => error.toString(),
        orElse: () => 'Terjadi kesalahan saat membagikan file.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membagikan: $errorMsg'), backgroundColor: AppColors.error),
      );
    }
  }

  // Konfirmasi Restore
  void _confirmRestoreDialog(BuildContext context, WidgetRef ref, BackupHistoryEntity item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pulihkan Data?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anda akan memulihkan data dari berkas berikut:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Gap(AppSpacing.sm),
            Text('Nama File: ${item.fileName}'),
            Text('Tanggal Dibuat: ${_formatDateTime(item.createdAt)}'),
            Text('Ukuran: ${item.fileSizeFormatted}'),
            Text('Total Transaksi: ${item.totalTransactions}'),
            const Gap(AppSpacing.md),
            const Text(
              'Peringatan: Seluruh data aktif saat ini akan ditimpa secara permanen.',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
            const Gap(AppSpacing.sm),
            const Text(
              'Catatan: Sistem akan membuat cadangan penyelamat (safety-net) secara otomatis sebelum memulai restore.',
              style: TextStyle(fontSize: 11, color: AppColors.outline),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _performRestore(context, ref, item.filePath);
            },
            child: const Text('Pulihkan Sekarang'),
          ),
        ],
      ),
    );
  }

  // Konfirmasi Hapus
  void _confirmDeleteDialog(BuildContext context, WidgetRef ref, BackupHistoryEntity item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Cadangan?'),
        content: Text('Apakah Anda yakin ingin menghapus berkas cadangan "${item.fileName}"?\nTindakan ini permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(backupNotifierProvider.notifier).executeDelete(item.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Berkas cadangan berhasil dihapus')),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Pilih & Restore File ZIP dari Luar
  Future<void> _pickAndRestoreFile(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        
        // Show validation loading
        if (context.mounted) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Memvalidasi file backup...'),
                ],
              ),
            ),
          );
        }

        final metadata = await ref.read(restoreNotifierProvider.notifier).executeValidate(path);
        
        if (context.mounted) {
          Navigator.pop(context); // Close validation dialog
        }

        if (metadata != null && context.mounted) {
          final createdAtStr = metadata['created_at'] != null 
              ? _formatDateTime(DateTime.parse(metadata['created_at'] as String))
              : '-';
          
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('File Valid. Pulihkan?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi berkas cadangan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Gap(AppSpacing.sm),
                  Text('App Version: ${metadata['app_version']}'),
                  Text('Schema Version: ${metadata['backup_schema_version']}'),
                  Text('Total Transaksi: ${metadata['total_transactions'] ?? 0}'),
                  Text('Total Produk: ${metadata['total_products'] ?? 0}'),
                  Text('Tanggal Dibuat: $createdAtStr'),
                  const Gap(AppSpacing.md),
                  const Text(
                    'Peringatan: Seluruh data aktif saat ini akan ditimpa secara permanen.',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _performRestore(context, ref, path);
                  },
                  child: const Text('Pulihkan Sekarang'),
                ),
              ],
            ),
          );
        } else if (context.mounted) {
          final state = ref.read(restoreNotifierProvider);
          final errorMsg = state.maybeWhen(
            error: (error, _) => error.toString(),
            orElse: () => 'Berkas tidak valid atau terjadi kesalahan saat validasi.',
          );
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Validasi Gagal'),
              content: Text('Berkas tidak valid atau rusak: $errorMsg'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // Melakukan Restore Riil
  Future<void> _performRestore(BuildContext context, WidgetRef ref, String filePath) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Sedang memulihkan data... Jangan tutup aplikasi.'),
            ],
          ),
        ),
      ),
    );

    final success = await ref.read(restoreNotifierProvider.notifier).executeRestore(filePath);
    
    if (context.mounted) {
      Navigator.pop(context); // Tutup dialog loading
      if (success) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Pemulihan Sukses'),
            content: const Text(
              'Data berhasil dipulihkan dari berkas cadangan! Silakan restart aplikasi untuk memuat data baru secara keseluruhan.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  exit(0);
                },
                child: const Text('Keluar & Restart Aplikasi'),
              ),
            ],
          ),
        );
      } else {
        final state = ref.read(restoreNotifierProvider);
        final errorMsg = state.maybeWhen(
          error: (error, _) => error.toString(),
          orElse: () => 'Terjadi kesalahan tidak dikenal.',
        );
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pemulihan Gagal'),
            content: Text(
              'Gagal memulihkan berkas cadangan. $errorMsg\n\nDatabase telah dikembalikan secara otomatis ke kondisi sebelum restore (safety-net).',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
