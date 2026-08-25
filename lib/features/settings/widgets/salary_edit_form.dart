import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/models/monthly_salary.dart';
import 'package:gestion_depenses/services/monthly_salary_service.dart';

class SalaryEditForm extends StatefulWidget {
  final MonthlySalary salary;
  final VoidCallback onEdited;

  const SalaryEditForm({
    required this.onEdited,
    required this.salary,
    super.key,
  });

  @override
  State<SalaryEditForm> createState() => _SalaryEditFormState();
}

class _SalaryEditFormState extends State<SalaryEditForm> {
  final TextEditingController _salaryEditController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _checkValue(double? value) {
    if (value == null) {
      return 'Veuillez entrer un montant valide';
    }

    if (value <= 0) {
      return 'Le salaire doit être supérieur à 0';
    }
    return null;
  }

  Future<void> _submit(MonthlySalary salary, BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final salaryEdited = double.parse(_salaryEditController.text);

    salary.amount = salaryEdited;

    try {
      await MonthlySalaryService.updateSalary(salary);
      widget.onEdited.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Salaire modifié avec succès'),
            backgroundColor: AppTheme.colors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "Une erreur est survenue lors de la modification du salaire mensuel: $e",
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de la modification du salaire'),
            backgroundColor: AppTheme.colors.danger,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _salaryEditController.text = widget.salary.amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Salaire mensuel',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Modification du salaire'),

            const SizedBox(height: 20),

            TextFormField(
              controller: _salaryEditController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                iconColor: AppTheme.colors.primary,
                labelText: 'Salaire',
                hintText: 'Exemple : 1500000',
                suffixText: 'Ar',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez renseigner votre salaire';
                }

                final salary = double.tryParse(value);

                return _checkValue(salary);
              },
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.colors.danger, 
            foregroundColor: Colors.white, 
          ),
          child: const Text("Annuler"),
        ),
        FilledButton(
          onPressed: () {
            _submit(widget.salary, context);
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
