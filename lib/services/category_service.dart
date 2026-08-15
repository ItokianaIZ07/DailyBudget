import 'package:flutter/cupertino.dart';
import 'package:gestion_depenses/models/option_result.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/category_limit.dart';
import 'package:gestion_depenses/repositories/category_repository.dart';
import 'package:gestion_depenses/repositories/category_limit_repository.dart';
import 'package:gestion_depenses/models/category_with_limit.dart';

class CategoryService {
  static Future<OperationResult> insert(
    String name,
    String color,
    String amount,
  ) async {
    
    OperationResult result = OperationResult(success: false, message: "");

    if(!_validateFieldsValue(result, name, color, amount)){
      return result;
    }

    Category category = Category(
      name: name,
      color: color,
    );

    try{
      category.id = await CategoryRepository.createCategory(category);
      CategoryLimit limit = CategoryLimit(
        amount: double.parse(amount),
        category: category,
      );
      await CategoryLimitRepository.createCategoryLimit(limit);
    }catch(e){
      result.message = "Le catégorie $name existe déjà";
      return result;
    }

    result.success = true;
    result.message = "Catégorie inseré avec succès";
    return result;
  }

  static bool _isCategoryNameValid(String name) {
    try {
      double.parse(name);
      return false;
      // ignore: empty_catches
    } catch (e) {}
    return name.isNotEmpty;
  }

  static bool _isColorValid(String color) {
    return color.isNotEmpty;
  }

  static bool _isAmountValid(String amount) {
    try {
      double montant = double.parse(amount);
      if (montant < 0) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return amount.isNotEmpty;
  }

  static Future<List<CategoryWithLimit>> getCategoriesWithLimit() async{
    return await CategoryRepository.getCategoriesWithLimit();
  }

  static bool _validateFieldsValue(OperationResult result, String name, String color, String amount){
    if (!_isCategoryNameValid(name)) {
      String message = "Veuillez entrer le nom de la catégorie";
      result.message = message;
      return false;
    }
    if (!_isColorValid(color)) {
      String message = "Veuillez choisir une couleur";
      result.message = message;
      return false;
    }
    if (!_isAmountValid(amount)) {
      String message = "Veuillez entrer un nombre positif pour la limite mensuel";
      result.message = message;
      return false;
    }
    return true;
  }

  static Future<OperationResult> updateCategory(String name, String color, String amount, int categoryId, int limitId) async{
    OperationResult result = OperationResult(success: false, message: "");

    if(!_validateFieldsValue(result, name, color, amount)){
      return result;
    }

    Category category = Category(
      id: categoryId,
      name: name,
      color: color
    );

    CategoryLimit categoryLimit = CategoryLimit(id:limitId, amount:  double.parse(amount), category: category);

    try{
      await CategoryRepository.updateCategory(category);
      await CategoryLimitRepository.updateCategoryLimit(categoryLimit);

      result.success = true;
      result.message = "Les information de la catégorie ${category.name} a été modifié";
    }catch(e){
      debugPrint("Erreur lors de la modification de la catégorie ${category.name}");
    }
    return result;
  }

  static Future<void> deleteCategory(CategoryWithLimit categoryLimit) async{
    Category category = categoryLimit.category;
    CategoryLimit limit = categoryLimit.categoryLimit;
    try{
      await CategoryRepository.deleteCategory(category);
      await CategoryLimitRepository.deleteCategoryLimit(limit);
    }catch(e){
      debugPrint("Une erreur est survenue lors de la suppression de ${category.name}");
    }
  }

  static Future<List<Category>> getAllCategories() async{
    return await CategoryRepository.getAllCategories();
  }
}
