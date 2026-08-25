import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';

class SalaryForm extends StatefulWidget {
  const SalaryForm({super.key});

  @override
  State<SalaryForm> createState() => _SalaryFormState();
}

class _SalaryFormState extends State<SalaryForm> {
  final _formKey = GlobalKey<FormState>();
  final _salaryController = TextEditingController();

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final salary = double.parse(_salaryController.text);

    Navigator.of(context).pop(salary);
  }

  String? _checkValue(double? value) {
    if (value == null) {
      return 'Veuillez entrer un montant valide';
    }

    if (value <= 0) {
      return 'Le salaire doit être supérieur à 0';
    }
    return null;
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
            const Text('Veuillez renseigner votre salaire pour ce mois.'),

            const SizedBox(height: 20),

            TextFormField(
              controller: _salaryController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                icon: Icon(Icons.payments_rounded),
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
        Center(
          child: FilledButton(onPressed: _submit, child: const Text('Enregistrer')),
        )
      ],
    );
  }
}
