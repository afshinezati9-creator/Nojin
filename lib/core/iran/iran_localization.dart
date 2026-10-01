import 'package:flutter/widgets.dart';

class IranLocalization {
  const IranLocalization._();

  static const locale = Locale('fa', 'IR');
  static const languageCode = 'fa';
  static const countryCode = 'IR';
  static const timezone = 'Asia/Tehran';
  static const currencySymbol = 'تومان';
  static const direction = TextDirection.rtl;

  static const weekdays = <String>[
    'شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه',
  ];

  static const jalaliMonths = <String>[
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
  ];
}
