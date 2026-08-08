import 'package:sqflite/sqflite.dart';

import 'package:gestion_depenses/core/database/database_service.dart';
import 'package:gestion_depenses/core/database/tables/expense_table.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/expense.dart';
import 'category_repository.dart';

class ExpenseRepository {
  static final String _tableName = ExpenseTable.tableName;
  static Database get _database => DatabaseService.instance.connexion!;


  static Future<int> createExpense(Expense expense) {
    return _database.insert(
      _tableName,
      expense.toMap(),
    );
  }


  static Future<List<Expense>> getAllExpenses() async {
    final List<Map<String, dynamic>> results = await _database.query(_tableName, orderBy: "date DESC");

    List<Expense> expenses = [];

    for (var map in results) {
      Category? category = await CategoryRepository.getCategoryById(map['category_id']);

      if (category != null) {
        expenses.add(
          Expense.fromMap(
            map,
            category: category,
          ),
        );
      }
    }

    return expenses;
  }


  static Future<Expense?> getExpenseById(int id) async {
    final List<Map<String, dynamic>> results =
        await _database.query(
          _tableName,
          where: 'id = ?',
          whereArgs: [id],
        );

    if (results.isEmpty) {
      return null;
    }

    final map = results.first;

    Category? category =
        await CategoryRepository.getCategoryById(map['category_id']);

    if (category == null) {
      return null;
    }

    return Expense.fromMap(
      map,
      category: category,
    );
  }


  static Future<int> updateExpense(Expense expense) {
    return _database.update(
      _tableName,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }


  static Future<int> deleteExpense(Expense expense) {
    return _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }


  static Future<List<Expense>> getExpensesByCategory(
      Category category) async {
    final List<Map<String, dynamic>> results =
        await _database.query(
          _tableName,
          where: 'category_id = ?',
          whereArgs: [category.id],
        );

    return results
        .map(
          (map) => Expense.fromMap(
            map,
            category: category,
          ),
        )
        .toList();
  }
}