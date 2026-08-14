import 'package:gestion_depenses/models/category_with_limit.dart';

class ExpenseCategory {
  final CategoryWithLimit category;
  final double amount;

  ExpenseCategory({
    required this.category,
    required this.amount
  });

  Map<String, dynamic> toMap(){
    Map<String, dynamic> categoryMap = category.toMap();
    return {
      'id': categoryMap['id'],
      'name': categoryMap['name'],
      'color': categoryMap['color'],
      'limit': categoryMap['limit'],
      'amount': amount
    };
  }

}