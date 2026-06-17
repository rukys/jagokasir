// lib/features/home/presentation/screens/settings_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/app_lifecycle_provider.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffProvider);
    final theme = Theme.of(context);
    final idleTimeout = ref.watch(appLifecycleProvider);

    if (staff == null) {
      return const Scaffold(
        body: Center(child: Text('Data sesi tidak ditemukan')),
      );
    }

    final isOwner = staff.role == StaffRole.owner;
    final isKasir = staff.role == StaffRole.kasir;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User profile card
            _buildProfileCard(staff, theme),
            const SizedBox(height: AppSpacing.xl),

            // Settings section header (only for Owner/Admin)
            if (!isKasir) ...[
              Text(
                'Manajemen Toko',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.outline,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                elevation: 0,
                child: Column(
                  children: [
                    if (isOwner) ...[
                      _buildSettingsTile(
                        icon: Icons.people_alt_rounded,
                        title: 'Manajemen Staff',
                        subtitle: 'Kelola akun Owner, Admin, dan Kasir',
                        onTap: () => context.push(AppRoutes.staffList),
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        icon: Icons.backup_rounded,
                        title: 'Backup & Restore',
                        subtitle: 'Cadangkan dan pulihkan data POS offline',
                        onTap: () => context.push(AppRoutes.backup),
                      ),
                      const Divider(height: 1),
                    ],
                    _buildSettingsTile(
                      icon: Icons.receipt_long_rounded,
                      title: 'Pajak & Preset Diskon',
                      subtitle: 'Konfigurasi PPN dan diskon belanja',
                      onTap: () => context.push(AppRoutes.taxDiscount),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.print_rounded,
                      title: 'Pengaturan Printer',
                      subtitle: 'Sambungkan printer thermal Bluetooth & WiFi',
                      onTap: () => context.push(AppRoutes.printerConfig),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.receipt_rounded,
                      title: 'Pengaturan Struk',
                      subtitle: 'Kustomisasi logo, nama toko, dan footer',
                      onTap: () => context.push(AppRoutes.storeConfig),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.history_rounded,
                      title: 'Riwayat Transaksi',
                      subtitle: 'Lihat daftar penjualan & batalkan transaksi',
                      onTap: () => context.push(AppRoutes.transactions),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Keamanan Section
            Text(
              'Keamanan',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.outline,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              elevation: 0,
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.lock_rounded,
                    title: 'Ubah PIN',
                    subtitle: 'Perbarui PIN keamanan akun Anda',
                    onTap: () => context.push(AppRoutes.changePin),
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.lock_clock_rounded,
                    title: 'Waktu Kunci Layar',
                    subtitle: idleTimeout <= 0
                        ? 'Kunci layar otomatis nonaktif'
                        : 'Kunci otomatis setelah $idleTimeout menit',
                    onTap: () {
                      _showTimeoutSelectionDialog(context, ref, idleTimeout);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Lainnya Section
            Text(
              'Lainnya',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.outline,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              elevation: 0,
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan & FAQ',
                    subtitle: 'Petunjuk penggunaan & solusi masalah',
                    onTap: () => context.push(AppRoutes.helpFaq),
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Syarat & Ketentuan',
                    subtitle: 'Aturan penggunaan aplikasi kasir',
                    onTap: () => context.push(AppRoutes.terms),
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Kebijakan Privasi',
                    subtitle: 'Keamanan data & privasi Anda',
                    onTap: () => context.push(AppRoutes.privacy),
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.star_outline_rounded,
                    title: 'Beri Rating',
                    subtitle: 'Dukung aplikasi ini dengan ulasan Anda',
                    onTap: () => _showRatingDialog(context),
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Detail versi, lisensi & pembuat',
                    onTap: () => context.push(AppRoutes.about),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Red Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                onPressed: () => _showLogoutConfirmDialog(context, ref),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded),
                    SizedBox(width: AppSpacing.sm),
                    Text('Keluar (Logout)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Footer version
            const Center(
              child: Text(
                'JagoKasir Offline v1.0.0\n100% Offline & Aman',
                style: TextStyle(
                  color: AppColors.outline,
                  fontSize: 11,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(StaffEntity staff, ThemeData theme) {
    Color badgeColor;
    Color badgeBg;
    String roleLabel;

    switch (staff.role) {
      case StaffRole.owner:
        badgeColor = AppColors.roleOwner;
        badgeBg = AppColors.roleOwnerBg;
        roleLabel = 'OWNER';
        break;
      case StaffRole.admin:
        badgeColor = AppColors.roleAdmin;
        badgeBg = AppColors.roleAdminBg;
        roleLabel = 'ADMIN';
        break;
      case StaffRole.kasir:
        badgeColor = AppColors.roleKasir;
        badgeBg = AppColors.roleKasirBg;
        roleLabel = 'KASIR';
        break;
    }

    final initial =
        staff.name.trim().isNotEmpty ? staff.name.trim()[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: AppSpacing.xs - 1,),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    roleLabel,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: titleColor ?? AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.outline),
      ),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Anda akan keluar dari sesi aktif saat ini. Untuk masuk kembali, Anda perlu memilih profil dan menginputkan PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).clearSession();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutSelectionDialog(
      BuildContext context, WidgetRef ref, int currentTimeout,) {
    showDialog<void>(
      context: context,
      builder: (context) {
        int selectedValue = currentTimeout;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildRadioOption(int value, String label) {
              return RadioListTile<int>(
                title: Text(label),
                value: value,
                // ignore: deprecated_member_use
                groupValue: selectedValue,
                activeColor: AppColors.primary,
                // ignore: deprecated_member_use
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      selectedValue = val;
                    });
                  }
                },
              );
            }

            return AlertDialog(
              title: const Text('Waktu Kunci Layar'),
              contentPadding: const EdgeInsets.only(
                  top: AppSpacing.md, bottom: AppSpacing.sm,),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildRadioOption(1, '1 Menit'),
                    buildRadioOption(2, '2 Menit'),
                    buildRadioOption(5, '5 Menit (Default)'),
                    buildRadioOption(10, '10 Menit'),
                    buildRadioOption(30, '30 Menit'),
                    buildRadioOption(0, 'Tidak Pernah'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.primary),
                  onPressed: () {
                    ref
                        .read(appLifecycleProvider.notifier)
                        .updateTimeoutMinutes(selectedValue);
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }



  void _showRatingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        int rating = 5;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Beri Rating Aplikasi'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Dukung pengembangan JagoKasir Offline agar tetap GRATIS selamanya dengan memberikan penilaian terbaik Anda!'),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = starValue;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Terima kasih atas rating bintang $rating Anda!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
