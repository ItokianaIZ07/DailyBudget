import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/models/daily_budget.dart';
import 'package:gestion_depenses/core/database/database_service.dart';

class DailyBudgetRepository {
  static final _database = DatabaseService.instance.connexion!;
  static final String _tableName = "daily_budget";

  static Future<DailyBudget?> getByDate(DateTime date) async {
    final dateString = date.toDateString();

    final results = await _database.query(
      _tableName,
      where: 'date = ?',
      whereArgs: [dateString],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return DailyBudget.fromMap(results.first);
  }

  static Future<int> insert(DailyBudget budget) async {
    return await _database.insert(
      _tableName,
      budget.toMap(),
    );
  }

  static Future<int> update(DailyBudget budget) async {
    return await _database.update(
      _tableName,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  static Future<int> delete(int id) async {
    return await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<double> getSumBudgetByPeriod(int month, int year) async {
    String sql = "SELECT SUM(amount) as total FROM $_tableName WHERE month = ? AND year = ?";
    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [month, year]);
    double total = 0;
    
    for(var item in results){
      total += item["total"];
    }

    return total;
  }
}