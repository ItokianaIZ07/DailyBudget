import 'package:flutter/material.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/repositories/category_repository.dart';

class CategoriesPage extends StatefulWidget {
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try{
      List<Category> categories = await CategoryRepository.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    }catch(e){
      print("Une erreur est survenue lors de la récupération des données de catégories ${e}");
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
    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return ListTile(
          title: Text(category.name),
          subtitle: Text('Color: ${category.color}'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: _buildBody(),
    );
  }
}
