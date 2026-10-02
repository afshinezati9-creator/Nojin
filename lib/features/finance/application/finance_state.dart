import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/nojin_database_provider.dart';
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
    state = await AsyncValue.guard(() => ref.read(financeRepositoryProvider.future).then((r) => r.listAccounts()));
  }

  Future<void> createAccount({
    required String name,
    required FinanceAccountType type,
    required int openingBalance,
  }) async {
    final repo = await ref.read(financeRepositoryProvider.future);
    await repo.createAccount(name: name, type: type, openingBalance: openingBalance);
    await refresh();
  }

  Future<void> archive(String id, bool value) async {
    final repo = await ref.read(financeRepositoryProvider.future);
    await repo.archiveAccount(id, archived: value);
    await refresh();
  }
}

final financeTransactionsProvider = FutureProvider.family<List<FinanceTransaction>, String>((ref, accountId) async {
  final repo = await ref.watch(financeRepositoryProvider.future);
  return repo.listTransactions(accountId);
});
