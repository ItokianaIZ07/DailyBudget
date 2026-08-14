import 'package:flutter/cupertino.dart';
import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/repositories/expense_repository.dart';

class StatisticService {
  static Future<double> _getTotalExpenseOfWeek() async{
    String week = DatetimeUtil.formatNumber(DatetimeUtil.getCurrentWeekNumber());
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear());

    return await ExpenseRepository.getExpenseOfTheWeek(week, year);
  }

  static Future<double> _getTotalExpenseOfMonth() async{
    String month = DatetimeUtil.getFormatedMonth();
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear());

    return await ExpenseRepository.getExpenseOfTheMonth(month, year);
  }

  static Future<double> _getTotalExpenseOfYear() async{
    String year = DatetimeUtil.formatNumber(DatetimeUtil.getNowYear());
    
    return await ExpenseRepository.getExpenseOfTheYear(year);
  }

  static Future<double> getTotalExpenseByOption(int option) async{
    switch(option){
      case 0:
        return await _getTotalExpenseOfWeek();
      case 1:
        return await _getTotalExpenseOfMonth();
      default:
        return await _getTotalExpenseOfYear();
    }
  }
}