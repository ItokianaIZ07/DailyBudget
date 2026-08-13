import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/features/home/widgets/home_page_header.dart';
import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/features/expense/widgets/card.dart';
import 'package:gestion_depenses/features/home/widgets/stat_card.dart';
import 'package:gestion_depenses/models/expense.dart';
import 'package:gestion_depenses/services/expense_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String date = "";

  final _formatAr = CurrencyUtil.getFormater();

  final List<Expense> _expenses = [];

  final GlobalKey<AnimatedListState> _expenseListKey =
      GlobalKey<AnimatedListState>();

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await ExpenseService.getAllExpenses();

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

  Future<void> _initDate() async {
    date = await DatetimeUtil.getDate();

    if (mounted) {
      setState(() {});
    }
  }


  @override
  void initState() {
    super.initState();

    _initDate();
    _loadExpenses();
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppTheme.spacing.sm,
                  children: [
                    // ------------------------------------------------
                    // HEADER
                    // ------------------------------------------------
                    HomePageHeader(title: "Bienvenue", date: date),

                    // ------------------------------------------------
                    // STATISTIQUES
                    // ------------------------------------------------
                    SizedBox(
                      height: 104,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: 220,
                            child: StatCard(
                              title: "Montant des dépenses effectuées",
                              mainContent: _formatAr.format(
                                ExpenseService.sumExpenseAmount(_expenses),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          SizedBox(
                            width: 180,
                            child: StatCard(
                              title: "Dépenses effectuées",
                              mainContent: _expenses.length.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ------------------------------------------------
                    // LISTE DES DEPENSES
                    // ------------------------------------------------
                    AnimatedList(
                      key: _expenseListKey,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      initialItemCount: _expenses.length,
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
                  ],
                ),
              ),
      ),
    );
  }
}
