import 'package:gestion_depenses/exception/daily_budget_not_found.dart';
import 'package:gestion_depenses/exception/negative_amount_value.dart';
import 'package:gestion_depenses/models/daily_budget.dart';
import 'package:gestion_depenses/repositories/daily_budget_repository.dart';

class DailyBudgetService {
  static Future<DailyBudget?> getBudgetByDate(DateTime date) async {
    final budget =  await DailyBudgetRepository.getByDate(date);
    if(budget == null){
      throw DailyBudgetNotFound(date);
    }
    return budget;
  }

  static Future<int> saveBudget(DailyBudget budget) async {
    if (budget.amount <= 0) {
      throw NegativeAmountValue(message: 'Le budget doit être supérieur à 0.');
    }

    final existingBudget = await DailyBudgetRepository.getByDate(budget.date);

    if (existingBudget != null) {
      throw Exception('Un budget existe déjà pour cette journée.');
    }

    return await DailyBudgetRepository.insert(budget);
  }

  static Future<int> updateBudget(DailyBudget budget) async {
    if (budget.amount <= 0) {
      throw Exception('Le budget doit être supérieur à 0.');
    }

    return await DailyBudgetRepository.update(budget);
  }

  static Future<int> deleteBudget(int id) async {
    return await DailyBudgetRepository.delete(id);
  }

  static Future<double> calculateSumBudgetByPeriod(int month, int year) async{
    return await DailyBudgetRepository.getSumBudgetByPeriod(month, year);
  }
}
