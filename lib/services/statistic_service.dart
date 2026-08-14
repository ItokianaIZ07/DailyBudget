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
    String week = DatetimeUtil.formatNumber(DatetimeUtil.getCurrentWeekNumber());
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
}
