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

  Future<void> _loadTotalExpense() async{
    try{
      final expense = await StatisticService.getTotalExpenseByOption(_selectedPeriod);
      setState(() {
        _totalExpense = expense;
      });
    }catch(e){
      debugPrint("Erreur lors du chargement des dépenses dans statistiques : $e");
    }
  }

  Future<void> _loadExpensePerCategory() async{
    try{
      final expenses = await StatisticService.getTotalExpensePerCategory(_selectedPeriod);
      setState(() {
        _expensesCategory.clear();
        _expensesCategory.addAll(expenses);
      });
    }catch(e){
      debugPrint("Erreur lors du chargement des dépenses par catégorie");
    }
  }

  @override
  void initState(){
    super.initState();
    _loadTotalExpense();
    _loadExpensePerCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Statistiques",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total des dépenses", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatAr.format(_totalExpense),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "-8.5%",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 20),
                        FlSpot(2, 50),
                        FlSpot(3, 30),
                        FlSpot(4, 80),
                        FlSpot(5, 45),
                        FlSpot(6, 90),
                      ],
                      isCurved: true, // Courbe fluide
                      color: Theme.of(context).primaryColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.15), // Dégradé sous la courbe
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16,),
            ListView.builder(
              itemCount: _expensesCategory.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                final expense = _expensesCategory[index];
                return CategoryBudgetProgressCard(expense: expense);
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
        setState((){
          _selectedPeriod = index;
          _loadTotalExpense();
          _loadExpensePerCategory();
        });
      },
    );
  }

  @override
  void dispose(){
    super.dispose();
  }
}