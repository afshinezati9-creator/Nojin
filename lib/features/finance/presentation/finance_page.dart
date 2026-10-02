import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/icons/nojin_icon_button.dart';
import '../../../core/icons/nojin_icons.dart';
import '../../../core/iran/iran_money.dart';
import '../../../core/iran/iran_number.dart';
import '../../../core/layout/nojin_breakpoints.dart';
import '../../../core/theme/nojin_tokens.dart';
import '../application/finance_state.dart';
import '../domain/finance_models.dart';

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeAccountsProvider);
    return Scaffold(appBar: AppBar(title: const Text('مالی'), actions: [NojinIconButton(icon: NojinIconName.add, tooltip: 'حساب جدید', onPressed: () => _accountForm(context, ref)), const SizedBox(width: 8)]),
      body: state.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('بارگذاری مالی انجام نشد'), Text(e.toString()), OutlinedButton(onPressed: () => ref.read(financeAccountsProvider.notifier).refresh(), child: const Text('تلاش دوباره'))])),
        data: (accounts) => _FinanceBody(accounts: accounts, onAdd: () => _accountForm(context, ref)));
  }
  Future<void> _accountForm(BuildContext context, WidgetRef ref) async {
    final d = await showModalBottomSheet<_AccountDraft>(context: context, isScrollControlled: true, useSafeArea: true, builder: (_) => const _AccountForm());
    if (d == null) return;
    try { await ref.read(financeAccountsProvider.notifier).createAccount(name: d.name, type: d.type, openingBalance: d.balance); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }
}

class _FinanceBody extends ConsumerWidget {
  const _FinanceBody({required this.accounts, required this.onAdd});
  final List<FinanceAccount> accounts; final VoidCallback onAdd;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final total = accounts.fold<int>(0, (s, a) => s + a.balance);
    final width = MediaQuery.sizeOf(context).width;
    return Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: NojinBreakpoints.contentMaxWidth(width)), child: ListView(padding: NojinBreakpoints.pagePadding(width), children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: NojinGradients.primary, borderRadius: BorderRadius.circular(NojinRadii.lg)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('موجودی کل', style: TextStyle(color: Colors.white70)), const SizedBox(height: 8), Text(IranMoney(total).display, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)), const Text('تومان', style: TextStyle(color: Colors.white70))])),
      const SizedBox(height: 24), Row(children: [const Expanded(child: Text('حساب‌ها', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))), Text(IranNumber.format(accounts.length) + ' حساب', style: const TextStyle(color: NojinColors.text2))]),
      const SizedBox(height: 12), if (accounts.isEmpty) _Empty(onAdd: onAdd) else ...accounts.map((a) => _AccountCard(account: a)),
    ])));
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.account}); final FinanceAccount account;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(financeTransactionsProvider(account.id));
    return Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(borderRadius: BorderRadius.circular(NojinRadii.lg), onTap: () => _details(context, ref), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Container(width: 48, height: 48, decoration: const BoxDecoration(gradient: NojinGradients.soft, shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet_outlined, color: NojinColors.indigo)),
      const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(account.name, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(account.type.label, style: const TextStyle(color: NojinColors.text3, fontSize: 12))])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(IranMoney(account.balance).display, style: const TextStyle(fontWeight: FontWeight.w800)), tx.when(data: (v) => Text(IranNumber.format(v.length) + ' تراکنش', style: const TextStyle(color: NojinColors.text3, fontSize: 11)), loading: () => const SizedBox(height: 16), error: (_, __) => const SizedBox.shrink())]), const Icon(Icons.chevron_left, color: NojinColors.text3)]))));
  }
  Future<void> _details(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, builder: (_) => _Details(account: account));
}

