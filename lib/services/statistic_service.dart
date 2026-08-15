import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/models/expense_category.dart';
import 'package:gestion_depenses/repositories/expense_repository.dart';

class StatisticService {
  static Future<double> _getTotalExpenseOfWeek() async {
    String week = DatetimeUtil.formatNumber(
      DatetimeUtil.getCurrentWeekNumber(),
    );
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear());

    return await ExpenseRepository.getExpenseOfTheWeek(week, year);
  }

  static Future<double> _getTotalExpenseOfMonth() async {
    String month = DatetimeUtil.getFormatedMonth();
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear());

    return await ExpenseRepository.getExpenseOfTheMonth(month, year);
  }

  static Future<double> _getTotalExpenseOfYear() async {
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear());

    return await ExpenseRepository.getExpenseOfTheYear(year);
  }

  static Future<double> getTotalExpenseByOption(int option) async {
    switch (option) {
      case 0:
        return await _getTotalExpenseOfWeek();
      case 1:
        return await _getTotalExpenseOfMonth();
      default:
        return await _getTotalExpenseOfYear();
    }
  }

  static Future<List<ExpenseCategory>> getTotalExpensePerCategory(
    int option,
  ) async {
    String week = DatetimeUtil.formatNumber(
      DatetimeUtil.getCurrentWeekNumber(),
    );
    String month = DatetimeUtil.getFormatedMonth();
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear());
    String condition = "";

    switch (option) {
      case 0:
        // Filtre par semaine (%W) et année
        condition =
            "WHERE strftime('%W', e.date) = ? AND strftime('%Y', e.date) = ?";
        break;
      case 1:
        // Filtre par mois (%m) et année
        condition =
            "WHERE strftime('%m', e.date) = ? AND strftime('%Y', e.date) = ?";
        break;
      default:
        // Filtre uniquement par année
        condition = "WHERE strftime('%Y', e.date) = ?";
        break;
    }
    return await ExpenseRepository.getExpensePerCategory(
      option: option,
      week: week,
      month: month,
      year: year,
      condition: condition,
    );
  }

  static double getProgress(ExpenseCategory expense) {
    double limit = expense.category.categoryLimit.amount;
    double expenseValue = expense.amount;

    return expenseValue / limit;
  }

  static Future<double> _getTotalExpenseOfPreviousWeek() async {
    int currentWeek = DatetimeUtil.getCurrentWeekNumber();
    int currentYear = DatetimeUtil.getNowYear();

    int targetWeek = currentWeek - 1;
    int targetYear = currentYear;

    if (targetWeek <= 0) {
      targetWeek = 52; // SQLite %W va jusqu'à la semaine 52 (ou 53)
      targetYear = currentYear - 1;
    }

    String weekStr = DatetimeUtil.formatNumber(targetWeek);
    String yearStr = targetYear.toString();

    return await ExpenseRepository.getExpenseOfTheWeek(weekStr, yearStr);
  }

  static Future<double> _getTotalExpenseOfPreviousMonth() async {
    DateTime now = DateTime.now();

    int currentMonth = now.month; // 1 à 12
    int currentYear = now.year;

    int targetMonth = currentMonth - 1;
    int targetYear = currentYear;

    if (targetMonth < 1) {
      targetMonth = 12;
      targetYear = currentYear - 1;
    }

    String monthStr = DatetimeUtil.formatNumber(targetMonth);
    String yearStr = targetYear.toString();

    return await ExpenseRepository.getExpenseOfTheMonth(monthStr, yearStr);
  }

  static Future<double> _getTotalExpenseOfPreviousYear() async {
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear() - 1);

    return await ExpenseRepository.getExpenseOfTheYear(year);
  }

  static Future<double> getTotalPreviousExpenseByOption(int option) async {
    switch (option) {
      case 0:
        return await _getTotalExpenseOfPreviousWeek();
      case 1:
        return await _getTotalExpenseOfPreviousMonth();
      default:
        return await _getTotalExpenseOfPreviousYear();
    }
  }

  static Future<double> getPreviousExpensePourcentage(int option) async {
    double actualExpense = await getTotalExpenseByOption(option);
    double previousExpense = await getTotalPreviousExpenseByOption(option);

    if (previousExpense == 0) {
      // Si la dépense actuelle est aussi nulle, 0% de variation
      // Si la dépense actuelle est > 0, augmentation de 100%
      return actualExpense > 0 ? 100.0 : 0.0;
    }

    double diff = actualExpense - previousExpense;

    return diff * 100 / previousExpense;
  }

  static String getDescription(int option) {
    switch (option) {
      case 0:
        return " par rapport à la semaine précedente";
      case 1:
        return " par rapport au mois précedent";
      default:
        return " par rapport à l'année précedente";
    }
  }

  static Future<Map<int, double>> _getDailyExpenseEvolution() async {
    String week = DatetimeUtil.formatNumber(
      DatetimeUtil.getCurrentWeekNumber(),
    );
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear());

    return await ExpenseRepository.getDailyExpense(week, year);
  }

  static Future<Map<int, double>> _getDailyMonthlyExpenseEvolution() async {
    String month = DatetimeUtil.getFormatedMonth();
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear());

    return await ExpenseRepository.getMonthlyDailyExpense(month, year);
  }

  static Future<Map<int, double>> _getYearlyMonthlyExpenseEvolution() async {
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear());

    return await ExpenseRepository.getYearlyMonthlyExpense(year);
  }

  static Future<Map<int, double>> getExpenseEvolutionByPeriod(
    int option,
  ) async {
    switch (option) {
      case 0:
        return await _getDailyExpenseEvolution();
      case 1:
        return await _getDailyMonthlyExpenseEvolution();
      default:
        return await _getYearlyMonthlyExpenseEvolution();
    }
  }

  static Future<Map<int, double>> _getPreviousDailyExpenseEvolution() async {
    int currentWeek = DatetimeUtil.getCurrentWeekNumber();
    int currentYear = DatetimeUtil.getNowYear();

    int targetWeek = currentWeek - 1;
    int targetYear = currentYear;

    if (targetWeek <= 0) {
      targetWeek = 52;
      targetYear = currentYear - 1;
    }

    String weekStr = DatetimeUtil.formatNumber(targetWeek);
    String yearStr = targetYear.toString();

    return await ExpenseRepository.getDailyExpense(weekStr, yearStr);
  }

  static Future<Map<int, double>> _getPreviousDailyMonthlyExpenseEvolution() async {
    DateTime now = DateTime.now();

    int currentMonth = now.month;
    int currentYear = now.year;

    int targetMonth = currentMonth - 1;
    int targetYear = currentYear;

    if (targetMonth < 1) {
      targetMonth = 12; // Décembre
      targetYear = currentYear - 1;
    }

    String monthStr = DatetimeUtil.formatNumber(targetMonth);
    String yearStr = targetYear.toString();

    return await ExpenseRepository.getMonthlyDailyExpense(monthStr, yearStr);
  }

  static Future<Map<int, double>> _getPreviousYearlyMonthlyExpenseEvolution() async {
    String previousYear = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear() - 1);


    return await ExpenseRepository.getYearlyMonthlyExpense(previousYear);
  }

  static Future<Map<int, double>> getPreviousExpenseEvolutionByPeriod(
    int option,
  ) async {
    switch (option) {
      case 0:
        return await _getPreviousDailyExpenseEvolution();
      case 1:
        return await _getPreviousDailyMonthlyExpenseEvolution();
      default:
        return await _getPreviousYearlyMonthlyExpenseEvolution();
    }
  }
}
