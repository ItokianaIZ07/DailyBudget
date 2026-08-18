import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/core/utils/datetime_util.dart';

class ExpenseCard extends StatelessWidget {
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final VoidCallback onDelete;

  final _formatAr = CurrencyUtil.getFormater();

  ExpenseCard({
    required this.description,
    required this.amount,
    required this.category,
    required this.onDelete,
    required this.date,
    super.key,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer la dépense ?"),
          content: const Text(
            "Cette action est irréversible. Voulez-vous vraiment supprimer cette dépense ?",
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
    return Card(
      color: AppTheme.colors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Partie gauche
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.colors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "$category.${DatetimeUtil.formatDate(date)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.colors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Partie droite
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatAr.format(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: ()async {
                    await _confirmDelete(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.colors.danger,
                  tooltip: "Supprimer",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
