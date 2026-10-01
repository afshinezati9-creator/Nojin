import 'package:flutter_test/flutter_test.dart';
import 'package:nojin/core/iran/iran_bank.dart';

void main() {
  test('validates card numbers with Luhn', () {
    expect(IranBank.isValidCard('6037997512345670'), isTrue);
    expect(IranBank.isValidCard('1111111111111111'), isFalse);
  });

  test('validates Sheba with MOD-97', () {
    expect(IranBank.isValidSheba('IR062960000000100324200001'), isTrue);
    expect(IranBank.isValidSheba('IR062960000000100324200002'), isFalse);
  });
}
