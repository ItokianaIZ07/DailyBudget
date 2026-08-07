import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/features/expense/widgets/expense_widgets.dart';
import 'package:gestion_depenses/models/category_with_limit.dart';
import 'package:gestion_depenses/models/expense.dart';
import 'package:gestion_depenses/services/category_service.dart';
import 'package:gestion_depenses/services/expense_service.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<CategoryWithLimit> _categories = [];
  CategoryWithLimit? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await CategoryService.getCategoriesWithLimit();
      setState(() {
        _categories.clear();
        _categories.addAll(categories);
      });
    } catch (e) {
      debugPrint('Erreur chargement catégories: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectCategory() async {
    if (_categories.isEmpty) {
      return;
    }

    final CategoryWithLimit?
    chosen = await showModalBottomSheet<CategoryWithLimit>(
      context: context,
      backgroundColor: AppTheme.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radius.lg),
        ),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              'Choisir une catégorie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.colors.text,
              ),
            ),
            const SizedBox(height: 12),
            ..._categories.map((category) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _parseColor(
                    category.category.color ?? '#FFFFFF',
                  ),
                  radius: 18,
                ),
                title: Text(
                  category.category.name,
                  style: TextStyle(color: AppTheme.colors.text),
                ),
                subtitle: Text(
                  'Limite ${category.categoryLimit.amount.toStringAsFixed(0)} Ar',
                  style: TextStyle(color: AppTheme.colors.textMuted),
                ),
                onTap: () => Navigator.of(context).pop(category),
              );
            }),
            const SizedBox(height: 20),
          ],
        );
      },
    );

    if (chosen != null) {
      setState(() {
        _selectedCategory = chosen;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.colors.primary,
              onPrimary: AppTheme.colors.surface,
              onSurface: AppTheme.colors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    final String amountText = _amountController.text.trim();
    final String description = _descriptionController.text.trim();

    final validation = ExpenseService.validateExpenseInput(
      amount: amountText,
      description: description,
      category: _selectedCategory,
    );

    if (!validation.success) {
      _showMessage(validation.message);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final expense = Expense(
        description: description,
        amount: double.parse(amountText.replaceAll(',', '.')),
        category: _selectedCategory!.category,
        date: _selectedDate,
      );

      final result = await ExpenseService.insertExpense(expense);
      if (!result.success) {
        _showMessage(result.message);
        return;
      }

      _showMessage(result.message, success: true);
      _clearForm();
    } catch (e) {
      _showMessage('Impossible d’enregistrer la dépense');
      debugPrint('Erreur sauvegarde dépense: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedDate = DateTime.now();
    });
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? AppTheme.colors.success
            : AppTheme.colors.danger,
      ),
    );
  }

  Color _parseColor(String hexColor) {
    String hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
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
                  children: [
                    const ExpenseHeader(
                      title: 'Nouvelle dépense',
                      subtitle: 'Enregistrez votre dépense et associez-la à une catégorie',
                    ),
                    const SizedBox(height: 24),
                    ExpenseInputCard(
                      label: 'Montant',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.colors.text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ExpenseInputCard(
                      label: 'Description',
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Ex: Courses, carburant, cinéma...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: AppTheme.colors.textMuted,
                          ),
                        ),
                        style: TextStyle(color: AppTheme.colors.text),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ExpenseCategoryCard(
                      selectedCategory: _selectedCategory,
                      onTap: _selectCategory,
                    ),
                    const SizedBox(height: 16),
                    ExpenseDateCard(
                      selectedDate: _selectedDate,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 32),
                    ExpenseActionButton(
                      isSaving: _isSaving,
                      onPressed: _saveExpense,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

}
