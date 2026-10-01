import 'package:flutter_test/flutter_test.dart';
import 'package:nojin/core/iran/iran_date.dart';

void main() {
  test('converts Gregorian New Year in Iran to Jalali', () {
    final date = IranDate.fromDateTime(DateTime(2026, 3, 21));
    expect(date.year, 1405);
    expect(date.month, 1);
    expect(date.day, 1);
    expect(date.display, '۰۱/۰۱/۱۴۰۵');
  });

  test('converts Jalali back to Gregorian', () {
    final date = const IranDate(1405, 1, 1).toDateTime();
    expect(date.year, 2026);
    expect(date.month, 3);
    expect(date.day, 21);
  });
}
