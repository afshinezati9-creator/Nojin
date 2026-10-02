import 'dart:math';

import '../../../core/database/nojin_database.dart';
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
    String currency = 'toman',
    int openingBalance = 0,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('نام حساب الزامی است.');
    if (openingBalance < 0) throw ArgumentError('موجودی اولیه نمی‌تواند منفی باشد.');
    final now = DateTime.now().toUtc();
    final item = FinanceAccount(
      id: _newId(),
      name: clean,
      type: type,
      currency: currency,
      balance: openingBalance,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
    await _database.connection.runCustom(
      'INSERT INTO finance_accounts(id,name,account_type,currency,balance,is_archived,created_at,updated_at) VALUES(?,?,?,?,?,?,?,?)',
      [item.id,item.name,item.type.key,item.currency,item.balance,0,item.createdAt.millisecondsSinceEpoch,item.updatedAt.millisecondsSinceEpoch],
    );
    return item;
  }

  Future<void> updateAccount({
    required String id,
    required String name,
    required FinanceAccountType type,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('نام حساب الزامی است.');
    await _database.connection.runCustom(
      'UPDATE finance_accounts SET name = ?, account_type = ?, updated_at = ? WHERE id = ?',
      [clean,type.key,DateTime.now().toUtc().millisecondsSinceEpoch,id],
    );
  }

  Future<void> archiveAccount(String id, {required bool archived}) async {
    await _database.connection.runCustom(
      'UPDATE finance_accounts SET is_archived = ?, updated_at = ? WHERE id = ?',
      [archived ? 1 : 0,DateTime.now().toUtc().millisecondsSinceEpoch,id],
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
      id: _newId(),
      accountId: accountId,
      title: clean,
      amount: amount,
      type: type,
      note: note.trim(),
      occurredAt: (occurredAt ?? now).toUtc(),
      createdAt: now,
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
      await tx.runCustom('UPDATE finance_accounts SET balance = balance + ?, updated_at = ? WHERE id = ?', [delta,now,row['account_id']]);
    });
  }

  FinanceAccount _accountFromRow(Map<String,Object?> row) => FinanceAccount(
    id: row['id'].toString(),
    name: row['name'].toString(),
    type: FinanceAccountTypeX.fromKey(row['account_type'].toString()),
    currency: row['currency'].toString(),
    balance: int.parse(row['balance'].toString()),
    isArchived: row['is_archived'].toString() == '1',
    createdAt: _date(row['created_at']),
    updatedAt: _date(row['updated_at']),
  );

  FinanceTransaction _transactionFromRow(Map<String,Object?> row) => FinanceTransaction(
    id: row['id'].toString(),
    accountId: row['account_id'].toString(),
    title: row['title'].toString(),
    amount: int.parse(row['amount'].toString()),
    type: FinanceTransactionTypeX.fromKey(row['transaction_type'].toString()),
    note: row['note'].toString(),
    occurredAt: _date(row['occurred_at']),
    createdAt: _date(row['created_at']),
  );

  DateTime _date(Object? value) => DateTime.fromMillisecondsSinceEpoch(int.parse(value.toString()), isUtc: true);
  String _newId() => DateTime.now().toUtc().microsecondsSinceEpoch.toString() + '-' + Random().nextInt(1 << 32).toRadixString(16);
}
