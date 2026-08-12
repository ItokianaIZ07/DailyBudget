import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/color_utils.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/services/category_service.dart';

class SortWidget extends StatefulWidget {
  Category? selectedCategory;
  final ValueChanged<Category?> onCategorySelected;
  final Function(String)? onSearch;

  SortWidget({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onSearch,
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
      child: TextField(
        decoration: InputDecoration(
          hintText: "Rechercher une dépense...",
          hintStyle: TextStyle(color: AppTheme.colors.textMuted, fontSize: 14),

          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.colors.textMuted,
            size: 21,
          ),

          suffixIcon: _editingController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _editingController.clear();
                  widget.onSearch?.call(''); 
                  setState(() {}); 
                },
              )
            : null,

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 13,
          ),
        ),
        controller: _editingController,
        onChanged: (value) => {
          widget.onSearch?.call(value)
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
  void dispose(){
    _editingController.dispose();
    super.dispose();
  }
}
