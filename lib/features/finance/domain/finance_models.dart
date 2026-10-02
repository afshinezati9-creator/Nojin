import '../../../core/iran/iran_money.dart';

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
  static FinanceAccountType fromKey(String value) => FinanceAccountType.values.firstWhere((item) => item.name == value, orElse: () => FinanceAccountType.other);
}

enum FinanceTransactionType { income, expense }

extension FinanceTransactionTypeX on FinanceTransactionType {
  String get key => name;
  String get label => this == FinanceTransactionType.income ? 'درآمد' : 'هزینه';
}

class FinanceAccount {
  const FinanceAccount({
    required this.id, required this.name, required this.type, required this.currency,
    required this.balance, required this.isArchived, required this.bankName,
    required this.accountNumber, required this.cardNumber, required this.sheba,
    required this.createdAt, required this.updatedAt,
  });
  final String id;
  final String name;
  final FinanceAccountType type;
  final IranCurrency currency;
  final int balance;
  final bool isArchived;
  final String? bankName;
  final String? accountNumber;
  final String? cardNumber;
  final String? sheba;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool get isBankAccount => type == FinanceAccountType.bank;
}

class FinanceTransaction {
  const FinanceTransaction({
    required this.id, required this.accountId, required this.title, required this.amount,
    required this.type, required this.note, required this.occurredAt, required this.createdAt,
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


class FinanceDashboardAggregate {
  const FinanceDashboardAggregate({required this.title, required this.total, required this.currency});
  final String title;
  final int total;
  final IranCurrency currency;
}

class FinanceDashboardTransaction {
  const FinanceDashboardTransaction({required this.transaction, required this.accountName, required this.currency});
  final FinanceTransaction transaction;
  final String accountName;
  final IranCurrency currency;
}

class FinanceDashboardSummary {
  const FinanceDashboardSummary({
    required this.tomanIncome, required this.tomanExpense,
    required this.rialIncome, required this.rialExpense,
    required this.recent, required this.topExpenses,
  });
  final int tomanIncome;
  final int tomanExpense;
  final int rialIncome;
  final int rialExpense;
  final List<FinanceDashboardTransaction> recent;
  final List<FinanceDashboardAggregate> topExpenses;

  int get tomanNet => tomanIncome - tomanExpense;
  int get rialNet => rialIncome - rialExpense;
  bool get isEmpty => tomanIncome == 0 && tomanExpense == 0 && rialIncome == 0 && rialExpense == 0 && recent.isEmpty;
}


enum InstallmentStatus { paid, overdue, pending }

extension InstallmentStatusX on InstallmentStatus {
  String get label => switch (this) {
    InstallmentStatus.paid => 'پرداخت‌شده',
    InstallmentStatus.overdue => 'معوق',
    InstallmentStatus.pending => 'در انتظار',
  };
}

class FinanceInstallmentPlan {
  const FinanceInstallmentPlan({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.installmentAmount,
    required this.installmentCount,
    required this.currency,
    required this.firstDueAt,
    required this.intervalMonths,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String title;
  final int totalAmount;
  final int installmentAmount;
  final int installmentCount;
  final IranCurrency currency;
  final DateTime firstDueAt;
  final int intervalMonths;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class FinanceInstallment {
  const FinanceInstallment({
    required this.id,
    required this.planId,
    required this.sequence,
    required this.dueAt,
    required this.amount,
    required this.paidAt,
    required this.transactionId,
  });
  final String id;
  final String planId;
  final int sequence;
  final DateTime dueAt;
  final int amount;
  final DateTime? paidAt;
  final String? transactionId;

  InstallmentStatus statusAt(DateTime now) {
    if (paidAt != null) return InstallmentStatus.paid;
    return now.isAfter(dueAt) ? InstallmentStatus.overdue : InstallmentStatus.pending;
  }
}
