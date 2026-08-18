import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/color_utils.dart';
import 'package:gestion_depenses/models/category_with_limit.dart';

class ExpenseHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const ExpenseHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.colors.textMuted,
          ),
        ),
      ],
    );
  }
}

class ExpenseInputCard extends StatelessWidget {
  final String label;
  final Widget child;

  const ExpenseInputCard({
    required this.label,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius.sm),
        border: Border.all(color: AppTheme.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppTheme.colors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class ExpenseCategoryCard extends StatelessWidget {
  final CategoryWithLimit? selectedCategory;
  final VoidCallback onTap;

  const ExpenseCategoryCard({
    required this.selectedCategory,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius.sm),
          border: Border.all(color: AppTheme.colors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catégorie', style: TextStyle(color: AppTheme.colors.textMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (selectedCategory == null)
                    Text('Choisir une catégorie', style: TextStyle(color: AppTheme.colors.text))
                  else
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: parseColor(selectedCategory!.category.color ?? '#FFFFFF'),
                          radius: 16,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedCategory!.category.name, style: TextStyle(color: AppTheme.colors.text, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Limite ${selectedCategory!.categoryLimit.amount.toStringAsFixed(0)} Ar', style: TextStyle(color: AppTheme.colors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AppTheme.colors.textMuted),
          ],
        ),
      ),
    );
  }

  
}

class ExpenseDateCard extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const ExpenseDateCard({
    required this.selectedDate,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius.sm),
          border: Border.all(color: AppTheme.colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date', style: TextStyle(color: AppTheme.colors.textMuted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: TextStyle(color: AppTheme.colors.text, fontSize: 16),
                ),
              ],
            ),
            Icon(Icons.calendar_today, color: AppTheme.colors.primary),
          ],
        ),
      ),
    );
  }
}

class ExpenseActionButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;
  final String label;

  const ExpenseActionButton({
    required this.isSaving,
    required this.onPressed,
    this.label = 'Enregistrer la dépense',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: AppTheme.colors.surface,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius.sm),
          ),
        ),
        onPressed: isSaving ? null : onPressed,
        child: isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label),
      ),
    );
  }
}
