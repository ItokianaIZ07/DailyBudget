import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/features/expense/widgets/card.dart';
import 'package:gestion_depenses/features/history/widgets/sort_widget.dart';
import 'package:gestion_depenses/features/history/widgets/total_widget.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/expense.dart';
import 'package:gestion_depenses/models/month.dart';
import 'package:gestion_depenses/services/expense_service.dart';
import 'package:gestion_depenses/services/history_service.dart';

class HistoryPage extends StatefulWidget {
  int selectedYear;

  HistoryPage({required this.selectedYear, super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // final List<String> _years = ["2026", "2025", "2024", "2023"];
  // String _selectedValue = "";
  final List<Expense> _expenses = [];
  Category? _selectedCategory;
  bool _isLoading = false;
  final GlobalKey<AnimatedListState> _expenseListKey =
      GlobalKey<AnimatedListState>();
  Month? _selectedMonth;
  final List<Month> _months = [];
  double _totalExpense = 0;

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await ExpenseService.getByCategory(
        _selectedCategory,
        widget.selectedYear,
        _selectedMonth?.value
      );

      setState(() {
        _expenses.clear();
        _expenses.addAll(expenses);
      });
    } catch (e) {
      debugPrint('Erreur chargement des dépenses : $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExpense(Expense expense, int index) async {
    try {
      await ExpenseService.deleteExpense(expense);

      if (index >= _expenses.length) {
        return;
      }

      final removedExpense = _expenses.removeAt(index);

      _expenseListKey.currentState?.removeItem(index, (context, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: ExpenseCard(
              description: removedExpense.description,
              amount: removedExpense.amount,
              category: removedExpense.category.name,
              date: removedExpense.date,
              onDelete: () {},
            ),
          ),
        );
      }, duration: const Duration(milliseconds: 300));

      setState(() {});
    } catch (e) {
      debugPrint('Erreur suppression dépense : $e');
    }
  }

  Future<void> _loadExpensesByKeyword(String keyword) async {
    if (keyword.isEmpty) {
      await _loadExpenses();
      return;
    }
    try {
      final expenses = await ExpenseService.searchByKeyWord(
        keyword,
        widget.selectedYear,
      );
      setState(() {
        _expenses.clear();
        _expenses.addAll(expenses);
      });
    } catch (e) {
      debugPrint(
        "Une erreur est survenue lors de la recherche des dépenses $e",
      );
    }
  }

  Future<void> _loadMonths() async {
    final allFilter = Month(value: null, label: "Toutes");

    try {
      final months = await HistoryService.getAllMonths();
      final selectedMonthValue = _selectedMonth?.value;

      setState(() {
        _months.clear();
        _months.add(allFilter);
        _months.addAll(months);

        _selectedMonth = _months.firstWhere(
          (month) => month.value == selectedMonthValue,
          orElse: () => allFilter,
        );
      });
    } catch (e) {
      debugPrint("Une erreur est survenue lors du chargement des mois : $e");
    }
  }

  Future<void> _loadTotalExpense() async {
    if (widget.selectedYear < 0) {
      setState(() {
        _totalExpense = ExpenseService.sumExpenseAmount(_expenses);
      });
      return;
    }
    try {
      final total = await HistoryService.getExpenseByPeriod(
        _selectedMonth?.value,
        widget.selectedYear,
      );
      setState(() {
        _totalExpense = total;
      });
    } catch (e) {
      debugPrint(
        "Une erreur est survenue lors du chargement de la total des dépénses: $e",
      );
    }
  }

  Future<void> _refreshScreen() async {
    await _loadExpenses();
    await _loadMonths();
    await _loadTotalExpense();
  }

  @override
  void initState() {
    super.initState();
    _refreshScreen();
    // _selectedValue = "2026";
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear != widget.selectedYear) {
      _refreshScreen();
      debugPrint("${_expenses.length}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppTheme.colors.primary,
                ),
              )
            : Column(
                children: [
                  Container(
                    height: 128,
                    padding: const EdgeInsets.all(8),
                    child: SortWidget(
                      selectedCategory: _selectedCategory,
                      selectedYear: widget.selectedYear,
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                          _refreshScreen();
                        });
                      },
                      onSearch: (keyword) {
                        setState(() {
                          _selectedCategory = null;
                          _loadExpensesByKeyword(keyword);
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radius.sm),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<Month>(
                        isExpanded: true,
                        initialValue: _selectedMonth,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        items: _months.map<DropdownMenuItem<Month>>((month) {
                          return DropdownMenuItem<Month>(
                            value: month,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month),
                                const SizedBox(width: 16),
                                Text(
                                  month.label,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) async{
                          setState(() {
                            _selectedMonth = value;
                          });
                          await _loadExpenses();
                          await _loadTotalExpense();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TotalWidget(
                            totalExpense: _totalExpense,
                            selectedMonth: _selectedMonth,
                            selectedYear: widget.selectedYear,
                          ),
                          const SizedBox(height: 16),
                          _expenses.isEmpty
                              ? Center(
                                  child: Text(
                                    "Aucune dépense trouvée pour cette catégorie",
                                    style: TextStyle(
                                      color: AppTheme.colors.textMuted,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : AnimatedList(
                                  key: ValueKey(
                                    "${widget.selectedYear}_${_selectedCategory?.id}_${_expenses.length}",
                                  ),
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  initialItemCount: _expenses.length,
                                  padding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    left: 8,
                                    right: 8,
                                  ),
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                    Animation<double> animation,
                                  ) {
                                    final expense = _expenses[index];

                                    return FadeTransition(
                                      opacity: animation,
                                      child: SizeTransition(
                                        sizeFactor: animation,
                                        child: ExpenseCard(
                                          description: expense.description,
                                          amount: expense.amount,
                                          category: expense.category.name,
                                          date: expense.date,
                                          onDelete: () async {
                                            await _deleteExpense(expense, index);
                                            await _refreshScreen();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