class _Details extends ConsumerWidget {
  const _Details({required this.account}); final FinanceAccount account;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(financeTransactionsProvider(account.id));
    return SizedBox(height: MediaQuery.sizeOf(context).height * .72, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Text(account.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(IranMoney.format(account.balance), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: NojinColors.indigo)), const SizedBox(height: 16), Expanded(child: tx.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Text(e.toString()), data: (items) => items.isEmpty ? const Center(child: Text('هنوز تراکنشی ثبت نشده است.')) : ListView.separated(itemCount: items.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) { final item = items[i]; final income = item.type == FinanceTransactionType.income; return ListTile(leading: Icon(income ? Icons.arrow_downward : Icons.arrow_upward, color: income ? NojinColors.success : NojinColors.danger), title: Text(item.title), subtitle: Text(IranNumber.format(item.amount)), trailing: IconButton(icon: const NojinIcon(NojinIconName.delete, size: 18), onPressed: () async { final repo = await ref.read(financeRepositoryProvider.future); await repo.deleteTransaction(item.id); ref.invalidate(financeTransactionsProvider(account.id)); ref.invalidate(financeAccountsProvider); })); }))), const SizedBox(height: 12), FilledButton.icon(onPressed: () => _addTransaction(context, ref), icon: const NojinIcon(NojinIconName.add, size: 18, color: Colors.white), label: const Text('ثبت تراکنش'))])));
  }
  Future<void> _addTransaction(BuildContext context, WidgetRef ref) async {
    final d = await showModalBottomSheet<_TransactionDraft>(context: context, isScrollControlled: true, useSafeArea: true, builder: (_) => const _TransactionForm());
    if (d == null) return; try { final repo = await ref.read(financeRepositoryProvider.future); await repo.addTransaction(accountId: account.id, title: d.title, amount: d.amount, type: d.type, note: d.note); ref.invalidate(financeTransactionsProvider(account.id)); ref.invalidate(financeAccountsProvider); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }
}

class _AccountForm extends StatefulWidget { const _AccountForm(); @override State<_AccountForm> createState() => _AccountFormState(); }
class _AccountFormState extends State<_AccountForm> {
  final name = TextEditingController(); final balance = TextEditingController(); FinanceAccountType type = FinanceAccountType.bank;
  @override void dispose() { name.dispose(); balance.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Padding(padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.viewInsetsOf(context).bottom), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('حساب جدید', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16), TextField(controller: name, decoration: const InputDecoration(labelText: 'نام حساب')), const SizedBox(height: 12), DropdownButtonFormField<FinanceAccountType>(initialValue: type, decoration: const InputDecoration(labelText: 'نوع حساب'), items: FinanceAccountType.values.map((v) => DropdownMenuItem(value: v, child: Text(v.label))).toList(), onChanged: (v) => setState(() => type = v ?? type)), const SizedBox(height: 12), TextField(controller: balance, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'موجودی اولیه (تومان)')), const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context, _AccountDraft(name.text, type, int.tryParse(balance.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)), child: const Text('ایجاد حساب')))]));
}
class _TransactionForm extends StatefulWidget { const _TransactionForm(); @override State<_TransactionForm> createState() => _TransactionFormState(); }
class _TransactionFormState extends State<_TransactionForm> {
  final title = TextEditingController(); final amount = TextEditingController(); final note = TextEditingController(); FinanceTransactionType type = FinanceTransactionType.expense;
  @override void dispose() { title.dispose(); amount.dispose(); note.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Padding(padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.viewInsetsOf(context).bottom), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('تراکنش جدید', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16), SegmentedButton<FinanceTransactionType>(segments: const [ButtonSegment(value: FinanceTransactionType.expense, label: Text('هزینه')), ButtonSegment(value: FinanceTransactionType.income, label: Text('درآمد'))], selected: {type}, onSelectionChanged: (v) => setState(() => type = v.first)), const SizedBox(height: 12), TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان')), const SizedBox(height: 12), TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مبلغ (تومان)')), const SizedBox(height: 12), TextField(controller: note, decoration: const InputDecoration(labelText: 'یادداشت (اختیاری)')), const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context, _TransactionDraft(title.text, int.tryParse(amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0, type, note.text)), child: const Text('ثبت تراکنش')))]));
}
class _AccountDraft { const _AccountDraft(this.name, this.type, this.balance); final String name; final FinanceAccountType type; final int balance; }
class _TransactionDraft { const _TransactionDraft(this.title, this.amount, this.type, this.note); final String title; final int amount; final FinanceTransactionType type; final String note; }
class _Empty extends StatelessWidget { const _Empty({required this.onAdd}); final VoidCallback onAdd; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: NojinColors.surface, borderRadius: BorderRadius.circular(NojinRadii.lg), border: Border.all(color: NojinColors.border)), child: Column(children: [const Icon(Icons.account_balance_wallet_outlined, size: 42, color: NojinColors.indigo), const SizedBox(height: 12), const Text('هنوز حسابی ساخته نشده است.', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), const Text('اولین حساب مالی خود را بسازید تا ثبت تراکنش‌ها را شروع کنید.', textAlign: TextAlign.center, style: TextStyle(color: NojinColors.text2)), const SizedBox(height: 16), FilledButton.icon(onPressed: onAdd, icon: const NojinIcon(NojinIconName.add, size: 18, color: Colors.white), label: const Text('افزودن حساب'))])); }