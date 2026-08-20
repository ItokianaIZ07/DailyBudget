import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/models/month.dart';
import 'package:gestion_depenses/repositories/expense_repository.dart';

class HistoryService {
  static Future<List<Month>> getAllMonths() async{
    String year = DatetimeUtil.getNowYear().toString();
    return await ExpenseRepository.getListMonths(year);
  }

  static Future<double> getExpenseByPeriod(String? month, int year) async{
    if(month == null){
      return await ExpenseRepository.getExpenseOfTheYear(year.toString());
    }
    return await ExpenseRepository.getExpenseOfTheMonth(month, year.toString());
  }
}