import 'package:gestion_depenses/models/category_limit.dart';
import 'package:gestion_depenses/models/category_with_limit.dart';
import 'package:gestion_depenses/models/expense_category.dart';
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
    return _database.insert(_tableName, expense.toMap());
  }

  static Future<List<Expense>> getAllExpenses() async {
    final List<Map<String, dynamic>> results = await _database.query(
      _tableName,
      orderBy: "date DESC",
    );

    List<Expense> expenses = [];

    for (var map in results) {
      Category? category = await CategoryRepository.getCategoryById(
        map['category_id'],
      );

      if (category != null) {
        expenses.add(Expense.fromMap(map, category: category));
      }
    }

    return expenses;
  }

  static Future<Expense?> getExpenseById(int id) async {
    final List<Map<String, dynamic>> results = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      return null;
    }

    final map = results.first;

    Category? category = await CategoryRepository.getCategoryById(
      map['category_id'],
    );

    if (category == null) {
      return null;
    }

    return Expense.fromMap(map, category: category);
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

  static Future<List<Expense>> getExpensesByCategory(Category category) async {
    // final debugQuery = await _database.rawQuery("SELECT date, strftime('%Y', date) AS annee_extraite FROM expenses");
    // debugprint("DEBUG DATES EN BDD : $debugQuery");
    final List<Map<String, dynamic>> results = await _database.query(
      _tableName,
      where: "category_id = ?",
      whereArgs: [category.id],
    );

    return results
        .map((map) => Expense.fromMap(map, category: category))
        .toList();
  }

  static Future<List<Expense>> getExpensesByCategoryAndYear(
    Category category,
    int year,
  ) async {
    // final debugQuery = await _database.rawQuery("SELECT date, strftime('%Y', date) AS annee_extraite FROM expenses");
    // debugprint("DEBUG DATES EN BDD : $debugQuery");
    final List<Map<String, dynamic>> results = await _database.query(
      _tableName,
      where: "category_id = ? AND strftime('%Y', date) = ?",
      whereArgs: [category.id, year.toString()],
    );

    return results
        .map((map) => Expense.fromMap(map, category: category))
        .toList();
  }

  static Future<List<Expense>> getByKeyword(String keyword) async {
    String sql =
        "SELECT c.id as category_id, c.name, c.color, e.id, e.description, e.date, e.amount FROM expenses e JOIN category c ON c.id = e.category_id WHERE description LIKE ? COLLATE NOCASE ORDER BY date DESC"; // COLLATE NOCASE pour ingorer les majuscules et minuscules

    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [
      "%$keyword%",
    ]);

    return results.map((element) {
      Category category = Category(
        id: element["category_id"],
        name: element["name"],
        color: element["color"],
      );

      Expense expense = Expense(
        id: element["id"],
        description: element["description"],
        amount: element["amount"],
        category: category,
        date: DateTime.parse(element["date"]),
      );

      return expense;
    }).toList();
  }

  static Future<List<Expense>> getByKeywordAndYear(
    String keyword,
    int year,
  ) async {
    String sql =
        "SELECT c.id as category_id, c.name, c.color, e.id, e.description, e.date, e.amount FROM expenses e JOIN category c ON c.id = e.category_id WHERE strftime('%Y', e.date) = ? AND description LIKE ? COLLATE NOCASE ORDER BY date DESC"; // COLLATE NOCASE pour ingorer les majuscules et minuscules

    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [
      year.toString(),
      "%$keyword%",
    ]);

    return results.map((element) {
      Category category = Category(
        id: element["category_id"],
        name: element["name"],
        color: element["color"],
      );

      Expense expense = Expense(
        id: element["id"],
        description: element["description"],
        amount: element["amount"],
        category: category,
        date: DateTime.parse(element["date"]),
      );

      return expense;
    }).toList();
  }

  static Future<List<Expense>> getByYear(int year) async {
    String sql = """
      SELECT c.id as category_id, c.name, c.color, e.id, e.description, e.date, e.amount 
      FROM expenses e 
      JOIN category c ON c.id = e.category_id 
      WHERE strftime('%Y', e.date) = ? 
      ORDER BY e.date DESC
    """;
    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [
      year.toString(),
    ]);
    return results.map((element) {
      Category category = Category(
        id: element["category_id"],
        name: element["name"],
        color: element["color"],
      );

      Expense expense = Expense(
        id: element["id"],
        description: element["description"],
        amount: element["amount"],
        category: category,
        date: DateTime.parse(element["date"]),
      );

      return expense;
    }).toList();
  }

  static Future<List<int>> getListYear() async {
    String sql =
        "SELECT DISTINCT strftime('%Y', date) as annee FROM $_tableName ORDER BY annee DESC";
    final List<Map<String, dynamic>> results = await _database.rawQuery(sql);
    return results.map((element) {
      return int.parse(element["annee"]);
    }).toList();
  }

  static Future<double> getExpenseOfTheWeek(String week, String year) async {
    String sql =
        """
      SELECT COALESCE(SUM(amount), 0.0) as total 
      FROM $_tableName e 
      WHERE strftime('%W', e.date) = ? AND strftime('%Y', e.date) = ?
    """;
    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [
      week,
      year,
    ]);

    // await testDebugDates();

    if (results.isNotEmpty && results.first["total"] != null) {
      return (results.first["total"] as num).toDouble();
    }
    return 0.0;
  }

  static Future<double> getExpenseOfTheMonth(String month, String year) async {
    String sql =
        """
          SELECT COALESCE(SUM(amount), 0.0) as total 
          FROM $_tableName e 
          WHERE strftime('%m', e.date) = ? AND strftime('%Y', e.date) = ?
        """;

    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [
      month,
      year,
    ]);

    if (results.isNotEmpty && results.first["total"] != null) {
      return (results.first["total"] as num).toDouble();
    }
    return 0.0;
  }

  static Future<double> getExpenseOfTheYear(String year) async {
    String sql =
        """
          SELECT COALESCE(SUM(amount), 0.0) as total 
          FROM $_tableName e 
          WHERE strftime('%Y', e.date) = ?
        """;

    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [
      year,
    ]);

    if (results.isNotEmpty && results.first["total"] != null) {
      return (results.first["total"] as num).toDouble();
    }
    return 0.0;
  }

  static Future<List<ExpenseCategory>> getExpensePerCategory({
    required int option,
    required String week,
    required String month,
    required String year,
    required String condition,
  }) async {
    // COALESCE(...) pour remplacer NULL par 0.0
    String sql =
        """
          SELECT 
            c.id, 
            c.name, 
            c.color, 
            COALESCE(l.amount, 0.0) as limit_amount, 
            COALESCE(SUM(e.amount), 0.0) as total 
          FROM category c 
          LEFT JOIN $_tableName e ON c.id = e.category_id 
          LEFT JOIN category_limit l ON l.category_id = c.id 
          $condition
          GROUP BY c.id, c.name, c.color, l.amount 
          ORDER BY total DESC
        """;

    List<String> arguments = [];
    if (option == 0) {
      arguments = [week, year];
    } else if (option == 1) {
      arguments = [month, year];
    } else {
      arguments = [year.toString()];
    }

    final List<Map<String, dynamic>> results = await _database.rawQuery(
      sql,
      arguments,
    );

    return results.map((element) {
      Category category = Category(
        id: element["id"],
        name: element["name"],
        color: element["color"],
      );

      double limitAmount = (element["limit_amount"] as num?)?.toDouble() ?? 0.0;
      double totalExpense = (element["total"] as num?)?.toDouble() ?? 0.0;

      CategoryLimit limit = CategoryLimit(
        amount: limitAmount,
        category: category,
      );

      CategoryWithLimit categoryWithLimit = CategoryWithLimit(
        category: category,
        categoryLimit: limit,
      );

      return ExpenseCategory(amount: totalExpense, category: categoryWithLimit);
    }).toList();
  }

  //   static Future<void> testDebugDates() async {
  //   // Sélectionne les dates brutes ainsi que la semaine et l'année calculées par SQLite
  //   String sql = """
  //     SELECT
  //       date,
  //       strftime('%W', date) AS semaine_sqlite,
  //       strftime('%Y', date) AS annee_sqlite,
  //       amount
  //     FROM $_tableName
  //     LIMIT 10
  //   """;

  //   final List<Map<String, dynamic>> results = await _database.rawQuery(sql);

  //   debugPrint("--- TEST DEBUG DATES ---");
  //   for (var row in results) {
  //     debugPrint(
  //       "Date BDD: ${row['date']} | Semaine SQLite: '${row['semaine_sqlite']}' | Année SQLite: '${row['annee_sqlite']}' | Montant: ${row['amount']}"
  //     );
  //   }
  //   debugPrint("------------------------");
  // }
}
