import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/icons/nojin_icon_button.dart';
import '../../../core/icons/nojin_icons.dart';
import '../../../core/iran/iran_bank.dart';
import '../../../core/iran/iran_money.dart';
import '../../../core/iran/iran_number.dart';
import '../../../core/layout/nojin_breakpoints.dart';
import '../../../core/theme/nojin_tokens.dart';
import '../application/finance_state.dart';
import '../domain/finance_models.dart';
import 'installments_section.dart';
import 'debt_receivable_section.dart';
import 'goals_emergency_fund_section.dart';

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeAccountsProvider);
    return Scaffold(appBar: AppBar(title: const Text('مالی'), actions: [NojinIconButton(icon: NojinIconName.add, tooltip: 'حساب جدید', onPressed: () => _accountForm(context, ref)), const SizedBox(width: 8)]),
      body: state.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('بارگذاری مالی انجام نشد'), Text(e.toString()), OutlinedButton(onPressed: () => ref.read(financeAccountsProvider.notifier).refresh(), child: const Text('تلاش دوباره'))])),
        data: (accounts) => _FinanceBody(accounts: accounts, onAdd: () => _accountForm(context, ref))));
  }
  Future<void> _accountForm(BuildContext context, WidgetRef ref) async {
    final d = await showModalBottomSheet<_AccountDraft>(context: context, isScrollControlled: true, useSafeArea: true, builder: (_) => const _AccountForm());
    if (d == null) return;
    try { await ref.read(financeAccountsProvider.notifier).createAccount(name: d.name, type: d.type, currency: d.currency, openingBalance: d.balance, bankName: d.bankName, accountNumber: d.accountNumber, cardNumber: d.cardNumber, sheba: d.sheba); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }
}

class _FinanceBody extends ConsumerWidget {
  const _FinanceBody({required this.accounts, required this.onAdd});
  final List<FinanceAccount> accounts; final VoidCallback onAdd;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final tomanTotal = accounts.where((a) => a.currency == IranCurrency.toman).fold<int>(0, (s, a) => s + a.balance);
    final rialTotal = accounts.where((a) => a.currency == IranCurrency.rial).fold<int>(0, (s, a) => s + a.balance);
    final width = MediaQuery.sizeOf(context).width;
    return Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: NojinBreakpoints.contentMaxWidth(width)), child: ListView(padding: NojinBreakpoints.pagePadding(width), children: [
      Wrap(spacing: 12, runSpacing: 12, children: [
        _BalanceCard(label: 'موجودی تومان', money: IranMoney(tomanTotal)),
        if (rialTotal != 0 || accounts.any((a) => a.currency == IranCurrency.rial)) _BalanceCard(label: 'موجودی ریال', money: IranMoney(rialTotal, currency: IranCurrency.rial)),
      ]),
      const SizedBox(height: 24),
      const _FinanceDashboardSection(),
      const SizedBox(height: 28),
      const InstallmentsSection(),
      const SizedBox(height: 28),
      const DebtReceivableSection(),
      const SizedBox(height: 28),
      const GoalsEmergencyFundSection(),
      const SizedBox(height: 28),
      Row(children: [const Expanded(child: Text('حساب‌ها', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))), Text(IranNumber.format(accounts.length) + ' حساب', style: const TextStyle(color: NojinColors.text2))]),
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
      const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(account.name, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(account.isBankAccount && account.bankName != null ? account.type.label + ' · ' + account.bankName! : account.type.label, style: const TextStyle(color: NojinColors.text3, fontSize: 12), overflow: TextOverflow.ellipsis)])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(IranMoney(account.balance, currency: account.currency).display, style: const TextStyle(fontWeight: FontWeight.w800)), tx.when(data: (v) => Text(IranNumber.format(v.length) + ' تراکنش', style: const TextStyle(color: NojinColors.text3, fontSize: 11)), loading: () => const SizedBox(height: 16), error: (_, __) => const SizedBox.shrink())]), const Icon(Icons.chevron_left, color: NojinColors.text3)]))));
  }
  Future<void> _details(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, builder: (_) => _Details(account: account));
}

