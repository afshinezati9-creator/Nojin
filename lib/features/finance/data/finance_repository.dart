import 'dart:math';

import '../../../core/database/nojin_database.dart';
import '../../../core/iran/iran_bank.dart';
import '../../../core/iran/iran_money.dart';
import '../../../core/iran/iran_number.dart';
import '../domain/finance_models.dart';

class FinanceRepository {
  FinanceRepository(this._database);

  final NojinDatabase _database;

  Future<List<FinanceAccount>> listAccounts({bool includeArchived = false}) async {
    final rows = await _database.connection.runSelect(
      includeArchived
          ? 'SELECT * FROM finance_accounts ORDER BY is_archived ASC, updated_at DESC'
          : 'SELECT * FROM finance_accounts WHERE is_archived = 0 ORDER BY updated_at DESC',
      [],
    );
    return rows.map(_accountFromRow).toList(growable: false);
  }

  Future<FinanceAccount?> getAccount(String id) async {
    final rows = await _database.connection.runSelect(
      'SELECT * FROM finance_accounts WHERE id = ? LIMIT 1',
      [id],
    );
    return rows.isEmpty ? null : _accountFromRow(rows.first);
  }

  Future<FinanceAccount> createAccount({
    required String name,
    required FinanceAccountType type,
    IranCurrency currency = IranCurrency.toman,
    int openingBalance = 0,
    String? bankName,
    String? accountNumber,
    String? cardNumber,
    String? sheba,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('نام حساب الزامی است.');
    if (openingBalance < 0) throw ArgumentError('موجودی اولیه نمی‌تواند منفی باشد.');
    final details = _validateBankDetails(
      type: type,
      bankName: bankName,
      accountNumber: accountNumber,
      cardNumber: cardNumber,
      sheba: sheba,
    );
    final now = DateTime.now().toUtc();
    final item = FinanceAccount(
      id: _newId(),
      name: clean,
      type: type,
      currency: currency,
      balance: openingBalance,
      isArchived: false,
      bankName: details.bankName,
      accountNumber: details.accountNumber,
      cardNumber: details.cardNumber,
      sheba: details.sheba,
      createdAt: now,
      updatedAt: now,
    );
    await _database.connection.runCustom(
      'INSERT INTO finance_accounts('
      'id,name,account_type,currency,balance,is_archived,bank_name,account_number,card_number,sheba,created_at,updated_at'
      ') VALUES(?,?,?,?,?,?,?,?,?,?,?,?)',
      [
        item.id, item.name, item.type.key, item.currency.name, item.balance, 0,
        item.bankName, item.accountNumber, item.cardNumber, item.sheba,
        item.createdAt.millisecondsSinceEpoch, item.updatedAt.millisecondsSinceEpoch,
      ],
    );
    return item;
  }

  Future<void> updateAccount({
    required String id,
    required String name,
    required FinanceAccountType type,
    required IranCurrency currency,
    String? bankName,
    String? accountNumber,
    String? cardNumber,
    String? sheba,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('نام حساب الزامی است.');
    final details = _validateBankDetails(
      type: type,
      bankName: bankName,
      accountNumber: accountNumber,
      cardNumber: cardNumber,
      sheba: sheba,
    );
    await _database.connection.runCustom(
      'UPDATE finance_accounts SET name = ?, account_type = ?, currency = ?, '
      'bank_name = ?, account_number = ?, card_number = ?, sheba = ?, updated_at = ? WHERE id = ?',
      [
        clean, type.key, currency.name, details.bankName, details.accountNumber,
        details.cardNumber, details.sheba,
        DateTime.now().toUtc().millisecondsSinceEpoch, id,
      ],
    );
  }

  Future<void> archiveAccount(String id, {required bool archived}) async {
    await _database.connection.runCustom(
      'UPDATE finance_accounts SET is_archived = ?, updated_at = ? WHERE id = ?',
      [archived ? 1 : 0, DateTime.now().toUtc().millisecondsSinceEpoch, id],
    );
  }

  Future<FinanceDashboardSummary> dashboardSummary() async {
    final rows = await _database.connection.runSelect(
      'SELECT a.currency, t.transaction_type, SUM(t.amount) AS total '
      'FROM finance_transactions t JOIN finance_accounts a ON a.id = t.account_id '
      'WHERE a.is_archived = 0 GROUP BY a.currency, t.transaction_type',
      [],
    );
    var tomanIncome = 0, tomanExpense = 0, rialIncome = 0, rialExpense = 0;
    for (final row in rows) {
      final currency = row['currency'].toString();
      final type = row['transaction_type'].toString();
      final total = int.parse(row['total'].toString());
      if (currency == IranCurrency.rial.name) {
        if (type == FinanceTransactionType.income.name) rialIncome += total; else rialExpense += total;
      } else {
        if (type == FinanceTransactionType.income.name) tomanIncome += total; else tomanExpense += total;
      }
    }
    final recentRows = await _database.connection.runSelect(
      'SELECT t.*, a.name AS account_name, a.currency AS account_currency '
      'FROM finance_transactions t JOIN finance_accounts a ON a.id = t.account_id '
      'WHERE a.is_archived = 0 ORDER BY t.occurred_at DESC, t.created_at DESC LIMIT 8',
      [],
    );
    final recent = recentRows.map((row) => FinanceDashboardTransaction(
      transaction: _transactionFromRow(row),
      accountName: row['account_name'].toString(),
      currency: IranCurrency.values.firstWhere((x) => x.name == row['account_currency'].toString(), orElse: () => IranCurrency.toman),
    )).toList(growable: false);
    final expenseRows = await _database.connection.runSelect(
      'SELECT t.title, t.transaction_type, a.currency, SUM(t.amount) AS total '
      'FROM finance_transactions t JOIN finance_accounts a ON a.id = t.account_id '
      'WHERE a.is_archived = 0 AND t.transaction_type = ? '
      'GROUP BY t.title, t.transaction_type, a.currency ORDER BY total DESC LIMIT 6',
      [FinanceTransactionType.expense.name],
    );
    final topExpenses = expenseRows.map((row) => FinanceDashboardAggregate(
      title: row['title'].toString(), total: int.parse(row['total'].toString()),
      currency: IranCurrency.values.firstWhere((x) => x.name == row['currency'].toString(), orElse: () => IranCurrency.toman),
    )).toList(growable: false);
    return FinanceDashboardSummary(
      tomanIncome: tomanIncome, tomanExpense: tomanExpense,
      rialIncome: rialIncome, rialExpense: rialExpense,
      recent: recent, topExpenses: topExpenses,
    );
  }

  Future<List<FinanceTransaction>> listTransactions(String accountId) async {
    final rows = await _database.connection.runSelect(
      'SELECT * FROM finance_transactions WHERE account_id = ? ORDER BY occurred_at DESC, created_at DESC',
      [accountId],
    );
    return rows.map(_transactionFromRow).toList(growable: false);
  }

  Future<FinanceTransaction> addTransaction({
    required String accountId,
    required String title,
    required int amount,
    required FinanceTransactionType type,
    String note = '',
    DateTime? occurredAt,
  }) async {
    final clean = title.trim();
    if (clean.isEmpty) throw ArgumentError('عنوان تراکنش الزامی است.');
    if (amount <= 0) throw ArgumentError('مبلغ تراکنش باید بیشتر از صفر باشد.');
    final account = await getAccount(accountId);
    if (account == null) throw StateError('حساب پیدا نشد.');
    final now = DateTime.now().toUtc();
    final item = FinanceTransaction(
      id: _newId(), accountId: accountId, title: clean, amount: amount, type: type,
      note: note.trim(), occurredAt: (occurredAt ?? now).toUtc(), createdAt: now,
    );
    final delta = type == FinanceTransactionType.income ? amount : -amount;
    await _database.transaction((tx) async {
      await tx.runCustom(
        'INSERT INTO finance_transactions(id,account_id,title,amount,transaction_type,note,occurred_at,created_at) VALUES(?,?,?,?,?,?,?,?)',
        [item.id,item.accountId,item.title,item.amount,item.type.key,item.note,item.occurredAt.millisecondsSinceEpoch,item.createdAt.millisecondsSinceEpoch],
      );
      await tx.runCustom(
        'UPDATE finance_accounts SET balance = balance + ?, updated_at = ? WHERE id = ?',
        [delta,now.millisecondsSinceEpoch,accountId],
      );
    });
    return item;
  }

  Future<void> deleteTransaction(String id) async {
    final rows = await _database.connection.runSelect(
      'SELECT account_id, amount, transaction_type FROM finance_transactions WHERE id = ? LIMIT 1',
      [id],
    );
    if (rows.isEmpty) return;
    final row = rows.first;
    final amount = int.parse(row['amount'].toString());
    final type = FinanceTransactionTypeX.fromKey(row['transaction_type'].toString());
    final delta = type == FinanceTransactionType.income ? -amount : amount;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _database.transaction((tx) async {
      await tx.runCustom('DELETE FROM finance_transactions WHERE id = ?', [id]);
      await tx.runCustom(
        'UPDATE finance_accounts SET balance = balance + ?, updated_at = ? WHERE id = ?',
        [delta,now,row['account_id']],
      );
    });
  }

  Future<List<FinanceInstallmentPlan>> listInstallmentPlans() async {
    final rows = await _database.connection.runSelect(
      'SELECT * FROM finance_installment_plans ORDER BY first_due_at ASC, created_at DESC',
      [],
    );
    return rows.map(_installmentPlanFromRow).toList(growable: false);
  }

  Future<FinanceInstallmentPlan?> getInstallmentPlan(String id) async {
    final rows = await _database.connection.runSelect(
      'SELECT * FROM finance_installment_plans WHERE id = ? LIMIT 1',
      [id],
    );
    return rows.isEmpty ? null : _installmentPlanFromRow(rows.first);
  }

  Future<List<FinanceInstallment>> listInstallments(String planId) async {
    final rows = await _database.connection.runSelect(
      'SELECT * FROM finance_installments WHERE plan_id = ? ORDER BY sequence ASC',
      [planId],
    );
    return rows.map(_installmentFromRow).toList(growable: false);
  }

  Future<FinanceInstallmentPlan> createInstallmentPlan({
    required String title,
    required int totalAmount,
    required int installmentCount,
    required IranCurrency currency,
    required DateTime firstDueAt,
    int intervalMonths = 1,
    String note = '',
  }) async {
    final clean = title.trim();
    if (clean.isEmpty) throw ArgumentError('عنوان قسط الزامی است.');
    if (totalAmount <= 0) throw ArgumentError('مبلغ کل باید بیشتر از صفر باشد.');
    if (installmentCount <= 0 || installmentCount > 120) {
      throw ArgumentError('تعداد اقساط باید بین ۱ تا ۱۲۰ باشد.');
    }
    if (intervalMonths <= 0 || intervalMonths > 24) {
      throw ArgumentError('فاصله اقساط باید بین ۱ تا ۲۴ ماه باشد.');
    }

    final now = DateTime.now().toUtc();
    final first = DateTime.utc(firstDueAt.year, firstDueAt.month, firstDueAt.day);
    final baseAmount = totalAmount ~/ installmentCount;
    final remainder = totalAmount - (baseAmount * installmentCount);
    final plan = FinanceInstallmentPlan(
      id: _newId(),
      title: clean,
      totalAmount: totalAmount,
      installmentAmount: baseAmount,
      installmentCount: installmentCount,
      currency: currency,
      firstDueAt: first,
      intervalMonths: intervalMonths,
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _database.transaction((tx) async {
      await tx.runCustom(
        'INSERT INTO finance_installment_plans('
        'id,title,total_amount,installment_amount,installment_count,currency,first_due_at,interval_months,note,created_at,updated_at'
        ') VALUES(?,?,?,?,?,?,?,?,?,?,?)',
        [
          plan.id, plan.title, plan.totalAmount, plan.installmentAmount,
          plan.installmentCount, plan.currency.name, plan.firstDueAt.millisecondsSinceEpoch,
          plan.intervalMonths, plan.note, now.millisecondsSinceEpoch, now.millisecondsSinceEpoch,
        ],
      );
      for (var index = 0; index < installmentCount; index++) {
        final amount = index == installmentCount - 1 ? baseAmount + remainder : baseAmount;
        final dueAt = _addMonths(first, index * intervalMonths);
        await tx.runCustom(
          'INSERT INTO finance_installments(id,plan_id,sequence,due_at,amount,paid_at,transaction_id) VALUES(?,?,?,?,?,?,?)',
          [_newId(), plan.id, index + 1, dueAt.millisecondsSinceEpoch, amount, null, null],
        );
      }
    });
    return plan;
  }

  Future<void> payInstallment({
    required String installmentId,
    required String accountId,
  }) async {
    final rows = await _database.connection.runSelect(
      'SELECT i.id, i.plan_id, i.sequence, i.due_at, i.amount, i.paid_at, '
      'p.title AS plan_title, p.currency AS plan_currency, a.currency AS account_currency, a.is_archived '
      'FROM finance_installments i '
      'JOIN finance_installment_plans p ON p.id = i.plan_id '
      'JOIN finance_accounts a ON a.id = ? '
      'WHERE i.id = ? LIMIT 1',
      [accountId, installmentId],
    );
    if (rows.isEmpty) throw StateError('قسط یا حساب پیدا نشد.');
    final row = rows.first;
    if (row['paid_at'] != null) throw StateError('این قسط قبلاً پرداخت شده است.');
    if (row['is_archived'].toString() == '1') throw StateError('حساب انتخاب‌شده بایگانی شده است.');
    if (row['account_currency'].toString() != row['plan_currency'].toString()) {
      throw ArgumentError('واحد پول حساب و قسط باید یکسان باشد.');
    }

    final now = DateTime.now().toUtc();
    final transactionId = _newId();
    final amount = int.parse(row['amount'].toString());
    final title = 'قسط ' + row['sequence'].toString() + ': ' + row['plan_title'].toString();

    await _database.transaction((tx) async {
      await tx.runCustom(
        'INSERT INTO finance_transactions(id,account_id,title,amount,transaction_type,note,occurred_at,created_at) VALUES(?,?,?,?,?,?,?,?)',
        [transactionId, accountId, title, amount, FinanceTransactionType.expense.name, 'پرداخت قسط', now.millisecondsSinceEpoch, now.millisecondsSinceEpoch],
      );
      await tx.runCustom(
        'UPDATE finance_accounts SET balance = balance - ?, updated_at = ? WHERE id = ?',
        [amount, now.millisecondsSinceEpoch, accountId],
      );
      await tx.runCustom(
        'UPDATE finance_installments SET paid_at = ?, transaction_id = ? WHERE id = ? AND paid_at IS NULL',
        [now.millisecondsSinceEpoch, transactionId, installmentId],
      );
    });
  }

  FinanceInstallmentPlan _installmentPlanFromRow(Map<String, Object?> row) {
    return FinanceInstallmentPlan(
      id: row['id'].toString(),
      title: row['title'].toString(),
      totalAmount: int.parse(row['total_amount'].toString()),
      installmentAmount: int.parse(row['installment_amount'].toString()),
      installmentCount: int.parse(row['installment_count'].toString()),
      currency: IranCurrency.values.firstWhere(
        (item) => item.name == row['currency'].toString(),
        orElse: () => IranCurrency.toman,
      ),
      firstDueAt: DateTime.fromMillisecondsSinceEpoch(int.parse(row['first_due_at'].toString()), isUtc: true),
      intervalMonths: int.parse(row['interval_months'].toString()),
      note: row['note']?.toString() ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(int.parse(row['created_at'].toString()), isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(int.parse(row['updated_at'].toString()), isUtc: true),
    );
  }

  FinanceInstallment _installmentFromRow(Map<String, Object?> row) {
    return FinanceInstallment(
      id: row['id'].toString(),
      planId: row['plan_id'].toString(),
      sequence: int.parse(row['sequence'].toString()),
      dueAt: DateTime.fromMillisecondsSinceEpoch(int.parse(row['due_at'].toString()), isUtc: true),
      amount: int.parse(row['amount'].toString()),
      paidAt: row['paid_at'] == null ? null : DateTime.fromMillisecondsSinceEpoch(int.parse(row['paid_at'].toString()), isUtc: true),
      transactionId: row['transaction_id']?.toString(),
    );
  }

  static DateTime _addMonths(DateTime date, int months) {
    final target = date.month + months;
    final year = date.year + ((target - 1) ~/ 12);
    final month = ((target - 1) % 12) + 1;
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    return DateTime.utc(year, month, date.day > lastDay ? lastDay : date.day);
  }

  _BankDetails _validateBankDetails({
    required FinanceAccountType type,
    String? bankName,
    String? accountNumber,
    String? cardNumber,
    String? sheba,
  }) {
    if (type != FinanceAccountType.bank) {
      return const _BankDetails();
    }
    final cleanBank = bankName?.trim();
    final cleanAccount = IranNumber.toEnglish(accountNumber ?? '').replaceAll(RegExp(r'\D'), '');
    final cleanCard = IranBank.normalizeCard(cardNumber ?? '');
    final cleanSheba = IranBank.normalizeSheba(sheba ?? '');

    if (cleanCard.isNotEmpty && !IranBank.isValidCard(cleanCard)) {
      throw ArgumentError('شماره کارت بانکی معتبر نیست.');
    }
    if (cleanSheba.isNotEmpty && !IranBank.isValidSheba(cleanSheba)) {
      throw ArgumentError('شماره شبا معتبر نیست.');
    }
    return _BankDetails(
      bankName: cleanBank?.isEmpty == true ? null : cleanBank,
      accountNumber: cleanAccount.isEmpty ? null : cleanAccount,
      cardNumber: cleanCard.isEmpty ? null : cleanCard,
      sheba: cleanSheba.isEmpty ? null : cleanSheba,
    );
  }

  FinanceAccount _accountFromRow(Map<String,Object?> row) => FinanceAccount(
    id: row['id'].toString(),
    name: row['name'].toString(),
    type: FinanceAccountTypeX.fromKey(row['account_type'].toString()),
    currency: IranCurrency.values.firstWhere(
      (item) => item.name == row['currency'].toString(),
      orElse: () => IranCurrency.toman,
    ),
    balance: int.parse(row['balance'].toString()),
    isArchived: row['is_archived'].toString() == '1',
    bankName: row['bank_name']?.toString(),
    accountNumber: row['account_number']?.toString(),
    cardNumber: row['card_number']?.toString(),
    sheba: row['sheba']?.toString(),
    createdAt: _date(row['created_at']),
    updatedAt: _date(row['updated_at']),
  );

  FinanceTransaction _transactionFromRow(Map<String,Object?> row) => FinanceTransaction(
    id: row['id'].toString(), accountId: row['account_id'].toString(),
    title: row['title'].toString(), amount: int.parse(row['amount'].toString()),
    type: FinanceTransactionTypeX.fromKey(row['transaction_type'].toString()),
    note: row['note'].toString(), occurredAt: _date(row['occurred_at']),
    createdAt: _date(row['created_at']),
  );

  DateTime _date(Object? value) => DateTime.fromMillisecondsSinceEpoch(int.parse(value.toString()), isUtc: true);
  String _newId() => DateTime.now().toUtc().microsecondsSinceEpoch.toString() + '-' + Random().nextInt(1 << 32).toRadixString(16);
}

class _BankDetails {
  const _BankDetails({this.bankName, this.accountNumber, this.cardNumber, this.sheba});
  final String? bankName;
  final String? accountNumber;
  final String? cardNumber;
  final String? sheba;
}
