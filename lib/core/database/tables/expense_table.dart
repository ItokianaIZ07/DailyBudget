import 'package:sqflite/sqflite.dart';

class ExpenseTable {
  static final String tableName = 'expenses';
  static final List<String> _columns = [
    'id INTEGER PRIMARY KEY AUTOINCREMENT',
    'amount REAL NOT NULL',
    'description TEXT',
    'category_id INTEGER NOT NULL',
    'date TEXT NOT NULL',
    'FOREIGN KEY(category_id) REFERENCES category(id)'
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