class _Details extends ConsumerWidget {
  const _Details({required this.account}); final FinanceAccount account;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(financeTransactionsProvider(account.id));
    return SizedBox(height: MediaQuery.sizeOf(context).height * .72, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Text(account.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(IranMoney(account.balance, currency: account.currency).display, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: NojinColors.indigo)),
      if (account.isBankAccount) ...[const SizedBox(height: 12), _BankDetails(account: account)], const SizedBox(height: 16), Expanded(child: tx.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Text(e.toString()), data: (items) => items.isEmpty ? const Center(child: Text('هنوز تراکنشی ثبت نشده است.')) : ListView.separated(itemCount: items.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) { final item = items[i]; final income = item.type == FinanceTransactionType.income; return ListTile(leading: Icon(income ? Icons.arrow_downward : Icons.arrow_upward, color: income ? NojinColors.success : NojinColors.danger), title: Text(item.title), subtitle: Text(IranMoney(item.amount, currency: account.currency).display), trailing: IconButton(icon: const NojinIcon(NojinIconName.delete, size: 18), onPressed: () async { final repo = await ref.read(financeRepositoryProvider.future); await repo.deleteTransaction(item.id); ref.invalidate(financeTransactionsProvider(account.id)); ref.invalidate(financeAccountsProvider); })); }))), const SizedBox(height: 12), FilledButton.icon(onPressed: () => _addTransaction(context, ref), icon: const NojinIcon(NojinIconName.add, size: 18, color: Colors.white), label: const Text('ثبت تراکنش'))])));
  }
  Future<void> _addTransaction(BuildContext context, WidgetRef ref) async {
    final d = await showModalBottomSheet<_TransactionDraft>(context: context, isScrollControlled: true, useSafeArea: true, builder: (_) => _TransactionForm(currency: account.currency));
    if (d == null) return; try { final repo = await ref.read(financeRepositoryProvider.future); await repo.addTransaction(accountId: account.id, title: d.title, amount: d.amount, type: d.type, note: d.note); ref.invalidate(financeTransactionsProvider(account.id)); ref.invalidate(financeAccountsProvider); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }
}

