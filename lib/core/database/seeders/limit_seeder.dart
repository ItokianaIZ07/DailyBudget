import 'package:sqflite/sqflite.dart';

class LimitSeeder {
  static Future<void> initialize(Database database) async {
    List<Map<String, dynamic>> resultats = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM category_limit',
    );

    int count = resultats.first['total'] as int;

    if (count > 0) {
      return;
    }

    final List<Map<String, dynamic>> categories = await database.query(
      'category',
      columns: ['id', 'name'],
    );

    Map<String, int> categoryIds = {
      for (var category in categories)
        category['name'] as String: category['id'] as int
    };

    final List<Map<String, dynamic>> limits = [];

    if (categoryIds.containsKey('Alimentation')) {
      limits.add({
        'amount': 400.0,
        'category_id': categoryIds['Alimentation'],
      });
    }
    if (categoryIds.containsKey('Transport')) {
      limits.add({
        'amount': 150.0,
        'category_id': categoryIds['Transport'],
      });
    }
    if (categoryIds.containsKey('Loisirs')) {
      limits.add({
        'amount': 120.0,
        'category_id': categoryIds['Loisirs'],
      });
    }

    for (var limit in limits) {
      await database.insert('category_limit', limit);
    }
  }
}
