import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nojin/core/database/nojin_database.dart';
import 'package:nojin/core/iran/iran_money.dart';
import 'package:nojin/features/finance/data/finance_repository.dart';
import 'package:nojin/features/finance/domain/finance_models.dart';

void main() {
  late NojinDatabase database;
  late FinanceRepository repository;

  setUp(() async {
    database = await NojinDatabase.fromConnection(
      DatabaseConnection.fromExecutor(NativeDatabase.memory()),
    );
    repository = FinanceRepository(database);
  });

  tearDown(() => database.close());

  test('creates account and keeps opening balance', () async {
    final account = await repository.createAccount(
      name: 'حساب اصلی',
      type: FinanceAccountType.bank,
      openingBalance: 100000,
    );
    expect(account.balance, 100000);
    final loaded = await repository.getAccount(account.id);
    expect(loaded?.name, 'حساب اصلی');
    expect(loaded?.balance, 100000);
  });

  test('income and expense atomically update account balance', () async {
    final account = await repository.createAccount(
      name: 'نقدی',
      type: FinanceAccountType.cash,
      openingBalance: 100000,
    );
    await repository.addTransaction(
      accountId: account.id,
      title: 'حقوق',
      amount: 50000,
      type: FinanceTransactionType.income,
    );
    await repository.addTransaction(
      accountId: account.id,
      title: 'خرید',
      amount: 20000,
      type: FinanceTransactionType.expense,
    );
    expect((await repository.getAccount(account.id))?.balance, 130000);
    expect((await repository.listTransactions(account.id)).length, 2);
  });

  test('deleting a transaction reverses its balance effect', () async {
    final account = await repository.createAccount(
      name: 'کیف پول',
      type: FinanceAccountType.wallet,
    );
    final tx = await repository.addTransaction(
      accountId: account.id,
      title: 'هزینه',
      amount: 25000,
      type: FinanceTransactionType.expense,
    );
    expect((await repository.getAccount(account.id))?.balance, -25000);
    await repository.deleteTransaction(tx.id);
    expect((await repository.getAccount(account.id))?.balance, 0);
  });

  test('stores and validates Iranian bank details', () async {
    final account = await repository.createAccount(
      name: 'حساب ملت',
      type: FinanceAccountType.bank,
      currency: IranCurrency.toman,
      bankName: 'ملت',
      accountNumber: '123456789',
      cardNumber: '6037997512345670',
      sheba: 'IR062960000000100324200001',
    );
    final loaded = await repository.getAccount(account.id);
    expect(loaded?.currency, IranCurrency.toman);
    expect(loaded?.bankName, 'ملت');
    expect(loaded?.accountNumber, '123456789');
    expect(loaded?.cardNumber, '6037997512345670');
    expect(loaded?.sheba, 'IR062960000000100324200001');
  });

  test('rejects invalid Iranian card and sheba numbers', () async {
    expect(
      () => repository.createAccount(
        name: 'بانک',
        type: FinanceAccountType.bank,
        cardNumber: '1111111111111111',
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => repository.createAccount(
        name: 'بانک',
        type: FinanceAccountType.bank,
        sheba: 'IR062960000000100324200002',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('keeps rial and toman as separate account currencies', () async {
    final account = await repository.createAccount(
      name: 'حساب ریالی',
      type: FinanceAccountType.bank,
      currency: IranCurrency.rial,
      openingBalance: 10000,
    );
    expect(account.currency, IranCurrency.rial);
    expect(IranMoney(account.balance, currency: account.currency).unit, 'ریال');
  });

}