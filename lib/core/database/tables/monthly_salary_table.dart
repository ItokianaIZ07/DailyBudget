import 'package:sqflite/sqflite.dart';

class MonthlySalaryTable {
  static final String tableName = 'monthly_salary';
  static final List<String> _columns = [
    'id INTEGER PRIMARY KEY AUTOINCREMENT',
    'month INTEGER NOT NULL',
    'year INTEGER NOT NULL',
    'amount REAL NOT NULL',
    'UNIQUE(month, year)',
    'CHECK(month BETWEEN 1 AND 12)',
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
