import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DatetimeUtil {

  static final DateTime now = DateTime.now();

  static int getNowDay(){
    return now.day;
  }

  static int getNowMonth(){
    return now.month;
  }

  static int getNowYear(){
    return now.year;
  }

  static String getFormatedDay(){
    return now.day >= 10? now.day.toString() : "0${now.day}";
  }

  static String getFormatedMonth(){
    return now.month >= 10? now.month.toString() : "0${now.month}";
  }

  static Future<String> getDate() async {
    await initializeDateFormatting('fr_FR', null);
    
    DateTime maintenant = DateTime.now();
    String dateFormatee = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(maintenant);
    
    return dateFormatee;
  }
}