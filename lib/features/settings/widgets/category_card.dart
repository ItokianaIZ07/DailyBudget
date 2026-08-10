import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/color_utils.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/models/category_with_limit.dart';

class CategoryCard extends StatelessWidget {
  final _formatAr = CurrencyUtil.getFormater();
  final CategoryWithLimit _category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  CategoryCard({
    required this._category,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  Future<void> _confirmDelete(
    BuildContext context,
    CategoryWithLimit category,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer la catégorie ?"),
          content: const Text(
            "Cette action supprimera aussi les dépenses associés. Voulez-vous vraiment supprimer cette dépense ?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Annuler"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onDelete.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _category.toMap()['name'],
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.colors.text,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Text("Limite mensuelle "),
                  Text(
                    _formatAr.format(_category.categoryLimit.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.colors.text,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: parseColor(_category.toMap()['color']),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              color: AppTheme.colors.primary,
            ),

            IconButton(
              onPressed: () {
                _confirmDelete(context, _category);
              },
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.colors.danger,
            ),
          ],
        ),
      ],
    );
  }
}
