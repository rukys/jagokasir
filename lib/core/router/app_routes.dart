/// Semua route path string.
/// Gunakan konstanta ini di GoRouter dan saat navigasi.
class AppRoutes {
  AppRoutes._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String splash      = '/';
  static const String login       = '/login';
  static const String pinSetup    = '/pin-setup';
  static const String onboarding  = '/onboarding';

  // ── Main shell ────────────────────────────────────────────────────────────
  static const String home        = '/home';
  static const String cashier     = '/cashier';
  static const String products    = '/products';
  static const String reports     = '/reports';
  static const String settings    = '/settings';

  // ── Products ──────────────────────────────────────────────────────────────
  static const String productAdd    = '/products/add';
  static const String productDetail = '/products/:id';
  static const String productEdit   = '/products/:id/edit';
  static const String categories    = '/products/categories';

  // ── Stock ─────────────────────────────────────────────────────────────────
  static const String stockList       = '/stock';
  static const String stockAdjustment = '/stock/adjustment';
  static const String stockLedger     = '/stock/ledger/:productId';

  // ── Cashier / Transaksi ───────────────────────────────────────────────────
  static const String cart        = '/cashier/cart';
  static const String payment     = '/cashier/payment';
  static const String receipt     = '/cashier/receipt/:transactionId';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/:id';

  // ── Reports ───────────────────────────────────────────────────────────────
  static const String reportSales      = '/reports/sales';
  static const String reportProfit     = '/reports/profit';
  static const String reportProducts   = '/reports/products';
  static const String reportCategories = '/reports/categories';

  // ── Settings ──────────────────────────────────────────────────────────────
  static const String staffList     = '/settings/staff';
  static const String staffAdd      = '/settings/staff/add';
  static const String staffEdit     = '/settings/staff/:id/edit';
  static const String taxDiscount   = '/settings/tax-discount';
  static const String printerConfig = '/settings/printer';
  static const String storeConfig   = '/settings/store';
  static const String backup        = '/settings/backup';
  static const String backupSettings = '/settings/backup/settings';
  static const String changePin     = '/settings/change-pin';
  static const String helpFaq       = '/settings/help-faq';
  static const String terms         = '/settings/terms';
  static const String privacy       = '/settings/privacy';
  static const String about         = '/settings/about';
}
