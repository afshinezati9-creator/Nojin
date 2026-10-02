import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nojin/core/database/nojin_database.dart';
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
}
