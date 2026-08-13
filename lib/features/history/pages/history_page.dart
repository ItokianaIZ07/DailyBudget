import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/features/expense/widgets/card.dart';
import 'package:gestion_depenses/features/history/widgets/sort_widget.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/expense.dart';
import 'package:gestion_depenses/services/expense_service.dart';

class HistoryPage extends StatefulWidget {
  int selectedYear;
  
  HistoryPage({
    required this.selectedYear,
    super.key
  });

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

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await ExpenseService.getByCategory(_selectedCategory, widget.selectedYear);

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

  Future<void> _loadExpensesByKeyword(String keyword) async{
    if(keyword.isEmpty){
      await _loadExpenses();
      return;
    }
    try{
      final expenses = await ExpenseService.searchByKeyWord(keyword, widget.selectedYear);
      setState(() {
        _expenses.clear();
        _expenses.addAll(expenses);
      });
    }catch(e){
      debugPrint("Une erreur est survenue lors de la recherche des dépenses $e");
    }

  }

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    // _selectedValue = "2026";
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear != widget.selectedYear) {
      _loadExpenses();
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
                          _loadExpenses();
                        });
                      },
                      onSearch: (keyword){
                        setState(() {
                          _selectedCategory = null;
                          _loadExpensesByKeyword(keyword);
                        });
                      },
                    ),
                  ),
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
                      : Expanded(
                          child: AnimatedList(
                            key: ValueKey("${widget.selectedYear}_${_selectedCategory?.id}_${_expenses.length}"),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            initialItemCount: _expenses.length,
                            padding: EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                            itemBuilder:
                                (
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
                                        },
                                      ),
                                    ),
                                  );
                                },
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}
