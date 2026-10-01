import 'iran_date.dart';

class IranHoliday {
  const IranHoliday({
    required this.date,
    required this.title,
    this.isNational = true,
  });

  final IranDate date;
  final String title;
  final bool isNational;
}

class IranHolidayProvider {
  const IranHolidayProvider._();

  static List<IranHoliday> fixedSolarHolidays(int year) => [
    IranHoliday(date: IranDate(year, 1, 1), title: 'نوروز'),
    IranHoliday(date: IranDate(year, 1, 2), title: 'نوروز'),
    IranHoliday(date: IranDate(year, 1, 3), title: 'نوروز'),
    IranHoliday(date: IranDate(year, 1, 4), title: 'نوروز'),
    IranHoliday(date: IranDate(year, 1, 12), title: 'روز جمهوری اسلامی ایران'),
    IranHoliday(date: IranDate(year, 1, 13), title: 'روز طبیعت'),
    IranHoliday(date: IranDate(year, 3, 14), title: 'رحلت امام خمینی'),
    IranHoliday(date: IranDate(year, 3, 15), title: 'قیام ۱۵ خرداد'),
    IranHoliday(date: IranDate(year, 11, 22), title: 'پیروزی انقلاب اسلامی'),
    IranHoliday(date: IranDate(year, 12, 29), title: 'ملی شدن صنعت نفت'),
  ];
}
