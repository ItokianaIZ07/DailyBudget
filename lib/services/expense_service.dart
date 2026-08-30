import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/services/notification_service.dart';
import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/exception/daily_budget_not_found.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/category_with_limit.dart';
import 'package:gestion_depenses/models/daily_budget.dart';
import 'package:gestion_depenses/models/expense.dart';
import 'package:gestion_depenses/models/option_result.dart';
import 'package:gestion_depenses/repositories/expense_repository.dart';
import 'package:gestion_depenses/services/daily_budget_service.dart';

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

    return OperationResult(
      success: true,
      message: 'Validation réussie.',
    );
  }


  static Future<OperationResult> insertExpense(Expense expense) async {
    try {
      await _getRequiredDailyBudget(expense.date);

      await ExpenseRepository.createExpense(expense);

      await _checkDailyBudgetNotification(expense.date);

      return OperationResult(
        success: true,
        message: 'Dépense enregistrée avec succès',
      );
    } on DailyBudgetNotFound {
      return OperationResult(
        success: false,
        message:
            "Aucun budget n'a été fixé pour la date "
            "${DatetimeUtil.formatDate(expense.date)}",
      );
    } catch (e) {
      debugPrint(
        "Erreur lors de l'enregistrement de la dépense : $e",
      );

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

    final double? parsed = double.tryParse(
      amount.replaceAll(',', '.'),
    );

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
      return await ExpenseRepository.getByKeyword(
        keyword,
        month: month,
      );
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

  static Future<double> calculateSumExpenseByDate(
    DateTime date,
  ) async {
    return await ExpenseRepository.getExpenseByDate(date);
  }

  static Future<double> getExpenseOfTheMonth(
    int month,
    int year,
  ) async {
    return await ExpenseRepository.getExpenseOfTheMonth(
      DatetimeUtil.formatNumber(month),
      year.toString(),
    );
  }

  static Future<List<Expense>> getExpenseByLimit(int limit) async {
    return await ExpenseRepository.getExpenseByLimit(limit);
  }

  static Future<int> deleteExpense(Expense expense) async {
    final int deletedExpense =
        await ExpenseRepository.deleteExpense(expense);

    await _checkDailyBudgetNotification(expense.date);

    return deletedExpense;
  }

  static Future<void> deleteAllExpenses() async {
    final List<DateTime> expenseDates =
        await ExpenseRepository.getAllExpenseDates();

    await ExpenseRepository.deleteAllExpenses();

    for (final date in expenseDates) {
      await _checkDailyBudgetNotification(date);
    }
  }

  static Future<void> updateExpense(Expense expense) async {
    final Expense? oldExpense = await ExpenseRepository.getExpenseById(expense.id!);

    if (oldExpense == null) {
      throw Exception("La dépense à modifier n'existe pas.");
    }

    if (oldExpense.date.toDateString() != expense.date.toDateString()) {
      await _getRequiredDailyBudget(expense.date);
    }

    await ExpenseRepository.updateExpense(expense);

    if (oldExpense.date.toDateString() != expense.date.toDateString()) {
      await _checkDailyBudgetNotification(oldExpense.date);
    }

    await _checkDailyBudgetNotification(expense.date);
  }

  static Future<DailyBudget> _getRequiredDailyBudget(
    DateTime date,
  ) async {
    final DailyBudget? budget =
        await DailyBudgetService.getBudgetByDate(date);

    if (budget == null) {
      throw DailyBudgetNotFound(date);
    }

    return budget;
  }

  static Future<void> _checkDailyBudgetNotification(
    DateTime date,
  ) async {
    try {
      final double totalExpense =
          await calculateSumExpenseByDate(date);

      final DailyBudget? budget = await DailyBudgetService.getBudgetByDate(date);

      if (budget == null) {
        return;
      }

      final double remaining = budget.amount - totalExpense;

      if (remaining < 0) {
        if (budget.notificationSent == 0) {
          await NotificationService.instance.showNotification(
            title: "SpendWise",
            body:
                "Vous avez dépassé le budget de ${budget.amount} "
                "fixé le ${DatetimeUtil.formatDate(date)}",
          );

          await DailyBudgetService.changeNotificationState(
            budget.id!,
            1,
          );
        }
      } else {
        if (budget.notificationSent == 1) {
          await DailyBudgetService.changeNotificationState(budget.id!,0);
        }
      }
    } catch (e) {
      debugPrint(
        "Erreur lors de la vérification de la notification : $e",
      );

      rethrow;
    }
  }
}