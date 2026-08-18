import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/color_utils.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/services/category_service.dart';

class SortWidget extends StatefulWidget {
  Category? selectedCategory;
  final ValueChanged<Category?> onCategorySelected;
  int selectedYear;
  final Function(String)? onSearch;

  SortWidget({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onSearch,
    required this.selectedYear,
    super.key,
  });

  @override
  State<SortWidget> createState() => _SortWidgetState();
}

class _SortWidgetState extends State<SortWidget> {
  List<Category> _categories = [];
  late final TextEditingController _editingController;

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getAllCategories();

      setState(() {
        _categories.clear();
        _categories.addAll(categories);
      });
    } catch (e) {
      debugPrint('Erreur chargement des dépenses : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _loadCategories();
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppTheme.radius.md),
        border: Border.all(color: AppTheme.colors.border, width: 1),
      ),
      child: SearchBar(
        controller: _editingController,
        hintText:
            "Rechercher une dépense ${widget.selectedYear >= 0 ? "de ${widget.selectedYear}" : ""}...",
        hintStyle: WidgetStateProperty.all(
          TextStyle(color: AppTheme.colors.textMuted, fontSize: 14),
        ),
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(AppTheme.colors.surface),

        leading: Icon(Icons.search, color: AppTheme.colors.textMuted, size: 21),

        trailing: [
          if (_editingController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: AppTheme.colors.textMuted),
              onPressed: () {
                _editingController.clear();
                widget.onSearch?.call('');
                setState(() {});
              },
            ),
        ],

        onChanged: (value) {
          widget.onSearch?.call(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String name,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppTheme.colors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppTheme.colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),

            const SizedBox(width: 7),

            Text(
              name,
              style: TextStyle(
                color: isSelected ? color : AppTheme.colors.text,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Toutes
          _buildCategoryChip(
            name: "Toutes",
            color: AppTheme.colors.primary,
            isSelected: widget.selectedCategory == null,
            onTap: () {
              widget.onCategorySelected(null);
            },
          ),

          const SizedBox(width: 8),

          // Catégories
          ..._categories.map((Category category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildCategoryChip(
                name: category.name,
                color: parseColor(category.color!),
                isSelected: widget.selectedCategory?.id == category.id,
                onTap: () {
                  widget.onCategorySelected(category);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [_buildSearchField(), _buildCategoryFilter()],
    );
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }
}
