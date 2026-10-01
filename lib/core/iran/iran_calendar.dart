import 'iran_date.dart';

enum IranCalendar { jalali, gregorian, hijri }

class IranCalendarService {
  const IranCalendarService._();

  static IranDate jalali(DateTime date) => IranDate.fromDateTime(date);

  static DateTime gregorian(IranDate date) => date.toDateTime();

  static const defaultCalendar = IranCalendar.jalali;
}
