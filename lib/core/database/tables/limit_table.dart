import 'package:sqflite/sqflite.dart';

class LimitTable {
  static final String tableName = 'category_limit';
  static final List<String> _columns = [
    'id INTEGER PRIMARY KEY AUTOINCREMENT',
    'amount REAL NOT NULL',
    'category_id INTEGER NOT NULL UNIQUE',
    'FOREIGN KEY(category_id) REFERENCES category(id)'
  ];

  static Future<void> createTable(Database database) {
    String sql = 'CREATE TABLE IF NOT EXISTS $tableName (';
    for (int i = 0; i < _columns.length; i++) {
      sql += _columns[i];
      if (i < _columns.length - 1) {
        sql += ', ';
      }
    }
    sql += ')';

    return database.execute(sql);
  }
}