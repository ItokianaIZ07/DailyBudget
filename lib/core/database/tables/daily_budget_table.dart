import 'package:sqflite/sqflite.dart';

class DailyBudgetTable {
  static final String tableName = "daily_budget";
  static final List<String> _columns = [
    'id INTEGER PRIMARY KEY AUTOINCREMENT',
    'date TEXT NOT NULL',
    'amount REAL NOT NULL',
    'notification_sent INTEGER DEFAULT 0',
    'UNIQUE(date)',
    'CHECK(amount >= 0)',
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
