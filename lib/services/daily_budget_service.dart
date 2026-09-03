import 'package:gestion_depenses/core/services/notification_service.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/exception/daily_budget_not_found.dart';
import 'package:gestion_depenses/exception/negative_amount_value.dart';
import 'package:gestion_depenses/models/daily_budget.dart';
import 'package:gestion_depenses/models/monthly_salary.dart';
import 'package:gestion_depenses/repositories/daily_budget_repository.dart';
import 'package:gestion_depenses/services/monthly_salary_service.dart';

class DailyBudgetService {
  static Future<DailyBudget?> getBudgetByDate(DateTime date) async {
    final budget = await DailyBudgetRepository.getByDate(date);
    if (budget == null) {
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

    int insertedBudget = await DailyBudgetRepository.insert(budget);
    await _checkMonthlyBudgetLimit();

    return insertedBudget;
  }

  static Future<int> updateBudget(DailyBudget budget) async {
    if (budget.amount <= 0) {
      throw Exception('Le budget doit être supérieur à 0.');
    }

    int updatedBudget = await DailyBudgetRepository.update(budget);
    await _checkMonthlyBudgetLimit();

    return updatedBudget;
  }

  static Future<int> deleteBudget(int id) async {
    return await DailyBudgetRepository.delete(id);
  }

  static Future<double> calculateSumBudgetByPeriod(int month, int year) async {
    return await DailyBudgetRepository.getSumBudgetByPeriod(month, year);
  }

  static Future<void> changeNotificationState(int id, int state) async {
    await DailyBudgetRepository.changeNotificationState(id, state: state);
  }

  static Future<List<DailyBudget>> getAllPlanifiedBudget({
    required int limit,
    required int offset,
  }) async {
    return await DailyBudgetRepository.getPerStack(
      limit: limit,
      offset: offset,
    );
  }

  static Future<void> _checkMonthlyBudgetLimit() async {
    int month = DatetimeUtil.getNowMonth();
    int year = DatetimeUtil.getNowYear();

    double totalBudget = await DailyBudgetRepository.getSumBudgetByPeriod(
      month,
      year,
    );
    MonthlySalary? salary = await MonthlySalaryService.getSalary(month, year);
    if (salary == null) {
      return;
    }
    if (totalBudget > salary.amount) {
      await NotificationService.instance.showNotification(
        title: "SpendWise Alert",
        body:
            "Attention! Le total de budget que vous avez planifié"
            " ce mois ci dépasse votre salaire qui est de "
            " ${CurrencyUtil.getFormater().format(salary.amount)}",
      );
    }
  }
}
