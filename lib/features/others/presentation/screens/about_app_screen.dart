// lib/features/others/presentation/screens/about_app_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            // Logo Branding Container
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_basket_rounded,
                      color: AppColors.primary,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'JagoKasir Offline',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Versi 1.0.0 (Build 100)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Offline badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs - 2),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded, color: AppColors.success, size: 12),
                        SizedBox(width: 4),
                        Text(
                          '100% OFFLINE & GRATIS',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi Aplikasi',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'JagoKasir Offline adalah aplikasi sistem kasir (Point of Sale) pintar yang dirancang khusus untuk mempermudah transaksi penjualan harian wirausaha dan Usaha Mikro, Kecil, dan Menengah (UMKM) di Indonesia.\n\n'
                      'Dengan konsep penyimpanan lokal penuh (Offline-first), seluruh transaksi Anda dapat dilakukan kapan saja dan di mana saja tanpa membutuhkan kuota internet atau jaringan WiFi. Data rahasia dagang Anda tersimpan aman hanya pada HP Anda sendiri.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Tech Stack details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spesifikasi Teknologi',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTechRow(label: 'Framework', value: 'Flutter SDK (>= 3.19.0)'),
                    const Divider(height: 16),
                    _buildTechRow(label: 'Bahasa Pemrograman', value: 'Dart SDK (>= 3.3.0)'),
                    const Divider(height: 16),
                    _buildTechRow(label: 'State Management', value: 'Riverpod 2.x (Code Generation)'),
                    const Divider(height: 16),
                    _buildTechRow(label: 'Database Lokal', value: 'SQLite / Sqflite (WAL Mode enabled)'),
                    const Divider(height: 16),
                    _buildTechRow(label: 'Lisensi Distribusi', value: 'MIT License (Open Source)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Features Highlight
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fitur Unggulan',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildFeatureItem(Icons.bolt_rounded, 'Transaksi Cepat & Akurat', 'Perhitungan harga jual, diskon item/transaksi, dan pajak dalam milidetik secara atomik.'),
                    _buildFeatureItem(Icons.print_rounded, 'Cetak Struk Thermal', 'Mendukung printer thermal tipe Bluetooth portabel dan WiFi jaringan secara nirkabel.'),
                    _buildFeatureItem(Icons.inventory_2_rounded, 'Kontrol Stok & Alert', 'Memantau mutasi kuantitas barang, penyesuaian stok opname manual, dan alert stok menipis.'),
                    _buildFeatureItem(Icons.analytics_rounded, 'Laporan Laba & Rugi', 'Analisis total penjualan harian/bulanan, laba kotor, laba bersih, serta ekspor file laporan.'),
                    _buildFeatureItem(Icons.cloud_download_rounded, 'Backup Database Mandiri', 'Kemudahan ekspor database secara enkripsi lokal dan impor restore saat pindah perangkat HP.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Action Card buttons
            Card(
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.contact_support_rounded,
                    title: 'Hubungi Tim Pengembang',
                    subtitle: 'Kirim masukan atau laporan bug lewat WhatsApp',
                    onTap: () {
                      _showSupportInfoDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  _buildActionTile(
                    icon: Icons.share_rounded,
                    title: 'Bagikan Aplikasi',
                    subtitle: 'Kirim Aplikasi ke rekan bisnis atau wirausaha lainnya',
                    onTap: () {
                      _shareApp(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Copyright
            const Center(
              child: Text(
                '© 2026 JagoKasir Team. Hak Cipta Dilindungi Undang-Undang.',
                style: TextStyle(
                  color: AppColors.outline,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildTechRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.outline,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: AppColors.onBackground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.outline,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.outline),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
      onTap: onTap,
    );
  }

  void _showSupportInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dukungan Pengembang'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jika Anda membutuhkan bantuan teknis khusus atau memiliki usulan fitur tambahan, silakan hubungi tim pengembang melalui:'),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.chat_rounded, color: Colors.green),
                SizedBox(width: AppSpacing.sm),
                Text('WhatsApp: +62 812-3456-7890', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.email_rounded, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Text('Email: support@jagokasir.id', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'Unduh JagoKasir Offline: Aplikasi Kasir Gratis & 100% Offline Tanpa Internet untuk UMKM Indonesia!'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teks promosi aplikasi disalin ke papan klip (clipboard)! Silakan bagikan ke WhatsApp atau media sosial.'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
