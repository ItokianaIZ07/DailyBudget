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
            "Cette action supprimera aussi les dépenses associées. "
            "Voulez-vous vraiment supprimer cette catégorie ?",
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
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = _category.toMap()['name'] as String;
    final categoryColor = parseColor(_category.toMap()['color']);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.shadow.withValues(alpha: 0.15),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.colors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Wrap(
                  spacing: 4,
                  children: [
                    Text(
                      "Limite mensuelle",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.colors.textMuted,
                      ),
                    ),
                    Text(
                      _formatAr.format(_category.categoryLimit.amount),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.colors.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),

              const SizedBox(width: 2),

              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 21),
                color: AppTheme.colors.primary,
                visualDensity: VisualDensity.compact,
              ),

              IconButton(
                onPressed: () {
                  _confirmDelete(context, _category);
                },
                icon: const Icon(Icons.delete_outline, size: 21),
                color: AppTheme.colors.danger,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
