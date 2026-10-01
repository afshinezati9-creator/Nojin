import 'iran_number.dart';

class IranBank {
  const IranBank._();

  static String normalizeCard(String value) =>
      IranNumber.toEnglish(value).replaceAll(RegExp(r'\D'), '');

  static bool isValidCard(String value) {
    final card = normalizeCard(value);
    if (card.length != 16 || RegExp(r'^(\d)\1{15}$').hasMatch(card)) {
      return false;
    }
    var sum = 0;
    for (var i = 0; i < 16; i++) {
      var digit = int.parse(card[i]);
      if (i.isEven) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    return sum % 10 == 0;
  }

  static String normalizeSheba(String value) =>
      IranNumber.toEnglish(value).toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

  static bool isValidSheba(String value) {
    final sheba = normalizeSheba(value);
    if (!RegExp(r'^IR\d{24}$').hasMatch(sheba)) return false;
    final numeric = sheba.substring(4) + '1827' + sheba.substring(2, 4);
    var remainder = 0;
    for (final char in numeric.split('')) {
      remainder = (remainder * 10 + int.parse(char)) % 97;
    }
    return remainder == 1;
  }

  static String formatCard(String value) {
    final card = normalizeCard(value);
    if (card.length != 16) return value;
    return List.generate(4, (i) => card.substring(i * 4, i * 4 + 4)).join(' ');
  }

  static String formatSheba(String value) {
    final sheba = normalizeSheba(value);
    if (sheba.length != 26) return value;
    return sheba.substring(0, 2) + ' ' +
        sheba.substring(2, 6) + ' ' +
        sheba.substring(6, 10) + ' ' +
        sheba.substring(10, 14) + ' ' +
        sheba.substring(14, 18) + ' ' +
        sheba.substring(18, 22) + ' ' +
        sheba.substring(22);
  }
}
