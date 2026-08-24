import 'package:gestion_depenses/models/monthly_salary.dart';
import 'package:gestion_depenses/core/database/database_service.dart';

class MonthlySalaryRepository {
  static final _database = DatabaseService.instance.connexion!;

  static Future<MonthlySalary?> getByMonth(
    int month,
    int year,
  ) async {
    final results = await _database.query(
      'monthly_salary',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return MonthlySalary.fromMap(results.first);
  }

  static Future<int> insert(MonthlySalary salary) async {
    return await _database.insert(
      'monthly_salary',
      salary.toMap(),
    );
  }

  static Future<int> update(MonthlySalary salary) async {
    return await _database.update(
      'monthly_salary',
      salary.toMap(),
      where: 'id = ?',
      whereArgs: [salary.id],
    );
  }

  static Future<int> delete(int id) async {
    return await _database.delete(
      'monthly_salary',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}