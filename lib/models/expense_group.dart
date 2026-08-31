import 'package:gestion_depenses/models/daily_budget_situation.dart';
import 'package:gestion_depenses/models/expense.dart';

class ExpenseGroup {
  final DateTime date;
  final List<Expense> expenses;
  final DailyBudgetSituation? situation;

  ExpenseGroup({
    required this.date,
    required this.expenses,
    this.situation,
  });

  double get total {
    return expenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }
}