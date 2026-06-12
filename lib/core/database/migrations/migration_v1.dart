import 'package:sqflite/sqflite.dart';

/// Migration V1 — Membuat semua 12 tabel saat pertama kali DB dibuka.
/// Urutan CREATE TABLE WAJIB diikuti karena ada foreign key dependencies.
class MigrationV1 {
  MigrationV1._();

  /// Jalankan semua DDL dalam satu batch.
  static Future<void> migrate(Batch batch) async {
    _createCategories(batch);
    _createProducts(batch);
    _createStocks(batch);
    _createStockLedger(batch);
    _createStaffs(batch);
    _createTaxConfig(batch);
    _createDiscountPresets(batch);
    _createTransactions(batch);
    _createTransactionItems(batch);
    _createPrinters(batch);
    _createStoreConfig(batch);
    _createBackupHistory(batch);
  }

  // ── 1. categories ──────────────────────────────────────────────────────────
  static void _createCategories(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id          TEXT PRIMARY KEY NOT NULL,
        name        TEXT NOT NULL,
        color_hex   TEXT,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL
      )
    ''');

    // Seed data — kategori default yang tidak bisa dihapus
    batch.execute('''
      INSERT OR IGNORE INTO categories (id, name, color_hex, is_deleted, created_at, updated_at)
      VALUES ('cat-uncategorized', 'Uncategorized', '#9CA3AF', 0, datetime('now'), datetime('now'))
    ''');
  }

  // ── 2. products ────────────────────────────────────────────────────────────
  static void _createProducts(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id            TEXT PRIMARY KEY NOT NULL,
        name          TEXT NOT NULL,
        sku           TEXT NOT NULL UNIQUE,
        selling_price REAL NOT NULL CHECK(selling_price >= 0),
        cost_price    REAL CHECK(cost_price >= 0),
        category_id   TEXT NOT NULL DEFAULT 'cat-uncategorized'
                      REFERENCES categories(id),
        unit          TEXT NOT NULL DEFAULT 'pcs',
        barcode       TEXT UNIQUE,
        image_path    TEXT,
        is_active     INTEGER NOT NULL DEFAULT 1,
        is_deleted    INTEGER NOT NULL DEFAULT 0,
        created_at    TEXT NOT NULL,
        updated_at    TEXT NOT NULL
      )
    ''');

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active, is_deleted)',
    );
  }

  // ── 3. stocks ──────────────────────────────────────────────────────────────
  static void _createStocks(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS stocks (
        id            TEXT PRIMARY KEY NOT NULL,
        product_id    TEXT NOT NULL UNIQUE REFERENCES products(id),
        current_stock REAL NOT NULL DEFAULT 0,
        minimum_stock REAL NOT NULL DEFAULT 0 CHECK(minimum_stock >= 0),
        track_stock   INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  // ── 4. stock_ledger (append-only — JANGAN UPDATE/DELETE) ──────────────────
  static void _createStockLedger(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS stock_ledger (
        id             TEXT PRIMARY KEY NOT NULL,
        product_id     TEXT NOT NULL REFERENCES products(id),
        change_amount  REAL NOT NULL,
        stock_after    REAL NOT NULL,
        reason         TEXT NOT NULL
                       CHECK(reason IN ('SALE','RESTOCK','ADJUSTMENT','VOID')),
        reference_id   TEXT,
        note           TEXT,
        staff_id       TEXT REFERENCES staffs(id),
        created_at     TEXT NOT NULL
      )
    ''');

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_ledger_product ON stock_ledger(product_id, created_at)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_ledger_reference ON stock_ledger(reference_id)',
    );
  }

  // ── 5. staffs ──────────────────────────────────────────────────────────────
  static void _createStaffs(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS staffs (
        id            TEXT PRIMARY KEY NOT NULL,
        name          TEXT NOT NULL,
        role          TEXT NOT NULL CHECK(role IN ('OWNER','ADMIN','KASIR')),
        pin_hash      TEXT NOT NULL,
        is_active     INTEGER NOT NULL DEFAULT 1,
        avatar_path   TEXT,
        created_at    TEXT NOT NULL,
        last_login_at TEXT
      )
    ''');

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_staffs_role ON staffs(role, is_active)',
    );
  }

  // ── 6. tax_config ──────────────────────────────────────────────────────────
  static void _createTaxConfig(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS tax_config (
        id           TEXT PRIMARY KEY NOT NULL,
        name         TEXT NOT NULL,
        rate         REAL NOT NULL CHECK(rate >= 0 AND rate <= 100),
        is_inclusive INTEGER NOT NULL DEFAULT 0,
        is_active    INTEGER NOT NULL DEFAULT 0,
        created_at   TEXT NOT NULL
      )
    ''');
  }

  // ── 7. discount_presets ────────────────────────────────────────────────────
  static void _createDiscountPresets(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS discount_presets (
        id         TEXT PRIMARY KEY NOT NULL,
        name       TEXT NOT NULL,
        type       TEXT NOT NULL CHECK(type IN ('PERCENTAGE','NOMINAL')),
        value      REAL NOT NULL CHECK(value >= 0),
        is_active  INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ── 8. transactions ────────────────────────────────────────────────────────
  static void _createTransactions(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id                TEXT PRIMARY KEY NOT NULL,
        invoice_number    TEXT NOT NULL UNIQUE,
        staff_id          TEXT REFERENCES staffs(id),
        subtotal          REAL NOT NULL,
        discount_type     TEXT CHECK(discount_type IN ('PERCENTAGE','NOMINAL')),
        discount_value    REAL,
        discount_amount   REAL NOT NULL DEFAULT 0,
        tax_rate          REAL NOT NULL DEFAULT 0,
        tax_is_inclusive  INTEGER NOT NULL DEFAULT 0,
        tax_amount        REAL NOT NULL DEFAULT 0,
        total             REAL NOT NULL,
        payment_method    TEXT NOT NULL
                          CHECK(payment_method IN ('CASH','TRANSFER','QRIS','DEBIT','CREDIT')),
        payment_received  REAL,
        change_amount     REAL,
        status            TEXT NOT NULL DEFAULT 'COMPLETED'
                          CHECK(status IN ('COMPLETED','VOIDED')),
        voided_at         TEXT,
        voided_by         TEXT REFERENCES staffs(id),
        void_reason       TEXT,
        note              TEXT,
        created_at        TEXT NOT NULL
      )
    ''');

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_txn_created ON transactions(created_at)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_txn_status ON transactions(status)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_txn_staff ON transactions(staff_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_txn_invoice ON transactions(invoice_number)',
    );
  }

  // ── 9. transaction_items ───────────────────────────────────────────────────
  static void _createTransactionItems(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS transaction_items (
        id                   TEXT PRIMARY KEY NOT NULL,
        transaction_id       TEXT NOT NULL REFERENCES transactions(id),
        product_id           TEXT NOT NULL REFERENCES products(id),
        product_name         TEXT NOT NULL,
        product_sku          TEXT NOT NULL,
        selling_price        REAL NOT NULL,
        cost_price           REAL,
        quantity             REAL NOT NULL CHECK(quantity > 0),
        item_discount_type   TEXT CHECK(item_discount_type IN ('PERCENTAGE','NOMINAL')),
        item_discount_value  REAL,
        item_discount_amount REAL NOT NULL DEFAULT 0,
        line_total           REAL NOT NULL
      )
    ''');

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_txn_items_txn ON transaction_items(transaction_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_txn_items_product ON transaction_items(product_id)',
    );
  }

  // ── 10. printers ───────────────────────────────────────────────────────────
  static void _createPrinters(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS printers (
        id          TEXT PRIMARY KEY NOT NULL,
        name        TEXT NOT NULL,
        type        TEXT NOT NULL CHECK(type IN ('BLUETOOTH','WIFI')),
        address     TEXT NOT NULL,
        paper_width INTEGER NOT NULL DEFAULT 80 CHECK(paper_width IN (58, 80)),
        is_default  INTEGER NOT NULL DEFAULT 0,
        is_active   INTEGER NOT NULL DEFAULT 1,
        created_at  TEXT NOT NULL
      )
    ''');
  }

  // ── 11. store_config (singleton, id = 'store-config') ─────────────────────
  static void _createStoreConfig(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS store_config (
        id             TEXT PRIMARY KEY NOT NULL DEFAULT 'store-config',
        store_name     TEXT NOT NULL DEFAULT 'Toko Saya',
        store_address  TEXT,
        store_phone    TEXT,
        receipt_footer TEXT,
        logo_path      TEXT,
        auto_print     INTEGER NOT NULL DEFAULT 1,
        updated_at     TEXT NOT NULL
      )
    ''');

    // Seed data — satu baris singleton
    batch.execute('''
      INSERT OR IGNORE INTO store_config (id, store_name, auto_print, updated_at)
      VALUES ('store-config', 'Toko Saya', 1, datetime('now'))
    ''');
  }

  // ── 12. backup_history ─────────────────────────────────────────────────────
  static void _createBackupHistory(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS backup_history (
        id                 TEXT PRIMARY KEY NOT NULL,
        file_name          TEXT NOT NULL,
        file_path          TEXT NOT NULL,
        file_size_bytes    INTEGER NOT NULL,
        app_version        TEXT NOT NULL,
        backup_schema_ver  INTEGER NOT NULL,
        db_checksum        TEXT NOT NULL,
        total_transactions INTEGER NOT NULL,
        created_at         TEXT NOT NULL
      )
    ''');
  }
}
