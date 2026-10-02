import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/nojin_database_provider.dart';
import '../../../core/iran/iran_money.dart';
import '../data/finance_repository.dart';
import '../domain/finance_models.dart';

final financeRepositoryProvider = FutureProvider<FinanceRepository>((ref) async {
  return FinanceRepository(await ref.watch(nojinDatabaseProvider.future));
});

final financeAccountsProvider = AsyncNotifierProvider<FinanceAccountsNotifier, List<FinanceAccount>>(
  FinanceAccountsNotifier.new,
);

class FinanceAccountsNotifier extends AsyncNotifier<List<FinanceAccount>> {
  @override
  Future<List<FinanceAccount>> build() async {
    return ref.read(financeRepositoryProvider).valueOrNull?.listAccounts() ??
        await ref.read(financeRepositoryProvider.future).then((repo) => repo.listAccounts());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(financeRepositoryProvider.future).then((r) => r.listAccounts()),
    );
  }

  Future<void> createAccount({
    required String name,
    required FinanceAccountType type,
    required IranCurrency currency,
    required int openingBalance,
    String? bankName,
    String? accountNumber,
    String? cardNumber,
    String? sheba,
  }) async {
    final repo = await ref.read(financeRepositoryProvider.future);
    await repo.createAccount(
      name: name,
      type: type,
      currency: currency,
      openingBalance: openingBalance,
      bankName: bankName,
      accountNumber: accountNumber,
      cardNumber: cardNumber,
      sheba: sheba,
    );
    await refresh();
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
    final repo = await ref.read(financeRepositoryProvider.future);
    await repo.updateAccount(
      id: id,
      name: name,
      type: type,
      currency: currency,
      bankName: bankName,
      accountNumber: accountNumber,
      cardNumber: cardNumber,
      sheba: sheba,
    );
    await refresh();
  }

  Future<void> archive(String id, bool value) async {
    final repo = await ref.read(financeRepositoryProvider.future);
    await repo.archiveAccount(id, archived: value);
    await refresh();
  }
}

final financeTransactionsProvider = FutureProvider.family<List<FinanceTransaction>, String>(
  (ref, accountId) async {
    final repo = await ref.watch(financeRepositoryProvider.future);
    return repo.listTransactions(accountId);
  },
);


final financeDashboardProvider = FutureProvider<FinanceDashboardSummary>((ref) async {
  final repo = await ref.watch(financeRepositoryProvider.future);
  return repo.dashboardSummary();
});


final financeInstallmentPlansProvider = FutureProvider<List<FinanceInstallmentPlan>>((ref) async {
  final repo = await ref.watch(financeRepositoryProvider.future);
  return repo.listInstallmentPlans();
});

final financeInstallmentsProvider = FutureProvider.family<List<FinanceInstallment>, String>((ref, planId) async {
  final repo = await ref.watch(financeRepositoryProvider.future);
  return repo.listInstallments(planId);
});

final financeDebtsProvider = FutureProvider<List<FinanceDebt>>((ref) async {
  final repo = await ref.watch(financeRepositoryProvider.future);
  return repo.listDebts();
});

final financeDebtPaymentsProvider = FutureProvider.family<List<FinanceDebtPayment>, String>((ref, debtId) async {
  final repo = await ref.watch(financeRepositoryProvider.future);
  return repo.listDebtPayments(debtId);
});

final financeGoalsProvider = FutureProvider<List<FinanceGoal>>((ref) async {
  final repo = await ref.watch(financeRepositoryProvider.future);
  return repo.listGoals();
});

final financeGoalEntriesProvider = FutureProvider.family<List<FinanceGoalEntry>, String>((ref, goalId) async {
  final repo = await ref.watch(financeRepositoryProvider.future);
  return repo.listGoalEntries(goalId);
});
