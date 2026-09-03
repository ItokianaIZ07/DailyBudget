import 'package:gestion_depenses/exception/negative_amount_value.dart';
import 'package:gestion_depenses/models/monthly_salary.dart';
import 'package:gestion_depenses/repositories/monthly_salary_repository.dart';

class MonthlySalaryService {
  static Future<MonthlySalary?> getSalary(int month, int year) async {
    return await MonthlySalaryRepository.getByMonth(month, year);
  }

  static Future<int> saveSalary(MonthlySalary salary) async {
    if (salary.amount <= 0) {
      throw NegativeAmountValue(message: 'Le salaire doit être supérieur à 0.');
    }

    final existingSalary = await MonthlySalaryRepository.getByMonth(
      salary.month,
      salary.year,
    );

    if (existingSalary != null) {
      throw Exception('Un salaire est déjà enregistré pour ce mois.');
    }

    return await MonthlySalaryRepository.insert(salary);
  }

  static Future<int> updateSalary(MonthlySalary salary) async {
    if (salary.amount <= 0) {
      throw Exception('Le salaire doit être supérieur à 0.');
    }

    return await MonthlySalaryRepository.update(salary);
  }

  static Future<int> deleteSalary(int id) async {
    return await MonthlySalaryRepository.delete(id);
  }

  static Future<List<MonthlySalary>> getAllSalary() async{
    return await MonthlySalaryRepository.getAll();
  }
}
