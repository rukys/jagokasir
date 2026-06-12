// lib/features/backup/presentation/screens/backup_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/permission_guard.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../providers/backup_provider.dart';

class BackupSettingsScreen extends ConsumerWidget {
  const BackupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(backupSettingsNotifierProvider);
    final theme = Theme.of(context);

    return PermissionGuard(
      allowedRoles: const [StaffRole.owner],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Pengaturan Backup'),
        ),
        body: settingsAsync.when(
          data: (settings) => _buildContent(context, ref, settings, theme),
          error: (err, stack) => Center(child: Text('Gagal memuat pengaturan: $err')),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    BackupSettingsState settings,
    ThemeData theme,
  ) {
    final notifier = ref.read(backupSettingsNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Auto Backup Switch Card
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              side: const BorderSide(color: AppColors.outlineVariant),
            ),
            child: SwitchListTile(
              activeColor: AppColors.primary,
              title: const Text(
                'Auto Backup Aktif',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text(
                'Secara otomatis mencadangkan data ke memori perangkat secara berkala.',
                style: TextStyle(fontSize: 11, color: AppColors.outline),
              ),
              value: settings.isAutoBackupEnabled,
              onChanged: (val) => notifier.toggleAutoBackup(val),
            ),
          ),
          const Gap(AppSpacing.md),

          // Frequency Section
          AnimatedOpacity(
            opacity: settings.isAutoBackupEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !settings.isAutoBackupEnabled,
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frekuensi Pencadangan',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(AppSpacing.xs),
                      Text(
                        'Pilih seberapa sering sistem melakukan backup otomatis.',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.outline),
                      ),
                      const Gap(AppSpacing.md),
                      RadioListTile<String>(
                        activeColor: AppColors.primary,
                        title: const Text('Harian', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Backup dilakukan otomatis setiap hari sekali.', style: TextStyle(fontSize: 11)),
                        value: 'daily',
                        groupValue: settings.frequency,
                        onChanged: (val) {
                          if (val != null) notifier.setFrequency(val);
                        },
                      ),
                      const Divider(),
                      RadioListTile<String>(
                        activeColor: AppColors.primary,
                        title: const Text('Mingguan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Backup dilakukan otomatis setiap seminggu sekali.', style: TextStyle(fontSize: 11)),
                        value: 'weekly',
                        groupValue: settings.frequency,
                        onChanged: (val) {
                          if (val != null) notifier.setFrequency(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.md),

          // Limit Card
          AnimatedOpacity(
            opacity: settings.isAutoBackupEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !settings.isAutoBackupEnabled,
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Batas Maksimal File Cadangan',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(AppSpacing.xs),
                                Text(
                                  'File lama akan otomatis dihapus jika melebihi batas ini.',
                                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.outline),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(
                              '${settings.maxBackupCount} Berkas',
                              style: const TextStyle(
                                color: AppColors.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                      Slider(
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        value: settings.maxBackupCount.toDouble(),
                        onChanged: (val) => notifier.setMaxBackupCount(val.toInt()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.xl),

          // Cleanup action card
          Card(
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
                      const Icon(Icons.cleaning_services_rounded, color: AppColors.warning, size: 24),
                      const Gap(AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bersihkan Cadangan Lama',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Hapus file cadangan lokal lama secara manual untuk menyisakan ruang penyimpanan.',
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
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    onPressed: () => _cleanOldBackupsDialog(context, ref, settings.maxBackupCount),
                    child: const Text('Bersihkan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cleanOldBackupsDialog(BuildContext context, WidgetRef ref, int limit) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bersihkan Cadangan Lama?'),
        content: Text(
          'Sistem akan menghapus seluruh file cadangan lokal lama dan hanya menyisakan maksimal $limit berkas cadangan terbaru.\n\nApakah Anda ingin melanjutkan?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              // Show progress dialog
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('Sedang membersihkan cadangan lama...'),
                    ],
                  ),
                ),
              );

              await ref.read(backupSettingsNotifierProvider.notifier).cleanOldBackups();
              
              if (context.mounted) {
                Navigator.pop(context); // Close progress dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pembersihan berhasil dilakukan')),
                );
              }
            },
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );
  }
}
