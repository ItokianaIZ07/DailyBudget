import 'package:gestion_depenses/models/option_result.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/category_limit.dart';
import 'package:gestion_depenses/repositories/category_repository.dart';
import 'package:gestion_depenses/repositories/category_limit_repository.dart';

class CategoryService {
  static Future<OperationResult> insert(
    String name,
    String color,
    String amount,
  ) async {
    
    OperationResult result = OperationResult(success: false, message: "");

    if (!_isCategoryNameValid(name)) {
      String message = "Veuillez entrer le nom de la catégorie";
      result.message = message;
      return result;
    }
    if (!_isColorValid(color)) {
      String message = "Veuillez choisir une couleur";
      result.message = message;
      return result;
    }
    if (!_isAmountValid(amount)) {
      String message = "Veuillez entrer un nombre positif pour la limite mensuel";
      result.message = message;
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
}
