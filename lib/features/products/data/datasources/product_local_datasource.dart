import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/sku_generator.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

/// Datasource produk — akses langsung ke SQLite.
class ProductLocalDatasource {
  const ProductLocalDatasource();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  static const String _joinQuery = '''
    SELECT p.*, c.${DbConstants.colName} AS category_name
    FROM ${DbConstants.tProducts} p
    LEFT JOIN ${DbConstants.tCategories} c
      ON p.${DbConstants.colCategoryId} = c.${DbConstants.colId}
  ''';

  Future<List<ProductModel>> getAll() async {
    final db = await _db;
    final rows = await db.rawQuery(
      '$_joinQuery WHERE p.${DbConstants.colIsDeleted} = 0 ORDER BY p.${DbConstants.colName} ASC',
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> getActive() async {
    final db = await _db;
    final rows = await db.rawQuery(
      '$_joinQuery WHERE p.${DbConstants.colIsDeleted} = 0 AND p.${DbConstants.colIsActive} = 1 ORDER BY p.${DbConstants.colName} ASC',
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<ProductModel> getById(String id) async {
    final db = await _db;
    final rows = await db.rawQuery(
      '$_joinQuery WHERE p.${DbConstants.colId} = ? LIMIT 1',
      [id],
    );
    if (rows.isEmpty) {
      throw NotFoundException('Produk tidak ditemukan: $id');
    }
    return ProductModel.fromMap(rows.first);
  }

  Future<List<ProductModel>> search({
    required String query,
    String? categoryId,
  }) async {
    final db = await _db;
    final args = <dynamic>[];
    final conditions = ['p.${DbConstants.colIsDeleted} = 0'];

    if (query.isNotEmpty) {
      conditions.add(
        '(p.${DbConstants.colName} LIKE ? OR p.${DbConstants.colSku} LIKE ? OR p.${DbConstants.colBarcode} LIKE ?)',
      );
      final pattern = '%$query%';
      args.addAll([pattern, pattern, pattern]);
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      conditions.add('p.${DbConstants.colCategoryId} = ?');
      args.add(categoryId);
    }

    final where = conditions.join(' AND ');
    final rows = await db.rawQuery(
      '$_joinQuery WHERE $where ORDER BY p.${DbConstants.colName} ASC',
      args.isEmpty ? null : args,
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<ProductModel> insert(ProductModel model) async {
    final db = await _db;
    try {
      await db.transaction((txn) async {
        // Insert produk
        await txn.insert(
          DbConstants.tProducts,
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
        // Buat record stok awal = 0
        await txn.insert(DbConstants.tStocks, {
          DbConstants.colId: UuidGenerator.generate(),
          DbConstants.colProductId: model.id,
          DbConstants.colCurrentStock: 0.0,
          DbConstants.colMinimumStock: 0.0,
          DbConstants.colTrackStock: 1,
        });
      });
      return model;
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw const ConstraintException('SKU atau barcode sudah digunakan');
      }
      throw DbException('Gagal menyimpan produk', cause: error);
    }
  }

  Future<ProductModel> update(ProductModel model) async {
    final db = await _db;
    final count = await db.update(
      DbConstants.tProducts,
      model.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [model.id],
    );
    if (count == 0) {
      throw NotFoundException('Produk tidak ditemukan: ${model.id}');
    }
    return model;
  }

  Future<ProductModel> toggleActive(String id) async {
    final db = await _db;
    final current = await getById(id);
    final now = DateTime.now().toIso8601String();
    await db.update(
      DbConstants.tProducts,
      {
        DbConstants.colIsActive: current.isActive ? 0 : 1,
        DbConstants.colUpdatedAt: now,
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
    return ProductModel.fromMap({
      ...current.toMap(),
      'is_active': current.isActive ? 0 : 1,
      'updated_at': now,
      'category_name': current.categoryName,
    });
  }

  Future<void> softDelete(String id) async {
    final db = await _db;
    await db.update(
      DbConstants.tProducts,
      {
        DbConstants.colIsDeleted: 1,
        DbConstants.colIsActive: 0,
        DbConstants.colUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<bool> checkSkuExists(String sku, {required String excludeId}) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.tProducts} '
      'WHERE ${DbConstants.colSku} = ? AND ${DbConstants.colId} != ? AND ${DbConstants.colIsDeleted} = 0',
      [sku, excludeId],
    );
    return (result.first['count'] as int) > 0;
  }

  Future<bool> checkBarcodeExists(
    String barcode, {
    required String excludeId,
  }) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.tProducts} '
      'WHERE ${DbConstants.colBarcode} = ? AND ${DbConstants.colId} != ? AND ${DbConstants.colIsDeleted} = 0',
      [barcode, excludeId],
    );
    return (result.first['count'] as int) > 0;
  }

  /// Import CSV — format: name,sku,selling_price,unit + opsional cost_price,category_name,barcode
  Future<ImportResult> importCsv(String csvContent) async {
    final db = await _db;
    final rows = const CsvToListConverter().convert(csvContent);
    if (rows.isEmpty) {
      return const ImportResult(success: 0, skipped: 0, errors: []);
    }

    // Skip baris header
    final dataRows = rows.skip(1).toList();
    if (dataRows.isEmpty) {
      return const ImportResult(success: 0, skipped: 0, errors: []);
    }

    var success = 0;
    var skipped = 0;
    final errors = <String>[];

    for (var i = 0; i < dataRows.length; i++) {
      final row = dataRows[i];
      final rowNum = i + 2; // +2 karena skip header (baris 1)

      try {
        if (row.length < 4) {
          errors.add('Baris $rowNum: kolom tidak lengkap (min: name, sku, selling_price, unit)');
          skipped++;
          continue;
        }

        final name = row[0].toString().trim();
        var sku = row[1].toString().trim().toUpperCase();
        final sellingPriceStr = row[2].toString().trim();
        final unit = row[3].toString().trim();
        final costPriceStr = row.length > 4 ? row[4].toString().trim() : '';
        final categoryName = row.length > 5 ? row[5].toString().trim() : '';
        final barcode = row.length > 6 ? row[6].toString().trim() : '';

        if (name.isEmpty) {
          errors.add('Baris $rowNum: nama produk kosong');
          skipped++;
          continue;
        }

        final sellingPrice = double.tryParse(sellingPriceStr);
        if (sellingPrice == null) {
          errors.add('Baris $rowNum: harga jual tidak valid ("$sellingPriceStr")');
          skipped++;
          continue;
        }

        // Auto-generate SKU jika kosong
        if (sku.isEmpty) {
          sku = SkuGenerator.generate(name);
        }

        // Cek SKU sudah ada — skip (jangan update)
        final skuExists = await checkSkuExists(sku, excludeId: '');
        if (skuExists) {
          errors.add('Baris $rowNum: SKU "$sku" sudah ada, dilewati');
          skipped++;
          continue;
        }

        // Resolve category ID
        String catId = DbConstants.defaultCategoryId;
        if (categoryName.isNotEmpty) {
          final catRows = await db.query(
            DbConstants.tCategories,
            where: 'LOWER(${DbConstants.colName}) = LOWER(?) AND ${DbConstants.colIsDeleted} = 0',
            whereArgs: [categoryName],
            limit: 1,
          );
          if (catRows.isNotEmpty) {
            catId = catRows.first[DbConstants.colId] as String;
          } else {
            // Buat kategori baru
            final newCatId = UuidGenerator.generate();
            final now = DateTime.now().toIso8601String();
            await db.insert(DbConstants.tCategories, {
              DbConstants.colId: newCatId,
              DbConstants.colName: categoryName,
              DbConstants.colColorHex: null,
              DbConstants.colIsDeleted: 0,
              DbConstants.colCreatedAt: now,
              DbConstants.colUpdatedAt: now,
            });
            catId = newCatId;
          }
        }

        final costPrice =
            costPriceStr.isNotEmpty ? double.tryParse(costPriceStr) : null;
        final productId = UuidGenerator.generate();
        final now = DateTime.now();

        await db.transaction((txn) async {
          await txn.insert(DbConstants.tProducts, {
            DbConstants.colId: productId,
            DbConstants.colName: name,
            DbConstants.colSku: sku,
            'selling_price': sellingPrice,
            'cost_price': costPrice,
            DbConstants.colCategoryId: catId,
            DbConstants.colUnit: unit.isEmpty ? 'pcs' : unit,
            DbConstants.colBarcode: barcode.isEmpty ? null : barcode,
            'image_path': null,
            DbConstants.colIsActive: 1,
            DbConstants.colIsDeleted: 0,
            DbConstants.colCreatedAt: now.toIso8601String(),
            DbConstants.colUpdatedAt: now.toIso8601String(),
          });
          // Buat record stok
          await txn.insert(DbConstants.tStocks, {
            DbConstants.colId: UuidGenerator.generate(),
            DbConstants.colProductId: productId,
            DbConstants.colCurrentStock: 0.0,
            DbConstants.colMinimumStock: 0.0,
            DbConstants.colTrackStock: 1,
            DbConstants.colCreatedAt: now.toIso8601String(),
            DbConstants.colUpdatedAt: now.toIso8601String(),
          });
        });
        success++;
      } catch (error) {
        errors.add('Baris $rowNum: error — $error');
        skipped++;
      }
    }

    return ImportResult(
      success: success,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Export semua produk aktif ke CSV string.
  Future<String> exportCsv() async {
    final products = await getActive();
    final header = [
      'name',
      'sku',
      'selling_price',
      'cost_price',
      'category_name',
      'unit',
      'barcode',
    ];
    final rows = [
      header,
      ...products.map(
        (p) => [
          p.name,
          p.sku,
          p.sellingPrice,
          p.costPrice ?? '',
          p.categoryName ?? '',
          p.unit,
          p.barcode ?? '',
        ],
      ),
    ];
    return const ListToCsvConverter().convert(rows);
  }
}
