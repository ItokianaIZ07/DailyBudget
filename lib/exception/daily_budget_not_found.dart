import 'package:gestion_depenses/core/utils/datetime_util.dart';

class DailyBudgetNotFound implements Exception {
  final DateTime date;

  DailyBudgetNotFound(this.date);

  @override
  String toString() {
    return "Aucun budget n'a été fixé pour la date ${date.toDateString()}";
  }
}