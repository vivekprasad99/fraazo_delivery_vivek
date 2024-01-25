import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  Map<String, String> parseDateTimeYMDHM(String? date,
      {String inputFormat = "yyyy-MM-ddTHH:mm"}) {
    if (date.isNullOrEmpty) {
      return {'date': "", 'time': ""};
    }
    final DateFormat inputDateFormat = DateFormat(inputFormat);
    final outPutFormat = inputDateFormat.parse(date!);
    var suffix = "th";
    final int day = outPutFormat.day;
    final digit = day % 10;
    if ((digit > 0 && digit < 4) && (day < 11 || day > 13)) {
      suffix = ["st", "nd", "rd"][digit - 1];
    }
    final DateFormat newDate = DateFormat("d'$suffix' MMM',' yyyy");
    final DateFormat newTime = DateFormat("hh:MM a");
    final String newDateFormatted = newDate.format(outPutFormat);
    final String newTimeFormatted = newTime.format(outPutFormat);

    final Map<String, String> dateTime = {
      'date': newDateFormatted,
      'time': newTimeFormatted
    };
    return dateTime;
  }

  Map<String, String> parseDateTimeYMDHMS(String? date,
      {String inputFormat = "yyyy-MM-ddTHH:mm:ss"}) {
    if (date.isNullOrEmpty) {
      return {'date': "", 'time': ""};
    }
    final DateFormat inputDateFormat = DateFormat(inputFormat);
    final outPutFormat = inputDateFormat.parse(date!);

    final DateFormat newDate = DateFormat("d' 'MMMM',' yyyy");
    final DateFormat newTime = DateFormat("hh:MM a");
    final String newDateFormatted = newDate.format(outPutFormat);
    final String newTimeFormatted = newTime.format(outPutFormat);

    final Map<String, String> dateTime = {
      'date': newDateFormatted,
      'time': newTimeFormatted
    };
    return dateTime;
  }

  String parseDateToDMY(String? date,
      {String fromFormat = "yyyy-MM-ddTHH:mm"}) {
    final DateFormat inputFormat = DateFormat(fromFormat);
    final DateTime dateTime = inputFormat.parse(date!);
    final DateFormat outputFormat = DateFormat("dd-MM-yyyy");
    return outputFormat.format(dateTime);
  }

  String parseDateTimeToDate(DateTime dateTime) {
    final DateFormat outputDateFormat = DateFormat("dd-MM-yyyy");
    final String formattedDate = outputDateFormat.format(dateTime);
    return formattedDate;
  }

  String dateStringToDateTimeWithAmPm(String date) {
    final _date = DateTime.parse(date).toLocal();
    final String month = getMonthName(_date);
    //2021-11-11T18:30:00.000Z
    //1 November, 2021 12:00 AM
    return "${_date.day} $month, ${_date.year} | ${DateFormat('h:mm a').format(_date)}";
  }

  String getMonthName(DateTime date) {
    late String month;
    switch (date.month) {
      case 1:
        month = 'Jan';
        break;
      case 2:
        month = 'Feb';
        break;
      case 3:
        month = 'Mar';
        break;
      case 4:
        month = 'Apr';
        break;
      case 5:
        month = 'May';
        break;
      case 6:
        month = 'Jun';
        break;
      case 7:
        month = 'Jul';
        break;
      case 8:
        month = 'Aug';
        break;
      case 9:
        month = 'Sep';
        break;
      case 10:
        month = 'Oct';
        break;
      case 11:
        month = 'Nov';
        break;
      case 12:
        month = 'Dec';
        break;
      default:
        return '';
    }
    return month;
  }

  String parseDateToDateTime(DateTime dateTime) {
    final DateFormat outputDateFormat = DateFormat("dd-MM-yyyy | hh:mm a");
    final String formattedDate = outputDateFormat.format(dateTime);
    return formattedDate;
  }

  int parseDateTimeToSecond(String? date) {
    // 2022-01-14T16:27:59.862962+05:30
    try {
      final DateTime parseDate = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(date!);
      final currentDate = DateTime.now();
      if (parseDate.difference(currentDate).isNegative) {
        return currentDate.difference(parseDate).inSeconds;
      } else {
        return parseDate.difference(currentDate).inSeconds;
      }
    } catch (e) {
      print(e);
      return 20 * 60;
    }
  }

  bool isPassedTime(String? date) {
    // 2022-01-14T16:27:59.862962+05:30
    try {
      final DateTime parseDate = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(date!);
      final currentDate = DateTime.now();
      return parseDate.difference(currentDate).isNegative;
    } catch (e) {
      print(e);
      return true;
    }
  }

  int parseDateTimeToMinute(String? date) {
    // 2022-01-14T16:27:59.862962+05:30
    try {
      final DateTime parseDate = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(date!);
      final currentDate = DateTime.now();
      return parseDate.difference(currentDate).inMinutes > 0
          ? parseDate.difference(currentDate).inMinutes
          : 20;
    } catch (e) {
      return 20;
    }
  }

  String dateStringToDateTime(String date) {
    final _date = DateTime.parse(date).toLocal();
    final String month = getMonthName(_date);
    return "${_date.day} $month, ${DateFormat('h:mm ').format(_date)}";
  }

  String firstDateOfTheWeek() {
    final dateTime = DateTime.now();
    return DateFormat('yyyy-MM-dd')
        .format(dateTime.subtract(Duration(days: dateTime.weekday - 1)));
  }

  String lastDateOfTheWeek() {
    final dateTime = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(
      dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday)),
    );
  }

  String lastDateOfTheWeekInDateFormat({
    required DateTime selectedDateTime,
  }) {
    final dateTime = selectedDateTime;
    return DateFormat('dd-MMM').format(
      dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday)),
    );
  }

  String dateStringToTime(String date) {
    final _date = DateTime.parse(date).toLocal();
    final String month = getMonthName(_date);
    return DateFormat('h:mm a').format(_date);
  }

  String parseDateToYMD(String? date,
      {String fromFormat = "yyyy-MM-ddTHH:mm"}) {
    final DateFormat inputFormat = DateFormat(fromFormat);
    final DateTime dateTime = inputFormat.parse(date!);
    final DateFormat outputFormat = DateFormat("yyyy-MM-dd");
    return outputFormat.format(dateTime);
  }
}
