import "category.dart";
import "category_limit.dart";

class CategoryWithLimit {
  final Category category;
  final CategoryLimit categoryLimit;

  CategoryWithLimit({
    required this.category,
    required this.categoryLimit
  });

  Map<String, dynamic> toMap() {
    return {
      'id': category.id,
      'name': category.name,
      'color': category.color,
      'limit': categoryLimit.amount
    };
  }
}