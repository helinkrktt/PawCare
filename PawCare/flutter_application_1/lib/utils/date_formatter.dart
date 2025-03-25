// lib/utils/date_formatter.dart

import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime? date, {String format = 'dd/MM/yyyy'}) {
    if (date == null) {
      return '';
    }
    return DateFormat(format).format(date);
  }

    // Haftanın gününü alma
    static String getDayOfWeek(DateTime date) {
      return DateFormat('EEEE').format(date); // "Monday", "Tuesday"...
    }

    //Daha okunabilir tarih formatı
    static String getVerboseDate(DateTime date){
        return DateFormat('MMMM d, y').format(date); // "December 19, 2024"
    }

    //Zaman formatı
    static String getTime(DateTime date){
      return DateFormat('Hm').format(date); // "14:30" (24-saat formatı)
    }

}