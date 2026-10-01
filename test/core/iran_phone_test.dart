import 'package:flutter_test/flutter_test.dart';
import 'package:nojin/core/iran/iran_phone.dart';

void main() {
  test('normalizes Iranian phone numbers', () {
    expect(IranPhone.normalize('+989121234567'), '09121234567');
    expect(IranPhone.normalize('۰۹۱۲۱۲۳۴۵۶۷'), '09121234567');
    expect(IranPhone.toInternational('09121234567'), '+989121234567');
  });

  test('validates Iranian mobile numbers', () {
    expect(IranPhone.isValid('09121234567'), isTrue);
    expect(IranPhone.isValid('0912123456'), isFalse);
  });
}
