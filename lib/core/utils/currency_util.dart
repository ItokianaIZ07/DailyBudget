import 'package:intl/intl.dart';

class CurrencyUtil {
  static NumberFormat getFormater(){
    return NumberFormat.currency(locale: 'fr_FR', symbol: 'Ar');
  }
}