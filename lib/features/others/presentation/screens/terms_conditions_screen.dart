// lib/features/others/presentation/screens/terms_conditions_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan'),
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
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Ketentuan Penggunaan Aplikasi',
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

            // Terms Content
            _buildSection(
              theme,
              title: '1. Penerimaan Ketentuan',
              content: 'Dengan mengunduh, menginstal, atau menggunakan aplikasi JagoKasir Offline ("Aplikasi"), Anda menyatakan bahwa Anda telah membaca, memahami, dan menyetujui untuk terikat oleh Syarat & Ketentuan ini. Jika Anda tidak menyetujui ketentuan ini, Anda tidak diperkenankan menggunakan Aplikasi ini.',
            ),
            _buildSection(
              theme,
              title: '2. Deskripsi Layanan & Lisensi',
              content: 'Aplikasi ini dirancang sebagai sistem Point of Sale (POS) kasir offline yang ditujukan untuk membantu pengelolaan transaksi penjualan, pencatatan stok barang, dan laporan keuangan dasar bagi usaha mikro, kecil, dan menengah (UMKM).\n\n'
                  'Aplikasi ini disediakan secara GRATIS, bebas dari iklan yang mengganggu, dan tidak mewajibkan registrasi langganan. Aplikasi ini didistribusikan di bawah Lisensi MIT, yang berarti Anda diberikan hak penuh untuk menggunakan, menyalin, memodifikasi, dan mendistribusikan salinan Aplikasi untuk tujuan komersial maupun pribadi tanpa biaya tersembunyi.',
            ),
            _buildSection(
              theme,
              title: '3. Penyimpanan Data & Sifat Offline',
              content: 'Aplikasi ini bekerja sepenuhnya secara lokal (Offline-first):\n'
                  '• Semua data transaksi, informasi produk, detail keuangan, data inventaris, dan PIN otentikasi staf disimpan langsung di memori penyimpanan internal perangkat HP Anda.\n'
                  '• Pengembang Aplikasi tidak memiliki server backend cloud untuk mengunggah, memproses, memantau, atau mencadangkan data Anda secara online.\n'
                  '• Anda mengakui bahwa hilangnya perangkat Anda atau kerusakan sistem OS akan secara otomatis menghilangkan seluruh data transaksi Anda jika Anda tidak melakukan backup data secara berkala.',
            ),
            _buildSection(
              theme,
              title: '4. Tanggung Jawab Keamanan & Cadangan Data (Backup)',
              content: 'Sebagai pengguna Aplikasi, Anda bertanggung jawab penuh atas:\n'
                  '• Melakukan ekspor cadangan database (.db) secara mandiri dan berkala melalui fitur "Backup & Restore" ke media eksternal (seperti kartu SD, flashdisk, Google Drive, email pribadi, atau WhatsApp).\n'
                  '• Menjaga keamanan fisik perangkat Anda dari akses tidak sah oleh pihak ketiga.\n'
                  '• Menjaga kerahasiaan PIN akses staf kasir dan admin untuk mencegah penyalahgunaan data penjualan atau manipulasi stok barang.',
            ),
            _buildSection(
              theme,
              title: '5. Batasan Tanggung Jawab',
              content: 'APLIKASI INI DISEDIAKAN "APA ADANYA", TANPA JAMINAN APAPUN, BAIK TERSURAT MAUPUN TERSIRAT.\n\n'
                  'Dalam hal apa pun, pengembang Aplikasi tidak bertanggung jawab atas:\n'
                  '• Segala kerusakan, kehilangan laba, kegagalan transaksi keuangan, atau hilangnya data penjualan Anda akibat kerusakan fisik perangkat HP, serangan virus, kegagalan OS, atau hilangnya file cadangan database.\n'
                  '• Kesalahan penginputan data harga jual, stok barang, perhitungan PPN/diskon, atau void transaksi yang dilakukan oleh staf kasir Anda.',
            ),
            _buildSection(
              theme,
              title: '6. Perubahan Ketentuan & Fitur',
              content: 'Pengembang berhak memperbarui, memodifikasi, atau menghentikan fitur-fitur tertentu dalam Aplikasi kapan saja guna meningkatkan kinerja atau keamanan sistem. Pembaruan Aplikasi yang tersedia melalui toko aplikasi resmi akan tetap mengikuti filosofi dasar gratis dan berfokus pada sistem offline untuk kenyamanan pengguna.',
            ),
            _buildSection(
              theme,
              title: '7. Hukum yang Berlaku',
              content: 'Syarat & Ketentuan ini diatur oleh dan ditafsirkan sesuai dengan hukum Republik Indonesia. Setiap perselisihan yang timbul dari penggunaan Aplikasi ini akan diselesaikan secara musyawarah dan kekeluargaan.',
            ),

            const SizedBox(height: AppSpacing.xl),
            // Confirmation note
            const Text(
              'Terima kasih telah mempercayai JagoKasir Offline untuk mendukung kemajuan bisnis Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
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
}
