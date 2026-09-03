import 'package:flutter/material.dart';
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
  State<SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  final _formatAr = CurrencyUtil.getFormater();

  MonthlySalary? _salary;
  String? _message;

  final List<MonthlySalary> _listMonthlySalary = [];

  bool _isLoading = true;

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final int month = DatetimeUtil.getNowMonth();
    final int year = DatetimeUtil.getNowYear();

    try {
      MonthlySalary? salary;

      try {
        salary = await MonthlySalaryService.getSalary(month, year);
      } on MonthlySalaryNotFoundException catch (e) {
        _message = "$e";
      }

      final salaries = await MonthlySalaryService.getAllSalary();

      if (!mounted) return;

      setState(() {
        _salary = salary;

        _listMonthlySalary
          ..clear()
          ..addAll(salaries);

        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        "Une erreur est survenue lors du chargement des salaires : $e",
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _message = "Impossible de charger les salaires.";
      });
    }
  }

  String _formatMonth(int month) {
    const months = [
      "Janvier",
      "Février",
      "Mars",
      "Avril",
      "Mai",
      "Juin",
      "Juillet",
      "Août",
      "Septembre",
      "Octobre",
      "Novembre",
      "Décembre",
    ];

    return months[month - 1];
  }

  bool _isCurrentSalary(MonthlySalary salary) {
    return salary.month == DatetimeUtil.getNowMonth() &&
        salary.year == DatetimeUtil.getNowYear();
  }

  Future<void> _editCurrentSalary() async {
    if (_salary == null) return;

    await showDialog(
      context: context,
      builder: (context) {
        return SalaryEditForm(salary: _salary!, onEdited: _loadData);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Salaire")),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.colors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppTheme.spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─────────────────────────────
                    // SALAIRE DU MOIS COURANT
                    // ─────────────────────────────
                    Card(
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
                                color: AppTheme.colors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radius.sm,
                                ),
                              ),
                              child: Icon(
                                Icons.payments_outlined,
                                color: AppTheme.colors.primary,
                              ),
                            ),

                            SizedBox(width: AppTheme.spacing.md),

                            Expanded(
                              child: _salary == null
                                  ? Text(
                                      _message ??
                                          "Aucun salaire défini pour ce mois.",
                                      style: TextStyle(
                                        color: AppTheme.colors.textMuted,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Salaire du mois",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.colors.secondary,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          _formatAr.format(_salary!.amount),
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: AppTheme.colors.text,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        const SizedBox(height: 3),

                                        Text(
                                          "${_formatMonth(_salary!.month)} ${_salary!.year}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.colors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),

                            if (_salary != null)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                color: AppTheme.colors.primary,
                                tooltip: "Modifier le salaire",
                                onPressed: _editCurrentSalary,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─────────────────────────────
                    // HISTORIQUE
                    // ─────────────────────────────
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 20,
                          color: AppTheme.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Historique des salaires",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.colors.text,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_listMonthlySalary.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            "Aucun salaire enregistré.",
                            style: TextStyle(
                              color: AppTheme.colors.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._listMonthlySalary.map((salary) {
                        final bool isCurrent = _isCurrentSalary(salary);

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isCurrent
                              ? AppTheme.colors.primary.withValues(alpha: 0.08)
                              : AppTheme.colors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radius.sm,
                            ),
                            side: BorderSide(
                              color: isCurrent
                                  ? AppTheme.colors.primary.withValues(
                                      alpha: 0.35,
                                    )
                                  : AppTheme.colors.border,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),

                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.colors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.payments_outlined,
                                size: 20,
                                color: AppTheme.colors.primary,
                              ),
                            ),

                            title: Row(
                              children: [
                                Text(
                                  "${_formatMonth(salary.month)} ${salary.year}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                if (isCurrent) ...[
                                  const SizedBox(width: 8),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.colors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Actuel",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.colors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _formatAr.format(salary.amount),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.colors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }
}
