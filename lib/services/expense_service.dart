import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/category_with_limit.dart';
import 'package:gestion_depenses/models/expense.dart';
import 'package:gestion_depenses/models/option_result.dart';
import 'package:gestion_depenses/repositories/expense_repository.dart';

class ExpenseService {
  static OperationResult validateExpenseInput({
    required String amount,
    required String description,
    required CategoryWithLimit? category,
  }) {
    if (!_isAmountValid(amount)) {
      return OperationResult(
        success: false,
        message: 'Veuillez saisir un montant positif valide.',
      );
    }

    if (!_isDescriptionValid(description)) {
      return OperationResult(
        success: false,
        message: 'Veuillez saisir une description valide.',
      );
    }

    if (!_isCategorySelected(category)) {
      return OperationResult(
        success: false,
        message: 'Veuillez choisir une catégorie.',
      );
    }

    return OperationResult(success: true, message: 'Validation réussie.');
  }

  static Future<OperationResult> insertExpense(Expense expense) async {
    try {
      await ExpenseRepository.createExpense(expense);
      return OperationResult(
        success: true,
        message: 'Dépense enregistrée avec succès',
      );
    } catch (e) {
      return OperationResult(
        success: false,
        message: 'Impossible d’enregistrer la dépense',
      );
    }
  }

  static bool _isAmountValid(String amount) {
    if (amount.isEmpty) {
      return false;
    }

    final double? parsed = double.tryParse(amount.replaceAll(',', '.'));
    return parsed != null && parsed > 0;
  }

  static bool _isDescriptionValid(String description) {
    return description.trim().isNotEmpty;
  }

  static bool _isCategorySelected(CategoryWithLimit? category) {
    return category != null;
  }

  static Future<List<Expense>> getAllExpenses() async {
    return await ExpenseRepository.getAllExpenses();
  }

  static double sumExpenseAmount(List<Expense> expenses) {
    double sum = 0;
    for (var expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }

  static Future<int> deleteExpense(Expense expense) async {
    return await ExpenseRepository.deleteExpense(expense);
  }

  static Future<List<Expense>> getByCategory(
    Category? category,
    int year,
    String? month,
  ) async {
    final List<Expense> expenses;

    if (category == null) {
      expenses = year < 0
          ? await ExpenseRepository.getAllExpenses()
          : await ExpenseRepository.getByYear(year);
    } else {
      expenses = year < 0
          ? await ExpenseRepository.getExpensesByCategory(category)
          : await ExpenseRepository.getExpensesByCategoryAndYear(
              category,
              year,
            );
    }

    if (month == null) {
      return expenses;
    }

    final monthNumber = int.tryParse(month);
    if (monthNumber == null) {
      return [];
    }

    return expenses
        .where((expense) => expense.date.month == monthNumber)
        .toList();
  }

  static Future<List<Expense>> searchByKeyWord(
    String keyword,
    int year, {
    int? month,
  }) async {
    if (year < 0) {
      return await ExpenseRepository.getByKeyword(keyword, month: month);
    }

    return await ExpenseRepository.getByKeywordAndYear(
      keyword,
      year,
      month: month,
    );
  }

  static Future<List<Expense>> getByTransactionYear(int year) async {
    return await ExpenseRepository.getByYear(year);
  }

  static Future<List<int>> getListYearTransaction() async {
    return await ExpenseRepository.getListYear();
  }

  static Future<void> deleteAllExpenses() async {
    await ExpenseRepository.deleteAllExpenses();
  }

  static Future<void> updateExpense(Expense expense) async {
    await ExpenseRepository.updateExpense(expense);
  }
}
