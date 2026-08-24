class DailyBudget {
  int? id;
  final DateTime date;
  final double amount;

  DailyBudget({
    this.id,
    required this.date,
    required this.amount
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'date': date,
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