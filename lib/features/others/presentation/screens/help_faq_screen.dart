// lib/features/others/presentation/screens/help_faq_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<Map<String, String>> _faqData = [
    {
      'category': 'Printer',
      'question': 'Bagaimana cara menyambungkan printer thermal Bluetooth?',
      'answer': '1. Pastikan printer thermal Anda menyala dan Bluetooth perangkat HP Anda aktif.\n'
          '2. Masuk ke Pengaturan > Pengaturan Printer di aplikasi ini.\n'
          '3. Pilih tab Bluetooth, lalu klik tombol "Cari Printer".\n'
          '4. Pilih nama printer thermal Anda dari daftar yang terdeteksi (biasanya bernama "MTP-II", "PT-210", atau sesuai merk printer).\n'
          '5. Jika diminta PIN penyandingan oleh sistem Android/iOS, coba masukkan "0000" atau "1234".\n'
          '6. Setelah status berubah menjadi "Terhubung", tekan tombol "Cetak Test Struk" untuk memastikan printer berfungsi dengan baik.',
    },
    {
      'category': 'Printer',
      'question': 'Bagaimana cara menyambungkan printer thermal WiFi/Network?',
      'answer': '1. Hubungkan perangkat HP Anda ke jaringan WiFi yang sama dengan printer thermal WiFi/Network Anda.\n'
          '2. Cari tahu IP Address dari printer thermal WiFi Anda (biasanya tertera pada struk self-test saat menyalakan printer sambil menahan tombol FEED).\n'
          '3. Masuk ke menu Pengaturan > Pengaturan Printer di aplikasi ini.\n'
          '4. Pilih tab WiFi / Network, lalu masukkan IP Address printer tersebut (misalnya: 192.168.1.100) dan Port printer (default: 9100).\n'
          '5. Tekan tombol "Hubungkan". Jika koneksi sukses, status koneksi akan berubah menjadi "Terhubung".\n'
          '6. Lakukan cetak test struk untuk memvalidasi sambungan.',
    },
    {
      'category': 'Printer',
      'question':
          'Mengapa struk terpotong atau teks tidak sejajar saat mencetak?',
      'answer':
          '1. Ukuran Kertas Struk: Masuk ke menu Pengaturan > Pengaturan Struk. Pastikan Anda memilih ukuran lebar kertas yang sesuai (58mm atau 80mm). Standar printer portabel kecil umumnya berukuran 58mm.\n'
              '2. Batas Karakter: Sesuaikan batas jumlah karakter per baris struk pada pengaturan jika teks terlihat bertumpuk atau terpotong tidak wajar.',
    },
    {
      'category': 'Transaksi',
      'question': 'Bagaimana cara melakukan pembatalan transaksi (Void)?',
      'answer': '1. Hak Akses: Pembatalan transaksi hanya dapat dilakukan oleh staf dengan role Owner atau Admin. Kasir tidak memiliki akses ini untuk mencegah kecurangan.\n'
          '2. Langkah-langkah:\n'
          '   a. Masuk ke menu Pengaturan > Riwayat Transaksi.\n'
          '   b. Cari struk atau transaksi yang ingin dibatalkan berdasarkan ID Transaksi atau waktu transaksi.\n'
          '   c. Ketuk baris transaksi tersebut untuk masuk ke detail struk.\n'
          '   d. Ketuk tombol merah "Batalkan Transaksi (Void)" di bagian bawah screen.\n'
          '   e. Masukkan alasan pembatalan secara ringkas.\n'
          '   f. Tekan tombol konfirmasi. Status transaksi akan berubah menjadi "Void" (Dibatalkan) secara permanen, stok produk yang terjual akan otomatis dikembalikan ke inventaris, dan perhitungan laba rugi akan diperbarui.',
    },
    {
      'category': 'Transaksi',
      'question': 'Bagaimana aturan perhitungan Pajak & Diskon Belanja?',
      'answer': 'Aplikasi menghitung rincian pembayaran secara otomatis dengan urutan baku demi keakuratan pembukuan:\n'
          '1. Total awal item dihitung berdasarkan (Harga Jual × Jumlah Barang) - Diskon Khusus Item.\n'
          '2. Subtotal transaksi diperoleh dari penjumlahan total akhir seluruh item.\n'
          '3. Diskon Transaksi (persentase atau nominal) dihitung dari Subtotal tersebut.\n'
          '4. Pajak (PPN) dihitung setelah Subtotal dikurangi Diskon Transaksi:\n'
          '   - Jika Pajak Eksklusif (Exclusive): Pajak ditambahkan sebagai biaya tambahan konsumen di luar harga jual produk.\n'
          '   - Jika Pajak Inklusif (Inclusive): Pajak dianggap sudah termasuk di dalam harga jual produk.\n'
          '5. Total Akhir (Grand Total) diperoleh dan dibulatkan ke nominal rupiah terdekat.',
    },
    {
      'category': 'Backup',
      'question': 'Bagaimana cara mengamankan data penjualan (Backup)?',
      'answer': 'Karena aplikasi ini bersifat 100% offline, keamanan data Anda sepenuhnya berada di perangkat lokal Anda.\n'
          '1. Backup Manual:\n'
          '   a. Buka menu Pengaturan > Backup & Restore.\n'
          '   b. Klik tombol "Buat Cadangan Baru".\n'
          '   c. File database (.db) akan diekspor dan disimpan ke folder penyimpanan lokal perangkat Anda.\n'
          '   d. Sangat disarankan untuk membagikan file backup tersebut ke email pribadi, Google Drive, atau WhatsApp Anda sendiri sebagai cadangan jika HP hilang/rusak.\n'
          '2. Backup Otomatis: Aktifkan fitur backup otomatis di menu Pengaturan > Backup & Restore > Setelan Backup Otomatis untuk mencadangkan database secara otomatis setiap kali aplikasi ditutup.',
    },
    {
      'category': 'Backup',
      'question':
          'Bagaimana cara memindahkan data aplikasi ke HP baru (Restore)?',
      'answer': '1. Di HP lama: Buka menu Backup & Restore, buat cadangan baru, lalu kirim file backup (.db) tersebut ke HP baru Anda (melalui Bluetooth, Email, atau WhatsApp).\n'
          '2. Di HP baru:\n'
          '   a. Pastikan Anda telah menginstal aplikasi JagoKasir ini.\n'
          '   b. Salin file backup (.db) tersebut ke penyimpanan HP baru Anda.\n'
          '   c. Jalankan aplikasi, buka menu Pengaturan > Backup & Restore.\n'
          '   d. Ketuk tombol "Pulihkan Data (Restore)", lalu pilih file backup (.db) yang telah dipindahkan tadi.\n'
          '   e. Aplikasi akan memvalidasi file dan memuat ulang seluruh data produk, riwayat transaksi, konfigurasi toko, dan profil staf ke HP baru Anda.',
    },
    {
      'category': 'Akun & Keamanan',
      'question': 'Apa perbedaan hak akses Owner, Admin, dan Kasir?',
      'answer': 'Untuk melindungi kerahasiaan keuangan dan inventaris toko Anda, hak akses dibagi menjadi 3 tingkatan:\n'
          '1. OWNER (Pemilik): Memiliki kontrol penuh atas seluruh aplikasi, termasuk laporan laba bersih (harga beli), penyesuaian PIN staf, penambahan/penghapusan staf baru, serta fitur Backup & Restore database.\n'
          '2. ADMIN: Dapat melayani transaksi di kasir, mengelola database produk, merubah stok manual, mengatur pajak/diskon, melihat riwayat transaksi global, dan melakukan pembatalan transaksi (void). Namun, tidak dapat melihat laporan keuntungan bersih, mengelola data staf, atau melakukan backup/restore.\n'
          '3. KASIR: Hanya diperbolehkan melayani penjualan barang, melihat laporan ringkasan transaksi kasir hari ini, serta mengganti PIN keamanan akun pribadinya saja.',
    },
    {
      'category': 'Akun & Keamanan',
      'question': 'Bagaimana jika staf kasir atau admin lupa PIN login?',
      'answer':
          '1. Jika staf Kasir atau Admin lupa PIN mereka, mereka dapat meminta staf dengan peran Owner untuk menyetel ulang (reset) PIN mereka.\n'
              '2. Langkah Owner:\n'
              '   a. Masuk sebagai Owner menggunakan PIN Owner Anda.\n'
              '   b. Buka menu Pengaturan > Manajemen Staff.\n'
              '   c. Pilih nama staf yang lupa PIN, lalu ketuk opsi edit.\n'
              '   d. Masukkan PIN baru untuk staf tersebut, lalu ketuk simpan.\n'
              '3. Jika Owner lupa PIN Owner, silakan hubungi tim bantuan dukungan pengembang melalui kontak resmi di menu "Tentang Aplikasi" untuk panduan pemulihan khusus.',
    },
    {
      'category': 'Stok',
      'question': 'Bagaimana cara mengelola stok dan penyesuaian stok manual?',
      'answer': '1. Lacak Stok: Saat membuat atau mengedit produk di menu Produk, pastikan pilihan "Pantau Stok" diaktifkan dan masukkan jumlah stok awal beserta batas stok minimum.\n'
          '2. Penyesuaian Stok (Stock Adjustment):\n'
          '   - Jika terjadi selisih stok fisik dengan data aplikasi (misal barang rusak, hilang, atau bonus dari supplier), masuk ke menu Stok > Penyesuaian Stok.\n'
          '   - Pilih produk yang disesuaikan, pilih jenis penyesuaian (Tambah atau Kurang), lalu masukkan jumlah selisih barang dan alasan penyesuaian.\n'
          '3. Alert Stok Rendah: Aplikasi akan otomatis menandai produk dengan warna merah jika jumlah stok saat ini di bawah angka batas stok minimum yang telah Anda tentukan sebelumnya.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter FAQ based on category and search query
    final filteredFaqs = _faqData.where((faq) {
      final matchesCategory =
          _selectedCategory == 'Semua' || faq['category'] == _selectedCategory;
      final matchesSearch =
          faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              faq['answer']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final categories = [
      'Semua',
      'Printer',
      'Transaksi',
      'Backup',
      'Akun & Keamanan',
      'Stok'
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bantuan & FAQ'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // Search Bar container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari solusi atau kata kunci...',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.outline),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.outline),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Category chips
          Container(
            color: Colors.white,
            height: 48,
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          // FAQ List
          Expanded(
            child: filteredFaqs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.help_outline_rounded,
                            size: 64,
                            color: AppColors.outline,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Pertanyaan tidak ditemukan',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onBackground,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            'Coba gunakan kata kunci pencarian lain atau pilih kategori yang berbeda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.outline),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = filteredFaqs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          iconColor: AppColors.primary,
                          textColor: AppColors.primary,
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  faq['category']!,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  faq['question']!,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.lg,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  faq['answer']!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
