import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../models/category_model.dart';

/// Datasource kategori — akses langsung ke SQLite.
class CategoryLocalDatasource {
  const CategoryLocalDatasource();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<CategoryModel>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      DbConstants.tCategories,
      where: '${DbConstants.colIsDeleted} = 0',
      orderBy: '${DbConstants.colName} ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<CategoryModel> getById(String id) async {
    final db = await _db;
    final rows = await db.query(
      DbConstants.tCategories,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw NotFoundException('Kategori tidak ditemukan: $id');
    }
    return CategoryModel.fromMap(rows.first);
  }

  Future<CategoryModel> insert(CategoryModel model) async {
    final db = await _db;
    try {
      await db.insert(
        DbConstants.tCategories,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return model;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const ConstraintException('Nama kategori sudah digunakan');
      }
      throw DbException('Gagal menyimpan kategori', cause: e);
    }
  }

  Future<CategoryModel> update(CategoryModel model) async {
    final db = await _db;
    final count = await db.update(
      DbConstants.tCategories,
      model.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [model.id],
    );
    if (count == 0) {
      throw NotFoundException('Kategori tidak ditemukan: ${model.id}');
    }
    return model;
  }

  /// Reassign semua produk di kategori ini ke Uncategorized, lalu soft delete.
  Future<void> delete(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      // Reassign produk ke Uncategorized
      await txn.update(
        DbConstants.tProducts,
        {DbConstants.colCategoryId: DbConstants.defaultCategoryId},
        where: '${DbConstants.colCategoryId} = ? AND ${DbConstants.colIsDeleted} = 0',
        whereArgs: [id],
      );
      // Soft delete kategori
      await txn.update(
        DbConstants.tCategories,
        {
          DbConstants.colIsDeleted: 1,
          DbConstants.colUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
    });
  }
}
