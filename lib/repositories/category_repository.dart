import 'package:sqflite/sqflite.dart';
import 'package:gestion_depenses/core/database/tables/category_table.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/core/database/database_service.dart';

class CategoryRepository {
  static final String _tableName = CategoryTable.tableName;

  static Future<int> createCategory(Category category) {
    Database database = DatabaseService.instance.connexion!;

    return database.insert(_tableName, category.toMap());
  }

  static Future<List<Category>> getAllCategories() async {
    Database database = DatabaseService.instance.connexion!;
    List<Map<String, dynamic>> resultats = await database.query(_tableName);

    return resultats.map((map) => Category.fromMap(map)).toList();
  }

  static Future<int> updateCategory(Category category) {
    Database database = DatabaseService.instance.connexion!;

    return database.update(
      _tableName,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<int> deleteCategory(Category category){
    Database database = DatabaseService.instance.connexion!;

    return database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [category.id]
    );
  }

  static Future<Category?> getCategoryById(int id) async {
    Database database = DatabaseService.instance.connexion!;
    
    List<Map<String, dynamic>> resultats = await database.query(
      _tableName,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id]
    );

    return resultats.isNotEmpty ? Category.fromMap(resultats.first) : null;
  } 
}