class _FinanceDashboardSection extends ConsumerWidget { const _FinanceDashboardSection(); @override Widget build(BuildContext context, WidgetRef ref) { final state=ref.watch(financeDashboardProvider); return state.when(loading:()=>const _DashboardSkeleton(),error:(e,_)=>_DashboardError(message:e.toString(),onRetry:()=>ref.invalidate(financeDashboardProvider)),data:(s)=>_DashboardContent(summary:s)); } }
class _DashboardContent extends StatelessWidget { const _DashboardContent({required this.summary}); final FinanceDashboardSummary summary; @override Widget build(BuildContext context) { return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Text('داشبورد مالی',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:12),LayoutBuilder(builder:(context,c){final two=c.maxWidth>=680;final cards=[_MetricCard(title:'درآمد تومان',value:IranMoney(summary.tomanIncome).display,icon:NojinIconName.arrowDown,tone:NojinColors.success),_MetricCard(title:'هزینه تومان',value:IranMoney(summary.tomanExpense).display,icon:NojinIconName.arrowUp,tone:NojinColors.danger),_MetricCard(title:'خالص تومان',value:IranMoney(summary.tomanNet).display,icon:NojinIconName.finance,tone:NojinColors.indigo)];return GridView.count(crossAxisCount:two?3:1,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:two?2.55:4.2,children:cards);}),if(summary.rialIncome!=0||summary.rialExpense!=0)...[const SizedBox(height:10),_MiniCurrencySummary(summary:summary)],const SizedBox(height:14),LayoutBuilder(builder:(context,c){if(c.maxWidth<720)return Column(children:[_TopExpenses(items:summary.topExpenses),const SizedBox(height:12),_RecentTransactions(items:summary.recent)]);return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:_TopExpenses(items:summary.topExpenses)),const SizedBox(width:12),Expanded(child:_RecentTransactions(items:summary.recent))]);})]); } }
class _MetricCard extends StatelessWidget { const _MetricCard({required this.title,required this.value,required this.icon,required this.tone}); final String title,value; final NojinIconName icon; final Color tone; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:NojinColors.surface,borderRadius:BorderRadius.circular(NojinRadii.lg),border:Border.all(color:NojinColors.border)),child:Row(children:[Container(width:40,height:40,decoration:BoxDecoration(color:tone.withValues(alpha:.10),shape:BoxShape.circle),child:NojinIcon(icon,size:19,color:tone)),const SizedBox(width:10),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:NojinColors.text3,fontSize:11)),const SizedBox(height:4),Text(value,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900))]))])); }
class _MiniCurrencySummary extends StatelessWidget { const _MiniCurrencySummary({required this.summary}); final FinanceDashboardSummary summary; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:NojinColors.surface,borderRadius:BorderRadius.circular(NojinRadii.lg),border:Border.all(color:NojinColors.border)),child:Wrap(spacing:20,runSpacing:8,children:[const Text('ریال',style:TextStyle(fontWeight:FontWeight.w800)),Text('درآمد: '+IranMoney(summary.rialIncome,currency:IranCurrency.rial).display),Text('هزینه: '+IranMoney(summary.rialExpense,currency:IranCurrency.rial).display),Text('خالص: '+IranMoney(summary.rialNet,currency:IranCurrency.rial).display,style:const TextStyle(fontWeight:FontWeight.w700))])); }
class _DashboardPanel extends StatelessWidget { const _DashboardPanel({required this.title,required this.child}); final String title; final Widget child; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:NojinColors.surface,borderRadius:BorderRadius.circular(NojinRadii.lg),border:Border.all(color:NojinColors.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Text(title,style:const TextStyle(fontSize:14,fontWeight:FontWeight.w800)),const SizedBox(height:12),child])); }
class _TopExpenses extends StatelessWidget { const _TopExpenses({required this.items}); final List<FinanceDashboardAggregate> items; @override Widget build(BuildContext context)=>_DashboardPanel(title:'بیشترین هزینه‌ها',child:items.isEmpty?const _DashboardEmpty(text:'هنوز هزینه‌ای ثبت نشده است.'):Column(children:items.map((item){final max=items.first.total<=0?1:items.first.total;final ratio=(item.total/max).clamp(0.0,1.0);return Padding(padding:const EdgeInsets.only(bottom:11),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Row(children:[Expanded(child:Text(item.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700))),Text(IranMoney(item.total,currency:item.currency).display,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800))]),const SizedBox(height:5),ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(minHeight:6,value:ratio,backgroundColor:NojinColors.border))]));}).toList())); }
class _RecentTransactions extends StatelessWidget { const _RecentTransactions({required this.items}); final List<FinanceDashboardTransaction> items; @override Widget build(BuildContext context)=>_DashboardPanel(title:'آخرین تراکنش‌ها',child:items.isEmpty?const _DashboardEmpty(text:'هنوز تراکنشی ثبت نشده است.'):Column(children:items.map((item){final income=item.transaction.type==FinanceTransactionType.income;return ListTile(dense:true,contentPadding:EdgeInsets.zero,leading:Container(width:34,height:34,decoration:BoxDecoration(color:(income?NojinColors.success:NojinColors.danger).withValues(alpha:.10),shape:BoxShape.circle),child:NojinIcon(income?NojinIconName.arrowDown:NojinIconName.arrowUp,size:16,color:income?NojinColors.success:NojinColors.danger)),title:Text(item.transaction.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700)),subtitle:Text(item.accountName,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10,color:NojinColors.text3)),trailing:Text((income?'+':'-')+IranMoney(item.transaction.amount,currency:item.currency).display,style:TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:income?NojinColors.success:NojinColors.danger)));}).toList())); }
class _DashboardEmpty extends StatelessWidget { const _DashboardEmpty({required this.text}); final String text; @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:22),child:Text(text,textAlign:TextAlign.center,style:const TextStyle(color:NojinColors.text3,fontSize:12))); }
class _DashboardSkeleton extends StatelessWidget { const _DashboardSkeleton(); @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:NojinColors.surface,borderRadius:BorderRadius.circular(NojinRadii.lg),border:Border.all(color:NojinColors.border)),child:const Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Text('داشبورد مالی',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),SizedBox(height:14),LinearProgressIndicator(),SizedBox(height:12),Text('در حال محاسبه گزارش‌های مالی...',style:TextStyle(color:NojinColors.text3))])); }
class _DashboardError extends StatelessWidget { const _DashboardError({required this.message,required this.onRetry}); final String message; final VoidCallback onRetry; @override Widget build(BuildContext context)=>_DashboardPanel(title:'داشبورد مالی',child:Column(children:[const Text('گزارش مالی در دسترس نیست.',style:TextStyle(fontWeight:FontWeight.w700)),const SizedBox(height:6),Text(message,maxLines:2,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:const TextStyle(color:NojinColors.text3,fontSize:11)),const SizedBox(height:10),OutlinedButton(onPressed:onRetry,child:const Text('تلاش دوباره'))])); }

