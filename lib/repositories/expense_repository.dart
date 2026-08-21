import 'package:gestion_depenses/models/category_limit.dart';
import 'package:gestion_depenses/models/category_with_limit.dart';
import 'package:gestion_depenses/models/expense_category.dart';
import 'package:gestion_depenses/models/month.dart';
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
      orderBy: "date DESC",
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
      orderBy: 'date DESC',
    );

    return results
        .map((map) => Expense.fromMap(map, category: category))
        .toList();
  }

  static Future<List<Expense>> getByKeyword(
    String keyword, {
    int? month,
  }) async {
    String sql = """
      SELECT
        c.id AS category_id,
        c.name,
        c.color,
        e.id,
        e.description,
        e.date,
        e.amount

      FROM expenses e

      JOIN category c
        ON c.id = e.category_id

      WHERE e.description LIKE ? COLLATE NOCASE
    """;

    final List<dynamic> arguments = ["%$keyword%"];

    if (month != null) {
      sql += """
        AND strftime('%m', e.date) = ?
      """;

      arguments.add(month.toString().padLeft(2, '0'));
    }

    sql += """
      ORDER BY e.date DESC
    """;

    final List<Map<String, dynamic>> results = await _database.rawQuery(
      sql,
      arguments,
    );

    return results.map((element) {
      final category = Category(
        id: element["category_id"],
        name: element["name"],
        color: element["color"],
      );

      return Expense(
        id: element["id"],
        description: element["description"],
        amount: (element["amount"] as num).toDouble(),
        category: category,
        date: DateTime.parse(element["date"]),
      );
    }).toList();
  }

  static Future<List<Expense>> getByKeywordAndYear(
    String keyword,
    int year, {
    int? month,
  }) async {
    String sql = """
      SELECT
        c.id AS category_id,
        c.name,
        c.color,
        e.id,
        e.description,
        e.date,
        e.amount

      FROM expenses e

      JOIN category c
        ON c.id = e.category_id

      WHERE strftime('%Y', e.date) = ?
        AND e.description LIKE ? COLLATE NOCASE
    """;

    final List<dynamic> arguments = [year.toString(), "%$keyword%"];

    // Si un mois est sélectionné
    if (month != null) {
      sql += """
        AND strftime('%m', e.date) = ?
      """;

      arguments.add(month.toString().padLeft(2, '0'));
    }

    sql += """
      ORDER BY e.date DESC
    """;

    final List<Map<String, dynamic>> results = await _database.rawQuery(
      sql,
      arguments,
    );

    return results.map((element) {
      final category = Category(
        id: element["category_id"],
        name: element["name"],
        color: element["color"],
      );

      return Expense(
        id: element["id"],
        description: element["description"],
        amount: (element["amount"] as num).toDouble(),
        category: category,
        date: DateTime.parse(element["date"]),
      );
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

  static Future<Map<int, double>> getDailyExpense(
    String week,
    String year,
  ) async {
    String sql =
        """
      SELECT 
        strftime('%w', date) as day_index,
        COALESCE(SUM(amount), 0.0) as total
      FROM $_tableName
      WHERE strftime('%W', date) = ? AND strftime('%Y', date) = ?
      GROUP BY day_index
    """;

    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [
      week,
      year,
    ]);

    Map<int, double> weeklyData = {
      1: 0.0, // Lundi
      2: 0.0, // Mardi
      3: 0.0, // Mercredi
      4: 0.0, // Jeudi
      5: 0.0, // Vendredi
      6: 0.0, // Samedi
      7: 0.0, // Dimanche (0 dans SQLite)
    };

    for (var data in results) {
      int dayIndex = int.parse(data["day_index"]);
      double total = (data["total"] as num).toDouble();
      if (dayIndex == 0) {
        weeklyData[7] = total;
      } else {
        weeklyData[dayIndex] = total;
      }
    }

    return weeklyData;
  }

  static Future<Map<int, double>> getMonthlyDailyExpense(
    String month,
    String year,
  ) async {
    int monthInt = int.parse(month);
    int yearInt = int.parse(year);
    int daysInMonth = DateTime(yearInt, monthInt + 1, 0).day;

    Map<int, double> monthlyData = {
      for (int i = 1; i <= daysInMonth; i++) i: 0.0,
    };

    // groupe par jour du mois ('%d')
    String sql =
        """
        SELECT 
          strftime('%d', date) as day_of_month,
          COALESCE(SUM(amount), 0.0) as total
        FROM $_tableName
        WHERE strftime('%m', date) = ? AND strftime('%Y', date) = ?
        GROUP BY day_of_month
      """;

    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [
      month,
      year,
    ]);

    for (var data in results) {
      int day = int.parse(data["day_of_month"]);
      double total = (data["total"] as num).toDouble();
      monthlyData[day] = total;
    }

    return monthlyData;
  }

  static Future<Map<int, double>> getYearlyMonthlyExpense(String year) async {
    Map<int, double> yearlyData = {
      for (int month = 1; month <= 12; month++) month: 0.0,
    };

    String sql =
        """
        SELECT 
          strftime('%m', date) as month_index,
          COALESCE(SUM(amount), 0.0) as total
        FROM $_tableName
        WHERE strftime('%Y', date) = ?
        GROUP BY month_index
      """;

    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [
      year,
    ]);

    for (var data in results) {
      int monthIndex = int.parse(data["month_index"]);
      double total = (data["total"] as num).toDouble();
      yearlyData[monthIndex] = total;
    }

    return yearlyData;
  }

  static Future<void> deleteAllExpenses() async {
    await _database.delete(_tableName);
  }

  static Future<List<Month>> getListMonths(String year) async {
    String sql =
        """
    SELECT DISTINCT
        strftime('%m', date) AS numero_mois,
        CASE strftime('%m', date)
            WHEN '01' THEN 'Janvier'
            WHEN '02' THEN 'Février'
            WHEN '03' THEN 'Mars'
            WHEN '04' THEN 'Avril'
            WHEN '05' THEN 'Mai'
            WHEN '06' THEN 'Juin'
            WHEN '07' THEN 'Juillet'
            WHEN '08' THEN 'Août'
            WHEN '09' THEN 'Septembre'
            WHEN '10' THEN 'Octobre'
            WHEN '11' THEN 'Novembre'
            WHEN '12' THEN 'Décembre'
        END AS mois
    FROM $_tableName
    WHERE strftime('%Y', date) = ?
    ORDER BY numero_mois ASC
    """;
    final List<Map<String, dynamic>> results = await _database.rawQuery(sql, [
      year,
    ]);

    return results.map((item) {
      // return Month(
      //   "label": item["mois"].toString(),
      //   "value": item["numero_mois"].toString()
      // );
      return Month(
        label: item["mois"].toString(),
        value: item["numero_mois"].toString(),
      );
    }).toList();
  }

  static Future<List<Expense>?> getExpenseByMonthAndYear(
    Category category,
    String month,
    String year,
  ) async {
    final List<Map<String, dynamic>> results = await _database.query(
      _tableName,
      where: "strftime('%m', date) = ? AND strftime('%m', date)",
      whereArgs: [month, year],
      orderBy: "date DESC",
    );
    if (results.isEmpty) {
      return null;
    }
    return results.map((expense) {
      return Expense.fromMap(expense, category: category);
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
