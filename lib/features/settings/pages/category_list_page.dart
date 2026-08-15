import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/features/settings/widgets/category_card.dart';
import 'package:gestion_depenses/models/category_with_limit.dart';
import 'package:gestion_depenses/features/settings/pages/category_form_page.dart';
import 'package:gestion_depenses/models/option_result.dart';
import 'package:gestion_depenses/services/category_service.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryWithLimit> _categories = [];
  bool _isLoading = true;
  final formatAr = CurrencyUtil.getFormater();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<OperationResult> _saveCategory({
    required String name,
    required String color,
    required String amount,
    int? categoryId,
    int? limitId,
  }) async {
    return await CategoryService.insert(name, color, amount);
  }

  Future<OperationResult> _updateCategory({
    required String name,
    required String color,
    required String amount,
    int? categoryId,
    int? limitId,
  }) async {
    return await CategoryService.updateCategory(
      name,
      color,
      amount,
      categoryId!,
      limitId!,
    );
  }

  Future<void> _deleteCategory({required CategoryWithLimit category}) async {
    await CategoryService.deleteCategory(category);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      List<CategoryWithLimit> categories =
          await CategoryService.getCategoriesWithLimit();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        "Une erreur est survenue lors de la récupération des données de catégories $e",
      );
    }
  }

  Widget _buildBody() {
    return _isLoading
        ? _buildLoading()
        : _categories.isEmpty
        ? _buildEmpty()
        : _buildCategoryList();
  }

  Widget _buildLoading() {
    return Center(child: Text("Chargement des catégories"));
  }

  Widget _buildEmpty() {
    return Center(child: Text("Aucune catégorie enregistrer"));
  }

  Widget _buildCategoryList() {
    return ListView.separated(
      itemCount: _categories.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final category = _categories[index];

        return CategoryCard(
          category: category,
          onEdit: (){
            _openCategoryFormPage(
              title: "Modifier la catégorie",
              category: category
            );
          },
          onDelete: () {
            _deleteCategory(category: category);
          },
        );
      },
    );
  }

  Future<void> _openCategoryFormPage({
    required String title,
    CategoryWithLimit? category,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFormPage(
          title: title,
          category: category,
          onSave: category == null ? _saveCategory : _updateCategory,
        ),
      ),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openCategoryFormPage(title: "Nouvelle catégorie");
        },
        backgroundColor: Color.fromRGBO(20, 89, 159, 1),
        foregroundColor: Color.fromRGBO(255, 255, 255, 1),
        child: Icon(Icons.add),
      ),
    );
  }
}
