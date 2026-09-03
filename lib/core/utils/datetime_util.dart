import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

extension DateTimeExtension on DateTime {
  /// Renvoie le numéro de semaine compatible avec le `strftime('%W', date)` de SQLite (00 à 53)
  int get weekNumber {
    // 1er janvier de l'année en cours
    final firstDayOfYear = DateTime(year, 1, 1);

    // Trouve le premier LUNDI de l'année (début de la semaine 01 dans SQLite %W)
    int daysUntilFirstMonday =
        (DateTime.monday - firstDayOfYear.weekday + 7) % 7;
    final firstMonday = firstDayOfYear.add(
      Duration(days: daysUntilFirstMonday),
    );

    // Si la date est située avant le premier lundi de l'année, SQLite la classe en semaine 0
    if (isBefore(firstMonday)) {
      return 0;
    }

    // Calcule le nombre de semaines écoulées depuis le premier lundi
    final differenceInDays = difference(firstMonday).inDays;
    return (differenceInDays / 7).floor() + 1;
  }

  String toDateString(){
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}

class DatetimeUtil {
  static final DateTime now = DateTime.now();
  static final DateFormat _formater = DateFormat.yMMMd("fr_FR");

  static int getNowDay() {
    return now.day;
  }

  static int getNowMonth() {
    return now.month;
  }

  static int getNowYear() {
    return now.year;
  }

  static String getFormatedDay() {
    return now.day >= 10 ? now.day.toString() : "0${now.day}";
  }

  static String getFormatedMonth() {
    return now.month >= 10 ? now.month.toString() : "0${now.month}";
  }

  static Future<String> getDate() async {
    await initializeDateFormatting('fr_FR', null);

    DateTime maintenant = DateTime.now();
    String dateFormatee = DateFormat(
      'EEEE d MMMM yyyy',
      'fr_FR',
    ).format(maintenant);

    return dateFormatee;
  }

  static String formatDate(DateTime date) {
    return _formater.format(date);
  }

  static int getCurrentWeekNumber() {
    return now.weekNumber;
  }

  static String formatNumber(int number) {
    return number >= 10 ? number.toString() : "0$number";
  }
}
