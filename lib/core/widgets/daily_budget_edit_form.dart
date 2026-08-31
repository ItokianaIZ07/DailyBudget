import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/widgets/app_snackbar.dart';
import 'package:gestion_depenses/exception/negative_amount_value.dart';
import 'package:gestion_depenses/models/daily_budget.dart';
import 'package:gestion_depenses/services/daily_budget_service.dart';

class DailyBudgetEditForm extends StatefulWidget {
  final DailyBudget? budget;
  final VoidCallback? onEdited;

  const DailyBudgetEditForm({this.budget, this.onEdited, super.key});

  @override
  State<DailyBudgetEditForm> createState() => _DailyBudgetEditFromState();
}

class _DailyBudgetEditFromState extends State<DailyBudgetEditForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _budgetController = TextEditingController();

  late DateTime _selectedDate;

  String? _checkValue(double? value) {
    if (value == null) {
      return 'Veuillez entrer un montant valide';
    }

    if (value <= 0) {
      return 'Le budget doit être supérieur à 0';
    }

    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final budget = double.parse(_budgetController.text.replaceAll(',', '.'));

    try {
      if (widget.budget != null) {
        widget.budget!.amount = budget;
        widget.budget!.date = _selectedDate;

        await DailyBudgetService.updateBudget(widget.budget!);
      } else {
        final DailyBudget newBudget = DailyBudget(
          date: _selectedDate,
          amount: budget,
        );

        try {
          await DailyBudgetService.saveBudget(newBudget);
        } on NegativeAmountValue catch (e) {
          if (context.mounted) {
            AppSnackBar.error(context, "$e");
            return;
          }
        }
      }

      if (context.mounted) {
        AppSnackBar.success(context, "Budget enregistré");
        widget.onEdited?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint(
        "Une erreur est survenue lors de l'enregistrement "
        "du budget quotidien : $e",
      );

      if (context.mounted) {
        AppSnackBar.error(
          context,
          "Erreur lors de l'enregistrement du budget quotidien",
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.budget != null) {
      _budgetController.text = widget.budget!.amount.toString();
      _selectedDate = widget.budget!.date;
    } else {
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day);
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        "${_selectedDate.day.toString().padLeft(2, '0')}/"
        "${_selectedDate.month.toString().padLeft(2, '0')}/"
        "${_selectedDate.year}";

    return AlertDialog(
      title: Text(
        widget.budget == null ? "Budget quotidien" : "Modification du budget",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Date du budget"),

            const SizedBox(height: 8),

            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(formattedDate),
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Budget',
                hintText: 'Exemple : 1500000',
                suffixText: 'Ar',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez renseigner votre budget';
                }

                final budget = double.tryParse(value.replaceAll(',', '.'));

                return _checkValue(budget);
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: widget.budget == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            widget.budget != null
                ? FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.colors.danger,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Annuler"),
                  )
                : Divider(),
            TextButton.icon(
              onPressed: () async {
                await _submit(context);
              },
              label: Text(
                "Définir le budget",
                style: TextStyle(color: AppTheme.colors.primarySoft),
              ),
              icon: Icon(
                Icons.check_circle,
                color: AppTheme.colors.primarySoft,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
