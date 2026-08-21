import 'package:flutter/material.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/expense.dart';
import 'package:gestion_depenses/services/expense_service.dart';

class EditModal extends StatefulWidget {
  final List<Category> categories;
  final Expense expense;

  const EditModal({required this.categories, required this.expense, super.key});

  @override
  State<EditModal> createState() => _EditModalState();
}

class _EditModalState extends State<EditModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  late DateTime _selectedDate;
  late Category _selectedCategory;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );

    _amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );

    _selectedDate = widget.expense.date;
    _selectedCategory = widget.expense.category;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date == null) {
      return;
    }

    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _updateExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final description = _descriptionController.text.trim();

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));

    if (amount == null) {
      return;
    }

    final editedExpense = Expense(
      id: widget.expense.id,
      description: description,
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      await ExpenseService.updateExpense(editedExpense);

      if (!mounted) return;

      // true = modification effectuée
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de modifier la dépense')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --------------------------------
              // TITRE
              // --------------------------------
              const Text(
                'Modifier la dépense',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _descriptionController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une description';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  suffixText: 'Ar',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un montant';
                  }

                  final amount = double.tryParse(value.replaceAll(',', '.'));

                  if (amount == null || amount <= 0) {
                    return 'Veuillez entrer un montant valide';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _selectedCategory.id,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedCategory = widget.categories.firstWhere(
                            (category) => category.id == value,
                          );
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez choisir une catégorie';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,

                leading: const Icon(Icons.calendar_month_outlined),

                title: const Text('Date'),

                subtitle: Text(_formatDate(_selectedDate)),

                trailing: const Icon(Icons.edit_calendar_outlined),

                enabled: !_isLoading,

                onTap: _selectDate,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateExpense,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
