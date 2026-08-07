import 'package:sqflite/sqflite.dart';

import 'package:gestion_depenses/core/database/database_service.dart';
import 'package:gestion_depenses/core/database/tables/limit_table.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/category_limit.dart';
import 'package:gestion_depenses/repositories/category_repository.dart';

class CategoryLimitRepository {
  static final String _tableName = LimitTable.tableName;
  static Database get _database => DatabaseService.instance.connexion!;

  static Future<int> createCategoryLimit(CategoryLimit categoryLimit) {
    return _database.insert(
      _tableName,
      categoryLimit.toMap(),
    );
  }

  static Future<List<CategoryLimit>> getAllCategoryLimits() async {
    final List<Map<String, dynamic>> results = await _database.query(_tableName);

    final List<CategoryLimit> limits = [];
    for (var map in results) {
      final Category? category =
          await CategoryRepository.getCategoryById(map['category_id']);

      if (category != null) {
        limits.add(CategoryLimit.fromMap(map, category));
      }
    }

    return limits;
  }

  static Future<CategoryLimit?> getCategoryLimitById(int id) async {
    final List<Map<String, dynamic>> results = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    final Category? category =
        await CategoryRepository.getCategoryById(results.first['category_id']);

    if (category == null) {
      return null;
    }

    return CategoryLimit.fromMap(results.first, category);
  }

  static Future<int> updateCategoryLimit(CategoryLimit categoryLimit) {
    return _database.update(
      _tableName,
      categoryLimit.toMap(),
      where: 'id = ?',
      whereArgs: [categoryLimit.id],
    );
  }

  static Future<int> deleteCategoryLimit(CategoryLimit categoryLimit) {
    return _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [categoryLimit.id],
    );
  }

  static Future<int> deletePerCategory(Category category) {
    return _database.delete(
      _tableName,
      where: 'category_id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<CategoryLimit?> getLimitByCategory(Category category) async {
    final List<Map<String, dynamic>> results = await _database.query(
      _tableName,
      where: 'category_id = ?',
      whereArgs: [category.id],
      limit: 1
    );

    return results.isNotEmpty ? CategoryLimit.fromMap(results.first, category) : null;
  }
}
