// lib/core/constants/db_constants.dart
// Semua nama tabel dan kolom sebagai const String
// JANGAN hardcode string tabel/kolom di file lain — selalu pakai konstanta ini

/// Konstanta nama tabel dan kolom database SQLite.
/// Dipakai di semua datasource, JANGAN hardcode string langsung.
class DbConstants {
  DbConstants._();

  // ── Tables ────────────────────────────────────────────────────────────────
  static const String tCategories      = 'categories';
  static const String tProducts        = 'products';
  static const String tStocks          = 'stocks';
  static const String tStockLedger     = 'stock_ledger';
  static const String tStaffs          = 'staffs';
  static const String tTaxConfig       = 'tax_config';
  static const String tDiscountPresets = 'discount_presets';
  static const String tTransactions    = 'transactions';
  static const String tTxnItems        = 'transaction_items';
  static const String tPrinters        = 'printers';
  static const String tStoreConfig     = 'store_config';
  static const String tBackupHistory   = 'backup_history';

  // ── Common columns ────────────────────────────────────────────────────────
  static const String colId        = 'id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colIsActive  = 'is_active';
  static const String colIsDeleted = 'is_deleted';
  static const String colName      = 'name';
  static const String colStaffId   = 'staff_id';
  static const String colRate        = 'rate';
  static const String colIsInclusive = 'is_inclusive';
  static const String colValue       = 'value';

  // ── categories ────────────────────────────────────────────────────────────
  static const String colColorHex = 'color_hex';

  /// ID kategori default (tidak bisa dihapus)
  static const String defaultCategoryId = 'cat-uncategorized';

  // ── products ──────────────────────────────────────────────────────────────
  static const String colSku          = 'sku';
  static const String colSellingPrice = 'selling_price';
  static const String colCostPrice    = 'cost_price';
  static const String colCategoryId   = 'category_id';
  static const String colUnit         = 'unit';
  static const String colBarcode      = 'barcode';
  static const String colImagePath    = 'image_path';

  // ── stocks ────────────────────────────────────────────────────────────────
  static const String colProductId    = 'product_id';
  static const String colCurrentStock = 'current_stock';
  static const String colMinimumStock = 'minimum_stock';
  static const String colTrackStock   = 'track_stock';

  // ── stock_ledger ──────────────────────────────────────────────────────────
  static const String colChangeAmount = 'change_amount';
  static const String colStockAfter   = 'stock_after';
  static const String colReason       = 'reason';
  static const String colReferenceId  = 'reference_id';
  static const String colNote         = 'note';

  // ── staffs ────────────────────────────────────────────────────────────────
  static const String colRole        = 'role';
  static const String colPinHash     = 'pin_hash';
  static const String colAvatarPath  = 'avatar_path';
  static const String colLastLoginAt = 'last_login_at';

  // ── transactions ──────────────────────────────────────────────────────────
  static const String colInvoiceNumber   = 'invoice_number';
  static const String colSubtotal        = 'subtotal';
  static const String colDiscountType    = 'discount_type';
  static const String colDiscountValue   = 'discount_value';
  static const String colDiscountAmount  = 'discount_amount';
  static const String colTaxRate         = 'tax_rate';
  static const String colTaxIsInclusive  = 'tax_is_inclusive';
  static const String colTaxAmount       = 'tax_amount';
  static const String colTotal           = 'total';
  static const String colPaymentMethod   = 'payment_method';
  static const String colPaymentReceived = 'payment_received';
  static const String colChangeAmt       = 'change_amount';
  static const String colStatus          = 'status';
  static const String colVoidedAt        = 'voided_at';
  static const String colVoidedBy        = 'voided_by';
  static const String colVoidReason      = 'void_reason';

  // ── transaction_items ─────────────────────────────────────────────────────
  static const String colTransactionId      = 'transaction_id';
  static const String colProductName        = 'product_name';
  static const String colProductSku         = 'product_sku';
  static const String colQuantity           = 'quantity';
  static const String colItemDiscountType   = 'item_discount_type';
  static const String colItemDiscountValue  = 'item_discount_value';
  static const String colItemDiscountAmount = 'item_discount_amount';
  static const String colLineTotal          = 'line_total';

  // ── printers ──────────────────────────────────────────────────────────────
  static const String colType       = 'type';
  static const String colAddress    = 'address';
  static const String colPaperWidth = 'paper_width';
  static const String colIsDefault  = 'is_default';

  // ── store_config ──────────────────────────────────────────────────────────
  static const String colStoreName     = 'store_name';
  static const String colStoreAddress  = 'store_address';
  static const String colStorePhone    = 'store_phone';
  static const String colReceiptFooter = 'receipt_footer';
  static const String colLogoPath      = 'logo_path';
  static const String colAutoPrint     = 'auto_print';

  /// ID singleton store_config (selalu satu baris)
  static const String storeConfigId = 'store-config';

  // ── backup_history ────────────────────────────────────────────────────────
  static const String colFileName        = 'file_name';
  static const String colFilePath        = 'file_path';
  static const String colFileSizeBytes   = 'file_size_bytes';
  static const String colAppVersion      = 'app_version';
  static const String colBackupSchemaVer = 'backup_schema_ver';
  static const String colDbChecksum      = 'db_checksum';
  static const String colTotalTxn        = 'total_transactions';
}
