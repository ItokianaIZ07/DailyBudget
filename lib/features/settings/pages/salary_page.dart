import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/exception/monthly_salary_not_found_exception.dart';
import 'package:gestion_depenses/features/settings/widgets/salary_edit_form.dart';
import 'package:gestion_depenses/models/monthly_salary.dart';
import 'package:gestion_depenses/services/monthly_salary_service.dart';

class SalaryPage extends StatefulWidget {
  const SalaryPage({super.key});

  @override
  State<StatefulWidget> createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  final _formatAr = CurrencyUtil.getFormater();
  MonthlySalary? _salary;
  String? _message;

  Future<void> _loadSalary() async {
    int month = DatetimeUtil.getNowMonth();
    int year = DatetimeUtil.getNowYear();

    try {
      final salary = await MonthlySalaryService.getSalary(month, year);
      setState(() {
        _salary = salary;
      });
    } on MonthlySalaryNotFoundException catch (e) {
      setState(() {
        _message = "$e";
      });
    } catch (e) {
      debugPrint(
        "Une erreur est survenue lors du chargement du salaire mensuel dans paramètre: $e",
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _loadSalary();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Salaire")),
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
                    Icons.payments_outlined,
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
                              "Salaire",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.colors.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatAr.format(_salary?.amount ?? 0.0),
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
                    if (_salary != null) {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return SalaryEditForm(
                            salary: _salary!,
                            onEdited: _loadSalary,
                          );
                        },
                      );
                    }
                  },
                  tooltip: "Modifier le salaire",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
