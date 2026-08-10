import 'package:flutter/material.dart';
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
    return ListTile(
      title: Text(_category.toMap()['name']),

      subtitle: Text(
        "Limite mensuel ${_formatAr.format(_category.toMap()['limit'])}",
      ),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
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
            tooltip: "Modifier",
          ),

          IconButton(
            onPressed: () {
              _confirmDelete(context, _category);
            },
            icon: const Icon(Icons.delete_outline),
            tooltip: "Supprimer",
          ),
        ],
      ),
    );
  }
}
