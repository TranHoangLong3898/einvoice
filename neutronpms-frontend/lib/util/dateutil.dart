import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

class DateUtil {
  DateUtil._();

  /// Return with format: ``yyyyMMdd``
  static String dateToShortString(DateTime date) {
    String month = date.month.toString();
    if (date.month < 10) month = "0$month";
    String day = date.day.toString();
    if (date.day < 10) day = "0$day";
    return "${date.year}$month$day";
  }

  /// Return with format: ``yyyyMM``
  static String dateToShortStringYearMonth(DateTime date) {
    String month = date.month.toString();
    if (date.month < 10) month = "0$month";
    return "${date.year}$month";
  }

  /// Return with format: ``dd``
  static String dateToShortStringDay(DateTime date) {
    String day = date.day.toString();
    if (date.day < 10) day = "0$day";
    return day;
  }

  /// Return with format: ``dd/MM/yyyy``
  static String dateToString(DateTime date) {
    String month = date.month.toString();
    if (date.month < 10) month = "0$month";
    String day = date.day.toString();
    if (date.day < 10) day = "0$day";
    return "$day/$month/${date.year}";
  }

  /// Return with format: ``yyyy-MM-dd``
  static String dateToHLSString(DateTime date) {
    String month = date.month.toString();
    if (date.month < 10) month = "0$month";
    String day = date.day.toString();
    if (date.day < 10) day = "0$day";
    return "${date.year}-$month-$day";
  }

  /// Return with format: ``dd-MM-yyyy``
  static String dateToStringDDMMYYY(DateTime date) {
    String month = date.month.toString();
    if (date.month < 10) month = "0$month";
    String day = date.day.toString();
    if (date.day < 10) day = "0$day";
    return "$day-$month-${date.year}";
  }

  /// Return with format: ``dd/MM/yyyy``
  static String dateToDayMonthYearString(DateTime? date) {
    if (date == null) return "";
    String month = date.month.toString();
    if (date.month < 10) month = "0$month";
    String day = date.day.toString();
    if (date.day < 10) day = "0$day";
    return "$day/$month/${date.year}";
  }

  /// Return with format: ``dd/MM``
  static String dateToDayMonthString(DateTime date) {
    String month = date.month.toString();
    if (date.month < 10) month = "0$month";
    String day = date.day.toString();
    if (date.day < 10) day = "0$day";
    return "$day/$month";
  }

  /// Return with format: ``dd/MM hh:mm``
  static String dateToDayMonthHourMinuteString(DateTime date) {
    String month = date.month.toString();
    if (date.month < 10) month = "0$month";
    String day = date.day.toString();
    if (date.day < 10) day = "0$day";
    String hour = date.hour.toString();
    if (date.hour < 10) hour = "0$hour";
    String minute = date.minute.toString();
    if (date.minute < 10) minute = "0$minute";
    return "$day/$month $hour:$minute";
  }

  /// Return with format: ``dd/MM/yyyy hh:mm``
  static String dateToDayMonthYearHourMinuteString(DateTime date) {
    String month = date.month.toString();
    if (date.month < 10) month = "0$month";
    String day = date.day.toString();
    if (date.day < 10) day = "0$day";
    String hour = date.hour.toString();
    if (date.hour < 10) hour = "0$hour";
    String minute = date.minute.toString();
    if (date.minute < 10) minute = "0$minute";
    return "$day/$month/${date.year} $hour:$minute";
  }

  /// Return with format: ``MM/yyyy``
  static String dateToMonthYearString(DateTime date) {
    String month = date.month.toString();
    if (date.month < 10) month = "0$month";

    return "$month/${date.year}";
  }

  /// Return with format: ``hh/mm``
  static String dateToHourMinuteString(DateTime date) {
    String hour = date.hour.toString();
    if (date.hour < 10) hour = "0$hour";
    String minute = date.minute.toString();
    if (date.minute < 10) minute = "0$minute";
    return "$hour:$minute";
  }

  /// Return the length of month
  static int getLengthOfMonth(DateTime date) {
    return [1, 3, 5, 7, 8, 10, 12].contains(date.month)
        ? 31
        : [4, 6, 9, 11].contains(date.month)
            ? 30
            : date.year % 4 == 0
                ? 29
                : 28;
  }

  /// Compare 2 DateTime. Return ``true`` if equal
  static bool equal(DateTime date1, DateTime date2) =>
      (date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day);

  static DateTime to12h(DateTime date) =>
      DateTime(date.year, date.month, date.day, 12);

