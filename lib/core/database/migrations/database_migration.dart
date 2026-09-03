import 'package:gestion_depenses/core/database/tables/daily_budget_table.dart';
import 'package:gestion_depenses/core/database/tables/monthly_salary_table.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseMigration {
  static Future<void> upgradeToVersion2(Database db) async {
    await MonthlySalaryTable.createTable(db);

    await DailyBudgetTable.createTable(db);
  }
}
