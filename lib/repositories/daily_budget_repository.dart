import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/models/daily_budget.dart';
import 'package:gestion_depenses/core/database/database_service.dart';

class DailyBudgetRepository {
  static final _database = DatabaseService.instance.connexion!;

  static Future<DailyBudget?> getByDate(DateTime date) async {
    final dateString = date.toDateString();

    final results = await _database.query(
      'daily_budget',
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
      'daily_budget',
      budget.toMap(),
    );
  }

  static Future<int> update(DailyBudget budget) async {
    return await _database.update(
      'daily_budget',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  static Future<int> delete(int id) async {
    return await _database.delete(
      'daily_budget',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}