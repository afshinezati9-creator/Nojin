import 'iran_number.dart';

enum IranCurrency { toman, rial }

class IranMoney {
  const IranMoney(this.amount, {this.currency = IranCurrency.toman});

  final int amount;
  final IranCurrency currency;

  String get unit => currency == IranCurrency.toman ? 'تومان' : 'ریال';

  String get display => IranNumber.format(amount) + ' ' + unit;

  int get rialAmount => currency == IranCurrency.toman ? amount * 10 : amount;

  int get tomanAmount => currency == IranCurrency.rial ? amount ~/ 10 : amount;

  IranMoney inCurrency(IranCurrency target) {
    if (target == currency) return this;
    return target == IranCurrency.toman
        ? IranMoney(rialAmount ~/ 10, currency: target)
        : IranMoney(rialAmount, currency: target);
  }

  @override
  String toString() => display;
}