class _AccountForm extends StatefulWidget { const _AccountForm(); @override State<_AccountForm> createState() => _AccountFormState(); }
class _AccountFormState extends State<_AccountForm> {
  final name = TextEditingController();
  final balance = TextEditingController();
  final bankName = TextEditingController();
  final accountNumber = TextEditingController();
  final cardNumber = TextEditingController();
  final sheba = TextEditingController();
  FinanceAccountType type = FinanceAccountType.bank;
  IranCurrency currency = IranCurrency.toman;
  @override void dispose() { name.dispose(); balance.dispose(); bankName.dispose(); accountNumber.dispose(); cardNumber.dispose(); sheba.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final bank = type == FinanceAccountType.bank;
    return SingleChildScrollView(padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.viewInsetsOf(context).bottom), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('حساب جدید', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'نام حساب')), const SizedBox(height: 12),
      DropdownButtonFormField<FinanceAccountType>(initialValue: type, decoration: const InputDecoration(labelText: 'نوع حساب'), items: FinanceAccountType.values.map((v) => DropdownMenuItem(value: v, child: Text(v.label))).toList(), onChanged: (v) => setState(() => type = v ?? type)), const SizedBox(height: 12),
      DropdownButtonFormField<IranCurrency>(initialValue: currency, decoration: const InputDecoration(labelText: 'واحد پول'), items: const [DropdownMenuItem(value: IranCurrency.toman, child: Text('تومان')), DropdownMenuItem(value: IranCurrency.rial, child: Text('ریال'))], onChanged: (v) => setState(() => currency = v ?? currency)), const SizedBox(height: 12),
      TextField(controller: balance, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'موجودی اولیه (' + (currency == IranCurrency.toman ? 'تومان' : 'ریال') + ')')),
      if (bank) ...[
        const SizedBox(height: 18), const Align(alignment: Alignment.centerRight, child: Text('اطلاعات بانکی', style: TextStyle(fontWeight: FontWeight.w800))), const SizedBox(height: 10),
        TextField(controller: bankName, decoration: const InputDecoration(labelText: 'نام بانک')), const SizedBox(height: 10),
        TextField(controller: accountNumber, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'شماره حساب')), const SizedBox(height: 10),
        TextField(controller: cardNumber, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'شماره کارت ۱۶ رقمی')), const SizedBox(height: 10),
        TextField(controller: sheba, decoration: const InputDecoration(labelText: 'شماره شبا', hintText: 'IR...')),
      ],
      const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton(onPressed: () { final value = int.tryParse(IranNumber.toEnglish(balance.text).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0; Navigator.pop(context, _AccountDraft(name.text, type, currency, value, bankName.text, accountNumber.text, cardNumber.text, sheba.text)); }, child: const Text('ایجاد حساب')),
    ]));
  }
}
class _TransactionForm extends StatefulWidget { const _TransactionForm({required this.currency}); final IranCurrency currency; @override State<_TransactionForm> createState() => _TransactionFormState(); }
class _TransactionFormState extends State<_TransactionForm> {
  final title = TextEditingController(); final amount = TextEditingController(); final note = TextEditingController(); FinanceTransactionType type = FinanceTransactionType.expense;
  @override void dispose() { title.dispose(); amount.dispose(); note.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Padding(padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.viewInsetsOf(context).bottom), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('تراکنش جدید', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16), SegmentedButton<FinanceTransactionType>(segments: const [ButtonSegment(value: FinanceTransactionType.expense, label: Text('هزینه')), ButtonSegment(value: FinanceTransactionType.income, label: Text('درآمد'))], selected: {type}, onSelectionChanged: (v) => setState(() => type = v.first)), const SizedBox(height: 12), TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان')), const SizedBox(height: 12), TextField(controller: amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'مبلغ (' + (widget.currency == IranCurrency.toman ? 'تومان' : 'ریال') + ')')), const SizedBox(height: 12), TextField(controller: note, decoration: const InputDecoration(labelText: 'یادداشت (اختیاری)')), const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context, _TransactionDraft(title.text, int.tryParse(IranNumber.toEnglish(amount.text).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0, type, note.text)), child: const Text('ثبت تراکنش')))]));
}
class _AccountDraft { const _AccountDraft(this.name, this.type, this.currency, this.balance, this.bankName, this.accountNumber, this.cardNumber, this.sheba); final String name; final FinanceAccountType type; final IranCurrency currency; final int balance; final String bankName; final String accountNumber; final String cardNumber; final String sheba; }
class _TransactionDraft { const _TransactionDraft(this.title, this.amount, this.type, this.note); final String title; final int amount; final FinanceTransactionType type; final String note; }

class _BankDetails extends StatelessWidget { const _BankDetails({required this.account}); final FinanceAccount account; @override Widget build(BuildContext context) { final rows = <String>[if (account.bankName != null) 'بانک: ' + account.bankName!, if (account.accountNumber != null) 'حساب: ' + account.accountNumber!, if (account.cardNumber != null) 'کارت: ' + IranBank.formatCard(account.cardNumber!), if (account.sheba != null) 'شبا: ' + IranBank.formatSheba(account.sheba!)]; if (rows.isEmpty) return const Align(alignment: Alignment.centerRight, child: Text('اطلاعات بانکی ثبت نشده است.', style: TextStyle(color: NojinColors.text3))); return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: NojinColors.surface, borderRadius: BorderRadius.circular(NojinRadii.md), border: Border.all(color: NojinColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows.map((v) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: SelectableText(v, textDirection: TextDirection.ltr, textAlign: TextAlign.right))).toList())); } }
class _BalanceCard extends StatelessWidget { const _BalanceCard({required this.label, required this.money}); final String label; final IranMoney money; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), constraints: const BoxConstraints(minWidth: 240), decoration: BoxDecoration(gradient: NojinGradients.primary, borderRadius: BorderRadius.circular(NojinRadii.lg)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 8), Text(money.display, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))])); }

class _Empty extends StatelessWidget { const _Empty({required this.onAdd}); final VoidCallback onAdd; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: NojinColors.surface, borderRadius: BorderRadius.circular(NojinRadii.lg), border: Border.all(color: NojinColors.border)), child: Column(children: [const Icon(Icons.account_balance_wallet_outlined, size: 42, color: NojinColors.indigo), const SizedBox(height: 12), const Text('هنوز حسابی ساخته نشده است.', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), const Text('اولین حساب مالی خود را بسازید تا ثبت تراکنش‌ها را شروع کنید.', textAlign: TextAlign.center, style: TextStyle(color: NojinColors.text2)), const SizedBox(height: 16), FilledButton.icon(onPressed: onAdd, icon: const NojinIcon(NojinIconName.add, size: 18, color: Colors.white), label: const Text('افزودن حساب'))])); }