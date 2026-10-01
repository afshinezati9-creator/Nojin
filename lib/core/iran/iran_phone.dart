import 'iran_number.dart';

class IranPhone {
  const IranPhone._();

  static String normalize(String value) {
    var phone = IranNumber.toEnglish(value).replaceAll(RegExp(r'[\s\-()]'), '');
    if (phone.startsWith('+98')) phone = '0' + phone.substring(3);
    if (phone.startsWith('0098')) phone = '0' + phone.substring(4);
    return phone;
  }

  static bool isValid(String value) {
    final phone = normalize(value);
    return RegExp(r'^09\d{9}$').hasMatch(phone);
  }

  static String toInternational(String value) {
    final phone = normalize(value);
    if (!isValid(phone)) return value;
    return '+98' + phone.substring(1);
  }

  static String mask(String value) {
    final phone = normalize(value);
    if (!isValid(phone)) return value;
    return phone.substring(0, 4) + '***' + phone.substring(7);
  }
}
