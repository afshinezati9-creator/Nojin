import 'iran_number.dart';

class IranDate {
  const IranDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  static IranDate fromDateTime(DateTime date) {
    final g = _Jalali.gregorianToJalali(date.year, date.month, date.day);
    return IranDate(g[0], g[1], g[2]);
  }

  DateTime toDateTime({int hour = 0, int minute = 0, int second = 0}) {
    final g = _Jalali.jalaliToGregorian(year, month, day);
    return DateTime.utc(g[0], g[1], g[2], hour, minute, second);
  }

  String get iso =>
      year.toString() + '-' +
      month.toString().padLeft(2, '0') + '-' +
      day.toString().padLeft(2, '0');

  String get display =>
      IranNumber.toPersian(day.toString().padLeft(2, '0')) + '/' +
      IranNumber.toPersian(month.toString().padLeft(2, '0')) + '/' +
      IranNumber.toPersian(year.toString());

  @override
  String toString() => display;
}

class _Jalali {
  static const _gdm = <int>[0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];

  static List<int> gregorianToJalali(int gy, int gm, int gd) {
    var gy2 = gy - 1600;
    var jy = 979;
    var days = 365 * gy2 +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) -
        80 +
        gd +
        _gdm[gm - 1];
    if (gm > 2 && _isLeapGregorian(gy)) days++;
    jy += 33 * (days ~/ 12053);
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }
    final jm = days < 186 ? 1 + days ~/ 31 : 7 + (days - 186) ~/ 30;
    final jd = 1 + (days < 186 ? days % 31 : (days - 186) % 30);
    return [jy, jm, jd];
  }

  static List<int> jalaliToGregorian(int jy, int jm, int jd) {
    var jy2 = jy - 979;
    var days = 365 * jy2 +
        (jy2 ~/ 33) * 8 +
        ((jy2 % 33 + 3) ~/ 4) +
        78 +
        jd +
        (jm < 7 ? (jm - 1) * 31 : (jm - 7) * 30 + 186);
    var gy = 1600 + 400 * (days ~/ 146097);
    days %= 146097;
    var leap = true;
    if (days >= 36525) {
      days--;
      gy += 100 * (days ~/ 36524);
      days %= 36524;
      if (days >= 365) days++;
      else leap = false;
    }
    gy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      leap = false;
      days--;
      gy += days ~/ 365;
      days %= 365;
    }
    var gd = days + 1;
    final monthDays = <int>[31, if (leap) 29 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var gm = 1;
    for (final length in monthDays) {
      if (gd <= length) break;
      gd -= length;
      gm++;
    }
    return [gy, gm, gd];
  }

  static bool _isLeapGregorian(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
}
