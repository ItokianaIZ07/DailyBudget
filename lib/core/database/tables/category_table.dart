import 'package:sqflite/sqflite.dart';

class CategoryTable {
  static final String tableName = 'category';
  static final List<String> _columns = [
    'id INTEGER PRIMARY KEY AUTOINCREMENT',
    'name TEXT NOT NULL',
    'color TEXT',
  ];

  static Future<void> createTable(Database database) {
    String sql = 'CREATE TABLE IF NOT EXISTS $tableName (';
    for(int i = 0; i < _columns.length; i++) {
      sql += _columns[i];
      if (i < _columns.length - 1) {
        sql += ', ';
      }
    }
    sql += ')';

    return database.execute(sql);
  }
}
