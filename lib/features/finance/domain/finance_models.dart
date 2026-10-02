enum FinanceAccountType { cash, bank, wallet, savings, other }

extension FinanceAccountTypeX on FinanceAccountType {
  String get key => name;
  String get label => switch (this) {
    FinanceAccountType.cash => 'نقدی',
    FinanceAccountType.bank => 'حساب بانکی',
    FinanceAccountType.wallet => 'کیف پول',
    FinanceAccountType.savings => 'پس‌انداز',
    FinanceAccountType.other => 'سایر',
  };
  static FinanceAccountType fromKey(String value) => FinanceAccountType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => FinanceAccountType.other,
  );
}

enum FinanceTransactionType { income, expense }

extension FinanceTransactionTypeX on FinanceTransactionType {
  String get key => name;
  String get label => this == FinanceTransactionType.income ? 'درآمد' : 'هزینه';
}

class FinanceAccount {
  const FinanceAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final FinanceAccountType type;
  final String currency;
  final int balance;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.accountId,
    required this.title,
    required this.amount,
    required this.type,
    required this.note,
    required this.occurredAt,
    required this.createdAt,
  });

  final String id;
  final String accountId;
  final String title;
  final int amount;
  final FinanceTransactionType type;
  final String note;
  final DateTime occurredAt;
  final DateTime createdAt;
}
