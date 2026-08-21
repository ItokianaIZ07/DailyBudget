import 'package:flutter/material.dart';

import 'package:gestion_depenses/core/themes/app_theme.dart';

import 'package:gestion_depenses/features/expense/widgets/card.dart';
import 'package:gestion_depenses/features/history/widgets/sort_widget.dart';
import 'package:gestion_depenses/features/history/widgets/total_widget.dart';
import 'package:gestion_depenses/features/expense/widgets/edit_modal.dart';

import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/expense.dart';
import 'package:gestion_depenses/models/month.dart';

import 'package:gestion_depenses/services/category_service.dart';
import 'package:gestion_depenses/services/expense_service.dart';
import 'package:gestion_depenses/services/history_service.dart';

class HistoryPage extends StatefulWidget {
  final int selectedYear;

  const HistoryPage({required this.selectedYear, super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  final List<Expense> _expenses = [];
  final List<Month> _months = [];
  final List<Category> _categories = [];

  Category? _selectedCategory;
  Month? _selectedMonth;

  double _totalExpense = 0;

  bool _isLoading = false;

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await ExpenseService.getByCategory(
        _selectedCategory,
        widget.selectedYear,
        _selectedMonth?.value,
      );

      if (!mounted) return;

      setState(() {
        _expenses
          ..clear()
          ..addAll(expenses);

        _totalExpense = ExpenseService.sumExpenseAmount(_expenses);
      });
    } catch (e) {
      debugPrint('Erreur chargement des dépenses : $e');
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExpensesByKeyword(String keyword) async {
    try {
      final search = keyword.trim();

      if (search.isEmpty) {
        await _loadExpenses();
        return;
      }

      int? month;

      if (_selectedMonth?.value != null) {
        month = int.parse(_selectedMonth!.value!);
      }

      final expenses = await ExpenseService.searchByKeyWord(
        search,
        widget.selectedYear,
        month: month,
      );

      if (!mounted) return;

      setState(() {
        _expenses
          ..clear()
          ..addAll(expenses);

        _totalExpense = ExpenseService.sumExpenseAmount(_expenses);
      });
    } catch (e) {
      debugPrint('Une erreur est survenue lors de la recherche : $e');
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    try {
      await ExpenseService.deleteExpense(expense);

      if (!mounted) return;

      setState(() {
        _expenses.removeWhere((item) => item.id == expense.id);

        _totalExpense = ExpenseService.sumExpenseAmount(_expenses);
      });
    } catch (e) {
      debugPrint('Erreur suppression dépense : $e');
    }
  }

  Future<void> _loadMonths() async {
    final allFilter = Month(value: null, label: "Toutes");

    try {
      final months = await HistoryService.getAllMonths();

      final selectedMonthValue = _selectedMonth?.value;

      if (!mounted) return;

      setState(() {
        _months
          ..clear()
          ..add(allFilter)
          ..addAll(months);

        _selectedMonth = _months.firstWhere(
          (month) => month.value == selectedMonthValue,
          orElse: () => allFilter,
        );
      });
    } catch (e) {
      debugPrint('Une erreur est survenue lors du chargement des mois : $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getAllCategories();

      if (!mounted) return;

      setState(() {
        _categories
          ..clear()
          ..addAll(categories);
      });
    } catch (e) {
      debugPrint(
        'Une erreur est survenue lors du chargement des catégories : $e',
      );
    }
  }

  Future<void> _refreshScreen() async {
    await _loadMonths();
    await _loadExpenses();
  }

  Future<void> _showEditModal(BuildContext context, Expense expense) async {
    final bool? modified = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EditModal(categories: _categories, expense: expense);
      },
    );

    if (modified == true) {
      await _loadExpenses();
    }
  }

  @override
  void initState() {
    super.initState();

    _refreshScreen();
    _loadCategories();
  }

  // Appelé lorsque le filtre année change
  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedYear != widget.selectedYear) {
      _refreshScreen();
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

                      onCategorySelected: (category) async {
                        setState(() {
                          _selectedCategory = category;
                        });

                        await _loadExpenses();
                      },

                      onSearch: (keyword) async {
                        setState(() {
                          _selectedCategory = null;
                        });
                        await _loadExpensesByKeyword(keyword);
                      },
                    ),
                  ),

                  // FILTRE MOIS
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

                        onChanged: (value) async {
                          setState(() {
                            _selectedMonth = value;
                          });

                          await _loadExpenses();
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

                          if (_expenses.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(24),

                              child: Text(
                                "Aucune dépense trouvée pour ces critères",

                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  color: AppTheme.colors.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

                              itemCount: _expenses.length,

                              padding: const EdgeInsets.only(
                                bottom: 8,
                                left: 8,
                                right: 8,
                              ),

                              itemBuilder: (context, index) {
                                final expense = _expenses[index];

                                return ExpenseCard(
                                  expense: expense,
                                  onDelete: () async {
                                    await _deleteExpense(expense);
                                  },
                                  onEdit: () async {
                                    await _showEditModal(context, expense);
                                  },
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
