import 'package:flutter_test/flutter_test.dart';
import 'package:nojin/core/iran/iran_money.dart';

void main() {
  test('defaults money to toman and converts rial', () {
    const toman = IranMoney(125000);
    expect(toman.display, '۱۲۵٬۰۰۰ تومان');
    expect(toman.rialAmount, 1250000);
    expect(toman.inCurrency(IranCurrency.rial).amount, 1250000);
  });
}
