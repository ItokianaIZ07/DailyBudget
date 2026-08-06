import 'package:sqflite/sqlite_api.dart';

class AppmetadataTable {
  static final String _tableName = "app_metadata";
  static final List<String> _columns = [
    "key TEXT",
    "value TEXT"
  ];

  static Future<void> createTable(Database database)  {
    String sql = 'CREATE TABLE IF NOT EXISTS $_tableName (';
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