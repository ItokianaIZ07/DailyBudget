import 'package:gestion_depenses/core/utils/datetime_util.dart';

class DailyBudget {
  int? id;
  DateTime date;
  double amount;
  int notificationSent;

  DailyBudget({
    this.id,
    required this.date,
    required this.amount,
    this.notificationSent = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toDateString(),
      'amount': amount,
      'notification_sent': notificationSent,
    };
  }

  factory DailyBudget.fromMap(Map<String, dynamic> map) {
    return DailyBudget(
      id: map["id"],
      date: DateTime.parse(map["date"] as String),
      amount: (map["amount"] as num).toDouble(),
      notificationSent: (map["notification_sent"] as num?)?.toInt() ?? 0,
    );
  }
}