  static DateTime to0h(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0);
  }

  static DateTime to24h(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59);

  static DateTime to12hDayAddOne(DateTime date) =>
      DateTime(date.year, date.month, date.day + 1, 12);

  ///return dateTime to 14h for check in booking
  static DateTime to14h(DateTime date) =>
      DateTime(date.year, date.month, date.day, 14, 00);

  /// Return the first day of the month
  static DateTime getFirstDateOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1, 12);
  }

  /// Return the last day of the month
  static DateTime getLastDateOfMonth(DateTime date) {
    return DateTime(date.year, date.month, getLengthOfMonth(date), 12);
  }

  /// Return the days between [inDay] and [outDay] (include [inDay])
  static List<DateTime> getStaysDay(DateTime inDay, DateTime outDay) {
    List<DateTime> staysDay = [];
    if (outDay.difference(inDay).inDays == 0) return [inDay];
    for (var i = 0; i < outDay.difference(inDay).inDays; i++) {
      staysDay.add(inDay.add(Duration(days: i)));
    }
    return staysDay;
  }

  static String addMonthToYearMonth(String yearMonth) {
    return dateToShortStringYearMonth(DateTime(
        int.parse(yearMonth.substring(0, 4)),
        int.parse(yearMonth.substring(4, 6)) + 1,
        1,
        12));
  }

  static String getDifferenceFromNow(DateTime date) {
    Duration duration = DateTime.now().difference(date);
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_SECONDS_AGO)}';
    }
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_MINUTES_AGO)}';
    }
    if (duration.inHours < 24) {
      return '${duration.inHours} ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_HOURS_AGO)}';
    }
    if (duration.inDays <= 7) {
      return '${duration.inDays} ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_DAYS_AGO)}';
    }
    return '+${duration.inDays} ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_DAYS_AGO)}';
  }

  /// Convert a string with format ``yyyyMMdd`` to DateTime with hour = 12
  static DateTime shortStringToDate12h(String yyyyMMdd) {
    return DateTime(
        int.parse(yyyyMMdd.substring(0, 4)),
        int.parse(yyyyMMdd.substring(4, 6)),
        int.parse(yyyyMMdd.substring(6, 8)),
        12);
  }

  /// Convert a string with format ``ddMMyyy`` to DateTime with hour = 12
  static DateTime shortStringDDMMYYYToDate12h(String ddMMyyy) {
    return DateTime(
        int.parse(ddMMyyy.substring(4)),
        int.parse(ddMMyyy.substring(2, 4)),
        int.parse(ddMMyyy.substring(0, 2)),
        12);
  }

  /// Return the list of month between [start] and [end]
  ///
  /// #### [start] and [end] must be formatted: ``yyyyMM`` and [end] > [start]
  /// For example:
  /// [start] = ``202211`` & [end] = ``202303``
  ///
  /// Result is [``202212``, ``202301``, ``202302``]
  static List<String> getBreakMonths(String start, String end) {
    List<String> result = [];

    int startMonth = int.parse(start.substring(4));
    int startYear = int.parse(start.substring(0, 4));
    int endMonth = int.parse(end.substring(4));
    int endYear = int.parse(end.substring(0, 4));

    if (startYear == endYear) {
      for (int i = startMonth + 1; i < endMonth; i++) {
        if (i < 10) {
          result.add('${startYear}0$i');
        } else {
          result.add('$startYear$i');
        }
      }
    } else {
      for (int i = startMonth + 1; i <= 12; i++) {
        if (i < 10) {
          result.add('${startYear}0$i');
        } else {
          result.add('$startYear$i');
        }
      }
      for (int year = startYear + 1; year < endYear; year++) {
        for (int month = 1; month <= 12; month++) {
          if (month < 10) {
            result.add('${year}0$month');
          } else {
            result.add('$year$month');
          }
        }
      }
      for (int i = 1; i < endMonth; i++) {
        if (i < 10) {
          result.add('${endYear}0$i');
        } else {
          result.add('$endYear$i');
        }
      }
    }

    return result;
  }

  static List<String> listMonth = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12"
  ];
}

class TimeOfDayUtil {
  static String timeOfDayToString(TimeOfDay timeOfDay) =>
      "${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}";

  static int compare(TimeOfDay a, TimeOfDay b) =>
      (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);

  static TimeOfDay stringToTimeOfDay(String value) {
    List<String> valueArray = value.split(':');
    return TimeOfDay(
        hour: int.parse(valueArray[0]), minute: int.parse(valueArray[1]));
  }
}
