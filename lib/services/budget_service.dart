import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/models/daily_budget.dart';
import 'package:gestion_depenses/models/daily_budget_situation.dart';
import 'package:gestion_depenses/models/monthly_budget_situation.dart';
import 'package:gestion_depenses/models/monthly_salary.dart';
import 'package:gestion_depenses/services/daily_budget_service.dart';
import 'package:gestion_depenses/services/expense_service.dart';
import 'package:gestion_depenses/services/monthly_salary_service.dart';

class BudgetService {
  static Future<DailyBudgetSituation> getDailySituation(DateTime date) async {
    DailyBudget? todayBudget = await DailyBudgetService.getBudgetByDate(date);
    double todayTotalExpense = await ExpenseService.calculateSumExpenseByDate(
      date,
    );
    if (todayBudget == null) {
      throw Exception(
        "Aucun budget n'a été fixé pour la date: ${date.toDateString()}",
      );
    }

    double consommation = todayBudget.amount == 0
        ? 0
        : (todayTotalExpense / todayBudget.amount) * 100;

    double result = todayBudget.amount - todayTotalExpense;

    return DailyBudgetSituation(
      budget: todayBudget.amount,
      spent: todayTotalExpense,
      percentage: consommation,
      remaining: result,
    );
  }

  static Future<MonthlyBudgetSituation> getMonthlySituation(
    int month,
    int year,
  ) async {
    MonthlySalary? monthlySalary = await MonthlySalaryService.getSalary(
      month,
      year,
    );
    if (monthlySalary == null) {
      throw Exception("Aucune salaire n'a été fixé pour ce mois: $month");
    }

    double sumBudgetPlanified =
        await DailyBudgetService.calculateSumBudgetByPeriod(month, year);
    double realExpenseOfTHeMonth = await ExpenseService.getExpenseOfTheMonth(
      month,
      year,
    );
    double availableBudget = monthlySalary.amount - realExpenseOfTHeMonth;
    double realRemainingMoney = monthlySalary.amount - realExpenseOfTHeMonth;

    return MonthlyBudgetSituation(
      salary: monthlySalary.amount,
      plannedBudget: sumBudgetPlanified,
      availableBudget: availableBudget,
      remaining: realRemainingMoney,
      spent: realExpenseOfTHeMonth,
    );
  }
}
