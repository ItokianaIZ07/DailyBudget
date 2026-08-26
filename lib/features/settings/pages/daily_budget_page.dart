import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/exception/daily_budget_not_found.dart';
import 'package:gestion_depenses/core/widgets/daily_budget_edit_form.dart';
import 'package:gestion_depenses/models/daily_budget.dart';
import 'package:gestion_depenses/services/daily_budget_service.dart';

class DailyBudgetPage extends StatefulWidget {
  
  const DailyBudgetPage({super.key});

  @override
  State<DailyBudgetPage> createState() => _DailyBudgetPageState();
}

class _DailyBudgetPageState extends State<DailyBudgetPage> {
  final _formatAr = CurrencyUtil.getFormater();
  DailyBudget? _budget;
  String? _message;

  Future<void> _loadTodayBudget() async {
    DateTime today = DateTime.now();

    try {
      final budget = await DailyBudgetService.getBudgetByDate(today);
      setState(() {
        _budget = budget;
      });
    } on DailyBudgetNotFound catch (e) {
      setState(() {
        _message = "$e";
      });
    } catch (e) {
      debugPrint(
        "Une erreur est survenue lors du chargement du budget dans paramètre: $e",
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _loadTodayBudget();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Budget")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacing.md),
        child: Card(
          elevation: 0,
          color: AppTheme.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius.md),
            side: BorderSide(color: AppTheme.colors.border),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacing.lg),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius.sm),
                  ),
                  child: Icon(
                    Icons.attach_money_sharp,
                    color: AppTheme.colors.primary,
                  ),
                ),
                SizedBox(width: AppTheme.spacing.md),

                Expanded(
                  child: _message != null
                      ? Text(_message!)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Budget d'ajourd'hui",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.colors.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatAr.format(_budget?.amount ?? 0.0),
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.colors.text,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                ),

                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: AppTheme.colors.primary,
                  onPressed: () async {
                    if (_budget != null) {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return DailyBudgetEditForm(
                            budget: _budget,
                            onEdited: _loadTodayBudget,
                          );
                        },
                      );
                    }
                  },
                  tooltip: "Modifier le budget",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
