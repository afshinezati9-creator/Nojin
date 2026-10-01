class IranNumber {
  const IranNumber._();

  static const _fa = '۰۱۲۳۴۵۶۷۸۹';
  static const _en = '0123456789';

  static String toEnglish(String value) {
    var result = value;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(_fa[i], _en[i]);
    }
    return result;
  }

  static String toPersian(String value) {
    var result = value;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(_en[i], _fa[i]);
    }
    return result;
  }

  static String format(num value, {bool persian = true}) {
    final raw = value is int
        ? value.toString()
        : value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
    final parts = raw.split('.');
    final sign = parts.first.startsWith('-') ? '-' : '';
    final integer = sign.isEmpty ? parts.first : parts.first.substring(1);
    final grouped = integer.replaceAllMapped(
      RegExp(r'(?<=\d)(?=(\d{3})+$)'),
      (_) => '٬',
    );
    var output = sign + grouped;
    if (parts.length > 1 && parts[1].isNotEmpty) {
      output += '.' + parts[1];
    }
    return persian ? toPersian(output) : output;
  }
}
