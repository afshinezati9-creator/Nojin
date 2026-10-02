import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/iran/iran_date.dart';
import '../../../core/iran/iran_money.dart';
import '../../../core/iran/iran_number.dart';
import '../../../core/theme/nojin_tokens.dart';
import '../application/finance_state.dart';
import '../domain/finance_models.dart';

class DebtReceivableSection extends ConsumerWidget {
  const DebtReceivableSection({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final state=ref.watch(financeDebtsProvider);
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Row(children:[const Expanded(child:Text('بدهی و طلب',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800))),OutlinedButton(onPressed:()=>_create(context,ref),child:const Text('ثبت مورد جدید'))]),
      const SizedBox(height:12),
      state.when(
        loading:()=>const LinearProgressIndicator(),
        error:(e,_)=>Column(children:[Text(e.toString()),OutlinedButton(onPressed:()=>ref.invalidate(financeDebtsProvider),child:const Text('تلاش دوباره'))]),
        data:(items)=>items.isEmpty?const _Empty():Column(children:items.map((d)=>Padding(padding:const EdgeInsets.only(bottom:10),child:_Card(debt:d))).toList()),
      ),
    ]);
  }
  Future<void> _create(BuildContext context,WidgetRef ref)async{
    final d=await showModalBottomSheet<_Draft>(context:context,isScrollControlled:true,useSafeArea:true,builder:(_)=>const _Form());
    if(d==null)return;
    try{final repo=await ref.read(financeRepositoryProvider.future);await repo.createDebt(title:d.title,personName:d.person,type:d.type,totalAmount:d.amount,currency:d.currency,dueAt:d.dueAt,note:d.note);ref.invalidate(financeDebtsProvider);}
    catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
  }
}
class _Card extends ConsumerWidget{
  const _Card({required this.debt});final FinanceDebt debt;
  @override Widget build(BuildContext context,WidgetRef ref){
    final s=debt.statusAt(DateTime.now().toUtc());
    final color=s==FinanceDebtStatus.settled?NojinColors.success:s==FinanceDebtStatus.overdue?NojinColors.danger:s==FinanceDebtStatus.partial?NojinColors.warning:NojinColors.indigo;
    final progress=debt.totalAmount==0?0.0:(debt.settledAmount/debt.totalAmount).clamp(0.0,1.0);
    return Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:NojinColors.surface,borderRadius:BorderRadius.circular(NojinRadii.lg),border:Border.all(color:NojinColors.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Row(children:[Expanded(child:Text(debt.title,style:const TextStyle(fontWeight:FontWeight.w800))),Text(debt.type.label,style:TextStyle(color:color,fontWeight:FontWeight.w700,fontSize:11))]),
      const SizedBox(height:5),Text(debt.personName,style:const TextStyle(color:NojinColors.text2)),const SizedBox(height:8),
      Wrap(spacing:14,runSpacing:6,children:[
        Text('کل: '+IranMoney(debt.totalAmount,currency:debt.currency).display),
        Text('مانده: '+IranMoney(debt.remainingAmount,currency:debt.currency).display,style:TextStyle(color:color,fontWeight:FontWeight.w700)),
        if(debt.dueAt!=null)Text('سررسید: '+IranDate.fromDateTime(debt.dueAt!).display,style:const TextStyle(fontSize:11,color:NojinColors.text2)),
        Text(s.label,style:TextStyle(color:color,fontSize:11,fontWeight:FontWeight.w700))
      ]),
      const SizedBox(height:10),LinearProgressIndicator(value:progress,minHeight:6,borderRadius:BorderRadius.circular(20)),const SizedBox(height:10),
      OutlinedButton(onPressed:()=>_details(context,ref),child:const Text('جزئیات و تسویه'))
    ]));
  }
  Future<void> _details(BuildContext context,WidgetRef ref)async{
    await showModalBottomSheet<void>(context:context,isScrollControlled:true,useSafeArea:true,builder:(_)=>_Details(debt:debt));
    ref.invalidate(financeDebtsProvider);ref.invalidate(financeAccountsProvider);ref.invalidate(financeDashboardProvider);
  }
}
class _Details extends ConsumerWidget{
  const _Details({required this.debt});final FinanceDebt debt;
  @override Widget build(BuildContext context,WidgetRef ref){
    final payments=ref.watch(financeDebtPaymentsProvider(debt.id));
    return SizedBox(height:MediaQuery.sizeOf(context).height*.78,child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text(debt.title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800)),Text(debt.personName+' · '+debt.type.label,style:const TextStyle(color:NojinColors.text2)),const SizedBox(height:8),
      Text('مانده: '+IranMoney(debt.remainingAmount,currency:debt.currency).display,style:const TextStyle(fontWeight:FontWeight.w800)),
      if(debt.remainingAmount>0)Padding(padding:const EdgeInsets.only(top:12),child:FilledButton(onPressed:()=>_settle(context,ref),child:const Text('ثبت تسویه'))),
      const SizedBox(height:12),const Text('تاریخچه تسویه',style:TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:6),
      Expanded(child:payments.when(loading:()=>const Center(child:CircularProgressIndicator()),error:(e,_)=>Center(child:Text(e.toString())),data:(items)=>items.isEmpty?const Center(child:Text('هنوز تسویه‌ای ثبت نشده است.')):ListView.separated(itemCount:items.length,separatorBuilder:(_,__)=>const Divider(height:1),itemBuilder:(_,i)=>ListTile(contentPadding:EdgeInsets.zero,title:Text(IranMoney(items[i].amount,currency:debt.currency).display),subtitle:Text(IranDate.fromDateTime(items[i].paidAt).display))))),
    ])));
  }
  Future<void> _settle(BuildContext context,WidgetRef ref)async{
    final accounts=await ref.read(financeAccountsProvider.future);final matching=accounts.where((a)=>a.currency==debt.currency&&!a.isArchived).toList();
    if(!context.mounted)return;
    if(matching.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('حساب فعال با واحد پول مناسب پیدا نشد.')));return;}
    final d=await showModalBottomSheet<_Settle>(context:context,useSafeArea:true,isScrollControlled:true,builder:(_)=>_SettleForm(debt:debt,accounts:matching));
    if(d==null)return;
    try{final repo=await ref.read(financeRepositoryProvider.future);await repo.settleDebt(debtId:debt.id,accountId:d.accountId,amount:d.amount,note:d.note);ref.invalidate(financeDebtPaymentsProvider(debt.id));ref.invalidate(financeDebtsProvider);ref.invalidate(financeAccountsProvider);ref.invalidate(financeDashboardProvider);if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تسویه با موفقیت ثبت شد.')));}
    catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
  }
}
class _Form extends StatefulWidget{const _Form();@override State<_Form> createState()=>_FormState();}
class _FormState extends State<_Form>{
 final title=TextEditingController(),person=TextEditingController(),amount=TextEditingController(),note=TextEditingController();FinanceDebtType type=FinanceDebtType.receivable;IranCurrency currency=IranCurrency.toman;DateTime? dueAt;
 @override void dispose(){title.dispose();person.dispose();amount.dispose();note.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>SingleChildScrollView(padding:EdgeInsets.fromLTRB(20,14,20,24+MediaQuery.viewInsetsOf(context).bottom),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  const Text('ثبت بدهی یا طلب',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:14),
  SegmentedButton<FinanceDebtType>(segments:const[ButtonSegment(value:FinanceDebtType.receivable,label:Text('طلب از دیگران')),ButtonSegment(value:FinanceDebtType.payable,label:Text('بدهی به دیگران'))],selected:{type},onSelectionChanged:(v)=>setState(()=>type=v.first)),
  const SizedBox(height:10),TextField(controller:title,decoration:const InputDecoration(labelText:'عنوان')),const SizedBox(height:10),TextField(controller:person,decoration:const InputDecoration(labelText:'نام شخص / طرف حساب')),const SizedBox(height:10),
  DropdownButtonFormField<IranCurrency>(initialValue:currency,decoration:const InputDecoration(labelText:'واحد پول'),items:const[DropdownMenuItem(value:IranCurrency.toman,child:Text('تومان')),DropdownMenuItem(value:IranCurrency.rial,child:Text('ریال'))],onChanged:(v)=>setState(()=>currency=v??currency)),const SizedBox(height:10),
  TextField(controller:amount,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:'مبلغ کل ('+(currency==IranCurrency.toman?'تومان':'ریال')+')')),const SizedBox(height:10),
  OutlinedButton(onPressed:_pick,child:Align(alignment:Alignment.centerRight,child:Text(dueAt==null?'بدون سررسید':'سررسید: '+IranDate.fromDateTime(dueAt!).display))),const SizedBox(height:10),TextField(controller:note,maxLines:2,decoration:const InputDecoration(labelText:'یادداشت (اختیاری)')),const SizedBox(height:14),FilledButton(onPressed:_submit,child:const Text('ثبت'))
 ]);
 Future<void> _pick()async{final d=await showDatePicker(context:context,initialDate:dueAt??DateTime.now(),firstDate:DateTime(2020),lastDate:DateTime(2100),helpText:'انتخاب سررسید',cancelText:'لغو',confirmText:'انتخاب');if(d!=null)setState(()=>dueAt=d);}
 void _submit(){final a=int.tryParse(IranNumber.toEnglish(amount.text).replaceAll(RegExp(r'[^0-9]'),''))??0;if(title.text.trim().isEmpty||person.text.trim().isEmpty||a<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('عنوان، نام شخص و مبلغ را کامل کنید.')));return;}Navigator.pop(context,_Draft(title.text,person.text,type,a,currency,dueAt,note.text));}
}
class _Draft{const _Draft(this.title,this.person,this.type,this.amount,this.currency,this.dueAt,this.note);final String title,person,note;final FinanceDebtType type;final int amount;final IranCurrency currency;final DateTime? dueAt;}
class _SettleForm extends StatefulWidget{const _SettleForm({required this.debt,required this.accounts});final FinanceDebt debt;final List<FinanceAccount> accounts;@override State<_SettleForm> createState()=>_SettleFormState();}
class _SettleFormState extends State<_SettleForm>{final amount=TextEditingController(),note=TextEditingController();String? accountId;@override void dispose(){amount.dispose();note.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>Padding(padding:EdgeInsets.fromLTRB(20,14,20,24+MediaQuery.viewInsetsOf(context).bottom),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Text('ثبت تسویه',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:10),Text('مانده: '+IranMoney(widget.debt.remainingAmount,currency:widget.debt.currency).display),const SizedBox(height:10),TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'مبلغ تسویه')),const SizedBox(height:10),DropdownButtonFormField<String>(initialValue:accountId,decoration:const InputDecoration(labelText:'حساب مالی'),items:widget.accounts.map((a)=>DropdownMenuItem(value:a.id,child:Text(a.name))).toList(),onChanged:(v)=>setState(()=>accountId=v)),const SizedBox(height:10),TextField(controller:note,decoration:const InputDecoration(labelText:'یادداشت (اختیاری)')),const SizedBox(height:14),FilledButton(onPressed:_submit,child:const Text('ثبت تسویه'))]));
 void _submit(){final a=int.tryParse(IranNumber.toEnglish(amount.text).replaceAll(RegExp(r'[^0-9]'),''))??0;if(a<=0||accountId==null||a>widget.debt.remainingAmount){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('مبلغ یا حساب تسویه معتبر نیست.')));return;}Navigator.pop(context,_Settle(a,accountId!,note.text));}}
class _Settle{const _Settle(this.amount,this.accountId,this.note);final int amount;final String accountId,note;}
class _Empty extends StatelessWidget{const _Empty();@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(24),decoration:BoxDecoration(color:NojinColors.surface,borderRadius:BorderRadius.circular(NojinRadii.lg),border:Border.all(color:NojinColors.border)),child:const Column(children:[Text('هنوز بدهی یا طلبی ثبت نشده است.',style:TextStyle(fontWeight:FontWeight.w700)),SizedBox(height:6),Text('طلب‌ها و بدهی‌های شخصی را با مبلغ، طرف حساب و سررسید مدیریت کنید.',textAlign:TextAlign.center,style:TextStyle(color:NojinColors.text2,fontSize:12))]));}
