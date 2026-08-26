import 'package:gestion_depenses/core/utils/datetime_util.dart';

class DailyBudget {
  int? id;
  final DateTime date;
  double amount;

  DailyBudget({
    this.id,
    required this.date,
    required this.amount
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'date': date.toDateString(),
      'amount': amount
    };
  }

  factory DailyBudget.fromMap(Map<String, dynamic> map){
    return DailyBudget(
      id: map["id"],
      date: DateTime.parse(map["date"]),
      amount: map["amount"]
    );
  }
}