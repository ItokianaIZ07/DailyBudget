class MonthlySalary {
  int? id;
  final int month;
  final int year;
  final double amount;

  MonthlySalary({
    this.id,
    required this.month,
    required this.year,
    required this.amount
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'month': month,
      'year': year,
      'amount': amount
    };
  } 

  factory MonthlySalary.fromMap(Map<String, dynamic> map){
    return MonthlySalary(
      id: map["id"],
      month: map["month"],
      year: map["year"],
      amount: map["amount"]
    );
  }
}