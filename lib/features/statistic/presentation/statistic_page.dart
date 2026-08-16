import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/features/statistic/widget/category_budget_progress_card.dart';
import 'package:gestion_depenses/models/expense_category.dart';
import 'package:gestion_depenses/services/statistic_service.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';

class StatisticsPage extends StatefulWidget {
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedPeriod = 1; // 0: Semaine, 1: Mois, 2: Année
  double _totalExpense = 0;
  final _formatAr = CurrencyUtil.getFormater();
  final List<ExpenseCategory> _expensesCategory = [];
  double _previousPercentage = 0;
  final List<FlSpot> _expensePerPeriod = [];
  final List<FlSpot> _previousExpensePerPeriod = [];

  Future<void> _loadTotalExpense() async {
    try {
      final expense = await StatisticService.getTotalExpenseByOption(
        _selectedPeriod,
      );
      setState(() {
        _totalExpense = expense;
      });
    } catch (e) {
      debugPrint(
        "Erreur lors du chargement des dépenses dans statistiques : $e",
      );
    }
  }

  Future<void> _loadExpensePerCategory() async {
    try {
      final expenses = await StatisticService.getTotalExpensePerCategory(
        _selectedPeriod,
      );
      setState(() {
        _expensesCategory.clear();
        _expensesCategory.addAll(expenses);
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des dépenses par catégorie");
    }
  }

  Future<void> _loadPreviousPercentage() async {
    try {
      final percentage = await StatisticService.getPreviousExpensePourcentage(
        _selectedPeriod,
      );
      setState(() {
        _previousPercentage = percentage;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des dépenses par catégorie");
    }
  }

  Future<void> _loadPeriodicData() async {
    try {
      final data = await StatisticService.getExpenseEvolutionByPeriod(
        _selectedPeriod,
      );
      setState(() {
        _expensePerPeriod.clear();
        data.forEach((period, expense) {
          if (period == 0) {
            _expensePerPeriod.insert(0, FlSpot(period.toDouble(), expense));
          } else {
            _expensePerPeriod.add(FlSpot(period.toDouble(), expense));
          }
        });
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des dépenses par catégorie");
    }
  }

  Future<void> _loadPreviousPeriodicData() async {
    try {
      final data = await StatisticService.getPreviousExpenseEvolutionByPeriod(
        _selectedPeriod,
      );
      setState(() {
        _previousExpensePerPeriod.clear();
        data.forEach((period, expense) {
          if (period == 0) {
            _previousExpensePerPeriod.insert(
              0,
              FlSpot(period.toDouble(), expense),
            );
          } else {
            _previousExpensePerPeriod.add(FlSpot(period.toDouble(), expense));
          }
        });
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des dépenses par catégorie");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTotalExpense();
    _loadExpensePerCategory();
    _loadPreviousPercentage();
    _loadPeriodicData();
    _loadPreviousPeriodicData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Statistiques",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPeriodChip("Semaine", 0),
                const SizedBox(width: 8),
                _buildPeriodChip("Mois", 1),
                const SizedBox(width: 8),
                _buildPeriodChip("Année", 2),
              ],
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total des dépenses",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatAr.format(_totalExpense),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _previousPercentage > 0
                                ? Colors.green.shade100
                                : AppTheme.colors.dangerSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${_previousPercentage > 0 ? "+" : ""}${_previousPercentage.toStringAsFixed(2)} %",
                                style: TextStyle(
                                  color: _previousPercentage > 0
                                      ? AppTheme.colors.success
                                      : AppTheme.colors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                StatisticService.getDescription(
                                  _selectedPeriod,
                                ),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppTheme.colors.text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Évolution des dépenses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _expensePerPeriod,
                      isCurved:
                          false, // false mba hi-evitena anazy hidina any @valeur négatif hi-reliena anle point roa(ref mielanelana b)
                      color: Theme.of(context).primaryColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withValues(
                          alpha: 0.15,
                        ), // Dégradé sous la courbe
                      ),
                    ),
                    LineChartBarData(
                      spots: _previousExpensePerPeriod,
                      isCurved: false,
                      color: AppTheme.colors.accent,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.colors.accentSoft.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 16,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      const SizedBox(width: 8),
                      Text(
                        _selectedPeriod == 0 ? "Semaine actuelle" : _selectedPeriod == 1 ? "Mois actuel": "Année actuelle",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 16,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.colors.accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      const SizedBox(width: 8),
                      Text(
                        _selectedPeriod == 0 ? "Semaine précedente" : _selectedPeriod == 1 ? "Mois précedent": "Année précedente",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: _expensesCategory.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final expense = _expensesCategory[index];
                return CategoryBudgetProgressCard(expense: expense, period: _selectedPeriod,);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedPeriod = index;
          _loadTotalExpense();
          _loadExpensePerCategory();
          _loadPreviousPercentage();
          _loadPeriodicData();
          _loadPreviousPeriodicData();
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
