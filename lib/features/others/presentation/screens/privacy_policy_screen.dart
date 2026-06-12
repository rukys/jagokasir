// lib/features/others/presentation/screens/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
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
            // Branding header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const Icon(
                      Icons.privacy_tip_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Privasi Data Pengguna',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Terakhir diperbarui: 12 Juni 2026',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Privacy sections
            _buildSection(
              theme,
              title: 'Komitmen 100% Offline & Lokal',
              content: 'Kami sangat menghormati hak privasi dan keamanan finansial bisnis Anda. Aplikasi JagoKasir Offline ini dibuat dengan prinsip privasi mutlak di mana pengembang Aplikasi tidak memantau, tidak mengoleksi, dan tidak memiliki sarana transmisi online apa pun.\n\n'
                  'Seluruh database berisi nama produk, harga modal, harga jual, rincian transaksi penjualan bulanan, jumlah stok gudang, dan kata sandi PIN staf dienkripsi/disimpan lokal pada partisi direktori penyimpanan internal yang aman pada perangkat smartphone Anda.',
            ),

            _buildSection(
              theme,
              title: 'Tidak Ada Transfer Data ke Pihak Ketiga',
              content: 'Karena Aplikasi ini tidak menggunakan koneksi server eksternal, maka:\n'
                  '• Tidak ada transmisi data penjualan Anda ke cloud pengembang atau pihak ketiga.\n'
                  '• Tidak ada skrip analitik pelacakan perilaku (seperti Firebase Analytics, Facebook SDK, dll.) yang berjalan di latar belakang.\n'
                  '• Tidak ada iklan berbasis minat atau penargetan lokasi geografi.',
            ),

            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transparansi Penggunaan Izin Perangkat',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Untuk mendukung fitur fungsional operasional kasir fisik, Aplikasi memerlukan izin akses sistem Android/iOS berikut:',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildPermissionRow(
                      icon: Icons.bluetooth_rounded,
                      title: 'Bluetooth & Lokasi',
                      description: 'Digunakan hanya untuk memindai perangkat sekitar dan menghubungkan Aplikasi dengan printer thermal Bluetooth untuk mencetak struk belanja kertas secara instan.',
                    ),
                    const Divider(height: 24),
                    _buildPermissionRow(
                      icon: Icons.folder_rounded,
                      title: 'Akses Penyimpanan / File',
                      description: 'Diperlukan untuk menyimpan file ekspor cadangan database (.db) ke direktori unduhan (Downloads) perangkat, serta membaca file cadangan tersebut pada saat Anda melakukan pemulihan data (Restore).',
                    ),
                    const Divider(height: 24),
                    _buildPermissionRow(
                      icon: Icons.camera_alt_rounded,
                      title: 'Kamera Perangkat',
                      description: 'Diperlukan untuk memfungsikan lensa kamera HP Anda sebagai pemindai barcode / kode SKU produk secara otomatis dari kemasan barang di masa depan.',
                    ),
                  ],
                ),
              ),
            ),

            _buildSection(
              theme,
              title: 'Penghapusan & Hak Data Anda',
              content: 'Semua data adalah milik mutlak Anda. Jika Anda ingin menghapus seluruh data transaksi dan produk secara permanen, Anda dapat:\n'
                  '1. Melakukan uninstall / hapus pemasangan Aplikasi dari perangkat smartphone Anda (sistem operasi HP secara otomatis menghapus direktori internal penyimpanan database lokal Aplikasi).\n'
                  '2. Melakukan hapus cache / hapus data Aplikasi melalui menu setelan sistem operasi HP Anda.',
            ),

            _buildSection(
              theme,
              title: 'Perubahan Kebijakan Privasi',
              content: 'Pengembang dapat memperbarui Kebijakan Privasi ini sewaktu-waktu sesuai pengembangan fitur. Pembaruan kebijakan akan selalu mengedepankan keamanan data offline dan komitmen kami untuk menjaga data UMKM tersimpan secara privat di dalam HP pengguna masing-masing.',
            ),

            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Dengan menggunakan Aplikasi, Anda menyetujui Kebijakan Privasi ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, {required String title, required String content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
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
    );
  }
}
