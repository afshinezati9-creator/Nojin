import 'package:flutter_test/flutter_test.dart';
import 'package:nojin/core/iran/iran_number.dart';

void main() {
  test('converts Persian digits to English', () {
    expect(IranNumber.toEnglish('۱۲۳٬۴۵۶'), '123٬456');
  });

  test('formats grouped Persian numbers', () {
    expect(IranNumber.format(1234567), '۱٬۲۳۴٬۵۶۷');
    expect(IranNumber.format(1234567, persian: false), '1٬234٬567');
  });
}
