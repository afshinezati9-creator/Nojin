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
    final today = DateTime.utc(now.year, now.month, now.day);
    final dueDate = DateTime.utc(dueAt.year, dueAt.month, dueAt.day);
    return today.isAfter(dueDate) ? InstallmentStatus.overdue : InstallmentStatus.pending;
  }
}



enum FinanceDebtType { receivable, payable }

extension FinanceDebtTypeX on FinanceDebtType {
  String get key => name;
  String get label => this == FinanceDebtType.receivable ? 'طلب از دیگران' : 'بدهی به دیگران';
  static FinanceDebtType fromKey(String value) => FinanceDebtType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => FinanceDebtType.payable,
  );
}

enum FinanceDebtStatus { open, partial, settled, overdue }

extension FinanceDebtStatusX on FinanceDebtStatus {
  String get label => switch (this) {
    FinanceDebtStatus.open => 'باز',
    FinanceDebtStatus.partial => 'بخشی پرداخت‌شده',
    FinanceDebtStatus.settled => 'تسویه‌شده',
    FinanceDebtStatus.overdue => 'سررسید گذشته',
  };
}

class FinanceDebt {
  const FinanceDebt({
    required this.id,
    required this.title,
    required this.personName,
    required this.type,
    required this.totalAmount,
    required this.settledAmount,
    required this.currency,
    required this.dueAt,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String personName;
  final FinanceDebtType type;
  final int totalAmount;
  final int settledAmount;
  final IranCurrency currency;
  final DateTime? dueAt;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get remainingAmount => totalAmount - settledAmount;

  FinanceDebtStatus statusAt(DateTime now) {
    if (remainingAmount <= 0) return FinanceDebtStatus.settled;
    if (dueAt != null) {
      final today = DateTime.utc(now.year, now.month, now.day);
      final due = DateTime.utc(dueAt!.year, dueAt!.month, dueAt!.day);
      if (today.isAfter(due)) return FinanceDebtStatus.overdue;
    }
    return settledAmount > 0 ? FinanceDebtStatus.partial : FinanceDebtStatus.open;
  }
}

class FinanceDebtPayment {
  const FinanceDebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.accountId,
    required this.transactionId,
    required this.paidAt,
    required this.note,
  });

  final String id;
  final String debtId;
  final int amount;
  final String accountId;
  final String transactionId;
  final DateTime paidAt;
  final String note;
}


enum FinanceGoalType { goal, emergencyFund }

extension FinanceGoalTypeX on FinanceGoalType {
  String get label => this == FinanceGoalType.emergencyFund ? 'صندوق اضطراری' : 'هدف مالی';
  static FinanceGoalType fromKey(String value) => FinanceGoalType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => FinanceGoalType.goal,
  );
}

enum FinanceGoalStatus { active, completed, overdue }

extension FinanceGoalStatusX on FinanceGoalStatus {
  String get label => switch (this) {
    FinanceGoalStatus.active => 'در حال پیشرفت',
    FinanceGoalStatus.completed => 'تکمیل‌شده',
    FinanceGoalStatus.overdue => 'مهلت گذشته',
  };
}

class FinanceGoal {
  const FinanceGoal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.dueAt,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final FinanceGoalType type;
  final int targetAmount;
  final int currentAmount;
  final IranCurrency currency;
  final DateTime? dueAt;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get remainingAmount => (targetAmount - currentAmount).clamp(0, targetAmount);
  double get progress => targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  FinanceGoalStatus statusAt(DateTime now) {
    if (currentAmount >= targetAmount) return FinanceGoalStatus.completed;
    if (dueAt != null) {
      final today = DateTime.utc(now.year, now.month, now.day);
      final due = DateTime.utc(dueAt!.year, dueAt!.month, dueAt!.day);
      if (today.isAfter(due)) return FinanceGoalStatus.overdue;
    }
    return FinanceGoalStatus.active;
  }
}

class FinanceGoalEntry {
  const FinanceGoalEntry({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.isWithdrawal,
    required this.occurredAt,
    required this.note,
  });

  final String id;
  final String goalId;
  final int amount;
  final bool isWithdrawal;
  final DateTime occurredAt;
  final String note;
}
