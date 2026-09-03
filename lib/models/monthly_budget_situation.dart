class MonthlyBudgetSituation {
  final double salary;
  final double plannedBudget;
  final double availableBudget;
  final double spent;
  final double remaining;

  MonthlyBudgetSituation({
    required this.salary,
    required this.plannedBudget,
    required this.availableBudget,
    required this.spent,
    required this.remaining,
  });

  double get expenseRatio {
    if (plannedBudget <= 0) return 0.0;
    return (spent / plannedBudget).clamp(0.0, 1.0);
  }

  bool get isOverBudget => spent > plannedBudget;
}