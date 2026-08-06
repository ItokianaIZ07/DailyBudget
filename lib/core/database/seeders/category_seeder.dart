import 'package:sqflite/sqflite.dart';

class CategorySeeder {
  static Future<void> initialize(Database database) async {
    List<Map<String, dynamic>> resultats = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM category',
    );

    int count = resultats.first['total'] as int;

    if (count > 0) {
      return;
    }

    // Catégories par défaut
    List<Map<String, dynamic>> categories = [
      {
        'name': 'Alimentation',
        'color': '#4CAF50',
      },
      {
        'name': 'Transport',
        'color': '#2196F3',
      },
      {
        'name': 'Loisirs',
        'color': '#9C27B0',
      },
    ];

    for (Map<String, dynamic> category in categories) {
      await database.insert(
        'category',
        category,
      );
    }

    List<Map<String, dynamic>> resultatsTest = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM category',
    );

    int countTest = resultats.first['total'] as int;
    print(countTest);
  }
}