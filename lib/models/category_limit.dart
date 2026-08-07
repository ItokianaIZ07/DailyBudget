import 'package:gestion_depenses/models/category.dart';

class CategoryLimit {
  int? id;
  final double amount;
  final Category category;

  CategoryLimit({
    this.id,
    required this.amount,
    required this.category
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category_id': category.id,
    };
  }

  factory CategoryLimit.fromMap(Map<String, dynamic> map, Category category) {
    return CategoryLimit(
      id: map['id'],
      amount: map['amount'],
      category: category,
    );
  }
}