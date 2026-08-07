import 'package:flutter/material.dart';
import 'package:gestion_depenses/models/category_with_limit.dart';
import 'package:gestion_depenses/features/settings/pages/category_form_page.dart';
import 'package:gestion_depenses/services/category_service.dart';
import 'package:intl/intl.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryWithLimit> _categories = [];
  bool _isLoading = true;
  final formatAr = NumberFormat.currency(locale: 'fr_FR', symbol: 'Ar');


  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      List<CategoryWithLimit> categories = await CategoryService.getCategoriesWithLimit();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print(
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

        return ListTile(
          title: Text(category.toMap()['name']),
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _parseColor(category.toMap()['color']),
              shape: BoxShape.circle, 
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          subtitle: Text("Limite mensuel ${formatAr.format(category.toMap()["limit"])}"),
        );
      },
    );
  }

  // Fonction utilitaire pour convertir une chaîne Hex (#XXXXXX ou #XXXXXXXX) en Color Flutter
  Color _parseColor(String hexColor) {
    String hex = hexColor.replaceAll('#', '');

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _openCategoryFormPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryFormPage()),
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
        onPressed: _openCategoryFormPage,
        backgroundColor: Color.fromRGBO(20, 89, 159, 1),
        foregroundColor: Color.fromRGBO(255, 255, 255, 1),
        child: Icon(Icons.add),
      ),
    );
  }
}
