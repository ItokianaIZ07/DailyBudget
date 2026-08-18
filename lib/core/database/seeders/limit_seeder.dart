import 'package:sqflite/sqflite.dart';

class LimitSeeder {
  static Future<void> initialize(Database database) async {
    final List<Map<String, dynamic>> categories = await database.query(
      'category',
      columns: ['id', 'name'],
    );

    for (var category in categories) {
      double amount = 0.0;

      switch (category['name']) {
        case 'Alimentation':
          amount = 400000.0;
          break;

        case 'Transport':
          amount = 1000000.0;
          break;

        case 'Loisirs':
          amount = 120000.0;
          break;
      }

      await database.insert(
        'category_limit',
        {
          'amount': amount,
          'category_id': category['id'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}