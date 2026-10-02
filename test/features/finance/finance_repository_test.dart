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

  test('builds dashboard aggregates from active accounts', () async {
    final toman = await repository.createAccount(
      name: 'حساب اصلی',
      type: FinanceAccountType.bank,
      openingBalance: 5000000,
    );
    final rial = await repository.createAccount(
      name: 'حساب ریالی',
      type: FinanceAccountType.bank,
      currency: IranCurrency.rial,
    );
    await repository.addTransaction(
      accountId: toman.id,
      title: 'حقوق',
      amount: 10000000,
      type: FinanceTransactionType.income,
    );
    await repository.addTransaction(
      accountId: toman.id,
      title: 'اجاره',
      amount: 3000000,
      type: FinanceTransactionType.expense,
    );
    await repository.addTransaction(
      accountId: rial.id,
      title: 'درآمد ریالی',
      amount: 2000000,
      type: FinanceTransactionType.income,
    );

    final summary = await repository.dashboardSummary();
    expect(summary.tomanIncome, 10000000);
    expect(summary.tomanExpense, 3000000);
    expect(summary.tomanNet, 7000000);
    expect(summary.rialIncome, 2000000);
    expect(summary.rialExpense, 0);
    expect(summary.recent, hasLength(3));
    expect(summary.topExpenses.first.title, 'اجاره');
    expect(summary.topExpenses.first.total, 3000000);
  });

  test('dashboard excludes archived accounts', () async {
    final account = await repository.createAccount(
      name: 'قدیمی',
      type: FinanceAccountType.cash,
    );
    await repository.addTransaction(
      accountId: account.id,
      title: 'هزینه قدیمی',
      amount: 900000,
      type: FinanceTransactionType.expense,
    );
    await repository.archiveAccount(account.id, archived: true);

    final summary = await repository.dashboardSummary();
    expect(summary.tomanExpense, 0);
    expect(summary.recent, isEmpty);
  });

  test('creates installment schedule with remainder on the last installment', () async {
    final plan = await repository.createInstallmentPlan(
      title: 'خرید لپ‌تاپ',
      totalAmount: 1000000,
      installmentCount: 3,
      currency: IranCurrency.toman,
      firstDueAt: DateTime.utc(2026, 10, 10),
    );
    final items = await repository.listInstallments(plan.id);
    expect(items, hasLength(3));
    expect(items.map((item) => item.amount).toList(), [333333, 333333, 333334]);
    expect(items[0].dueAt, DateTime.utc(2026, 10, 10));
    expect(items[1].dueAt, DateTime.utc(2026, 11, 10));
    expect(items[2].dueAt, DateTime.utc(2026, 12, 10));
  });

  test('marks overdue installments from their due date without mutating storage', () async {
    final plan = await repository.createInstallmentPlan(
      title: 'خرید معوق',
      totalAmount: 900000,
      installmentCount: 3,
      currency: IranCurrency.toman,
      firstDueAt: DateTime.utc(2020, 1, 1),
    );
    final item = (await repository.listInstallments(plan.id)).first;
    expect(item.statusAt(DateTime.utc(2020, 1, 1, 23, 59)), InstallmentStatus.pending);
    expect(item.statusAt(DateTime.utc(2020, 2, 1)), InstallmentStatus.overdue);
    expect(item.paidAt, isNull);
  });

  test('paying an installment creates an expense transaction and marks it paid', () async {
    final account = await repository.createAccount(
      name: 'حساب پرداخت',
      type: FinanceAccountType.bank,
      openingBalance: 500000,
    );
    final plan = await repository.createInstallmentPlan(
      title: 'خرید قسطی',
      totalAmount: 300000,
      installmentCount: 3,
      currency: IranCurrency.toman,
      firstDueAt: DateTime.utc(2026, 10, 10),
    );
    final item = (await repository.listInstallments(plan.id)).first;
    await repository.payInstallment(installmentId: item.id, accountId: account.id);
    final paid = (await repository.listInstallments(plan.id)).first;
    expect(paid.paidAt, isNotNull);
    expect(paid.transactionId, isNotNull);
    expect((await repository.getAccount(account.id))?.balance, 400000);
    final transactions = await repository.listTransactions(account.id);
    expect(transactions, hasLength(1));
    expect(transactions.single.type, FinanceTransactionType.expense);
    expect(transactions.single.amount, 100000);
  });

  test('rejects payment when account currency does not match installment', () async {
    final account = await repository.createAccount(
      name: 'حساب ریالی',
      type: FinanceAccountType.bank,
      currency: IranCurrency.rial,
      openingBalance: 1000000,
    );
    final plan = await repository.createInstallmentPlan(
      title: 'خرید تومانی',
      totalAmount: 300000,
      installmentCount: 3,
      currency: IranCurrency.toman,
      firstDueAt: DateTime.utc(2026, 10, 10),
    );
    final item = (await repository.listInstallments(plan.id)).first;
    expect(
      () => repository.payInstallment(installmentId: item.id, accountId: account.id),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('creates a receivable and settles it as income', () async {
    final account = await repository.createAccount(
      name: 'حساب دریافت',
      type: FinanceAccountType.bank,
      openingBalance: 100000,
    );
    final debt = await repository.createDebt(
      title: 'طلب فروش',
      personName: 'مشتری',
      type: FinanceDebtType.receivable,
      totalAmount: 300000,
      currency: IranCurrency.toman,
      dueAt: DateTime.utc(2026, 10, 10),
    );
    await repository.settleDebt(debtId: debt.id, accountId: account.id, amount: 100000);
    final updated = await repository.getDebt(debt.id);
    expect(updated?.settledAmount, 100000);
    expect(updated?.remainingAmount, 200000);
    expect((await repository.getAccount(account.id))?.balance, 200000);
    final tx = await repository.listTransactions(account.id);
    expect(tx.single.type, FinanceTransactionType.income);
    expect(tx.single.amount, 100000);
    expect((await repository.listDebtPayments(debt.id)), hasLength(1));
  });

  test('partially settles a payable as expense and then settles the remainder', () async {
    final account = await repository.createAccount(
      name: 'حساب بدهی',
      type: FinanceAccountType.bank,
      openingBalance: 500000,
    );
    final debt = await repository.createDebt(
      title: 'خرید نسیه',
      personName: 'فروشنده',
      type: FinanceDebtType.payable,
      totalAmount: 300000,
      currency: IranCurrency.toman,
    );
    await repository.settleDebt(debtId: debt.id, accountId: account.id, amount: 120000);
    await repository.settleDebt(debtId: debt.id, accountId: account.id, amount: 180000);
    final updated = await repository.getDebt(debt.id);
    expect(updated?.statusAt(DateTime.utc(2026, 10, 1)), FinanceDebtStatus.settled);
    expect((await repository.getAccount(account.id))?.balance, 200000);
    final tx = await repository.listTransactions(account.id);
    expect(tx, hasLength(2));
    expect(tx.every((item) => item.type == FinanceTransactionType.expense), isTrue);
  });

  test('rejects debt settlement with mismatched currency', () async {
    final account = await repository.createAccount(
      name: 'حساب ریالی',
      type: FinanceAccountType.bank,
      currency: IranCurrency.rial,
      openingBalance: 1000000,
    );
    final debt = await repository.createDebt(
      title: 'طلب تومانی',
      personName: 'شخص',
      type: FinanceDebtType.receivable,
      totalAmount: 100000,
      currency: IranCurrency.toman,
    );
    final payment = () => repository.settleDebt(
      debtId: debt.id,
      accountId: account.id,
      amount: 100000,
    );
    expect(payment, throwsA(isA<ArgumentError>()));
  });

  test('reports an overdue debt after its due day', () async {
    final debt = await repository.createDebt(
      title: 'بدهی قدیمی',
      personName: 'شخص',
      type: FinanceDebtType.payable,
      totalAmount: 100000,
      currency: IranCurrency.toman,
      dueAt: DateTime.utc(2026, 1, 10),
    );
    expect(debt.statusAt(DateTime.utc(2026, 1, 10, 23, 59)), FinanceDebtStatus.open);
    expect(debt.statusAt(DateTime.utc(2026, 1, 11)), FinanceDebtStatus.overdue);
  });

  test('creates a financial goal and tracks savings progress', () async {
    final goal = await repository.createGoal(
      title: 'خرید لپ‌تاپ',
      targetAmount: 10000000,
      currency: IranCurrency.toman,
      dueAt: DateTime.utc(2026, 12, 29),
    );
    expect(goal.currentAmount, 0);
    expect(goal.statusAt(DateTime.utc(2026, 10, 1)), FinanceGoalStatus.active);

    await repository.addGoalEntry(goalId: goal.id, amount: 2500000, note: 'پس‌انداز ماه اول');
    final loaded = await repository.getGoal(goal.id);
    expect(loaded?.currentAmount, 2500000);
    expect(loaded?.progress, 0.25);
    expect((await repository.listGoalEntries(goal.id)), hasLength(1));
  });

  test('completes an emergency fund and rejects over-withdrawal', () async {
    final goal = await repository.createGoal(
      title: 'صندوق اضطراری',
      type: FinanceGoalType.emergencyFund,
      targetAmount: 5000000,
      currency: IranCurrency.toman,
    );
    await repository.addGoalEntry(goalId: goal.id, amount: 5000000);
    final complete = await repository.getGoal(goal.id);
    expect(complete?.statusAt(DateTime.utc(2026, 10, 1)), FinanceGoalStatus.completed);

    expect(
      () => repository.addGoalEntry(goalId: goal.id, amount: 5000001, isWithdrawal: true),
      throwsA(isA<ArgumentError>()),
    );
    await repository.addGoalEntry(goalId: goal.id, amount: 1000000, isWithdrawal: true);
    final afterWithdrawal = await repository.getGoal(goal.id);
    expect(afterWithdrawal?.currentAmount, 4000000);
  });

  test('reports overdue financial goal after its due date', () async {
    final goal = await repository.createGoal(
      title: 'هدف قدیمی',
      targetAmount: 1000000,
      currency: IranCurrency.toman,
      dueAt: DateTime.utc(2026, 1, 10),
    );
    expect(goal.statusAt(DateTime.utc(2026, 1, 10, 23, 59)), FinanceGoalStatus.active);
    expect(goal.statusAt(DateTime.utc(2026, 1, 11)), FinanceGoalStatus.overdue);
  });


  test('deleting a goal withdrawal reverses the goal balance', () async {
    final goal = await repository.createGoal(
      title: 'ذخیره',
      targetAmount: 3000000,
      currency: IranCurrency.toman,
    );
    await repository.addGoalEntry(goalId: goal.id, amount: 2000000);
    final withdrawal = await repository.addGoalEntry(
      goalId: goal.id,
      amount: 500000,
      isWithdrawal: true,
    );
    expect((await repository.getGoal(goal.id))?.currentAmount, 1500000);
    await repository.deleteGoalEntry(withdrawal.id);
    expect((await repository.getGoal(goal.id))?.currentAmount, 2000000);
  });


}