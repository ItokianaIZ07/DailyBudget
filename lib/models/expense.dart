import "package:gestion_depenses/models/category.dart";

class Expense {
  final int? id;
  final String description;
  final double amount;
  final Category category;
  final DateTime date;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category_id': category.id,
      'date': date.toIso8601String()
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, {required Category category}){
    return Expense(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      category: category,
      date: DateTime.parse(map['date'])
    );
  }
}