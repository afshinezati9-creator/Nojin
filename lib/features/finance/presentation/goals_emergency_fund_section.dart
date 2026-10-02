import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/iran/iran_date.dart';
import '../../../core/iran/iran_money.dart';
import '../../../core/iran/iran_number.dart';
import '../../../core/theme/nojin_tokens.dart';
import '../application/finance_state.dart';
import '../domain/finance_models.dart';

class GoalsEmergencyFundSection extends ConsumerWidget {
  const GoalsEmergencyFundSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeGoalsProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        const Expanded(child: Text('اهداف مالی و صندوق اضطراری', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
        OutlinedButton(onPressed: () => _create(context, ref), child: const Text('هدف جدید')),
      ]),
      const SizedBox(height: 6),
      const Text('پیشرفت پس‌انداز را مستقل از تراکنش‌های حساب‌های بانکی دنبال کنید.', style: TextStyle(color: NojinColors.text3, fontSize: 11)),
      const SizedBox(height: 12),
      state.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Column(children: [
          Text(e.toString(), textAlign: TextAlign.center),
          OutlinedButton(onPressed: () => ref.invalidate(financeGoalsProvider), child: const Text('تلاش دوباره')),
        ]),
        data: (items) => items.isEmpty
            ? const _GoalEmpty()
            : Column(children: items.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GoalCard(goal: g),
              )).toList()),
      ),
    ]);
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final draft = await showModalBottomSheet<_GoalDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _GoalForm(),
    );
    if (draft == null) return;
    try {
      final repo = await ref.read(financeRepositoryProvider.future);
      await repo.createGoal(
        title: draft.title,
        type: draft.type,
        targetAmount: draft.targetAmount,
        currency: draft.currency,
        dueAt: draft.dueAt,
        note: draft.note,
      );
      ref.invalidate(financeGoalsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});
  final FinanceGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = goal.statusAt(DateTime.now().toUtc());
    final color = switch (status) {
      FinanceGoalStatus.completed => NojinColors.success,
      FinanceGoalStatus.overdue => NojinColors.danger,
      FinanceGoalStatus.active => NojinColors.indigo,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NojinColors.surface,
        borderRadius: BorderRadius.circular(NojinRadii.lg),
        border: Border.all(color: NojinColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: const BoxDecoration(gradient: NojinGradients.soft, shape: BoxShape.circle),
            child: Icon(
              goal.type == FinanceGoalType.emergencyFund ? Icons.shield_outlined : Icons.flag_outlined,
              size: 20,
              color: NojinColors.indigo,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(goal.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(goal.type.label, style: const TextStyle(color: NojinColors.text3, fontSize: 11)),
          ])),
          Text(status.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Text(IranMoney(goal.currentAmount, currency: goal.currency).display, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
          Text('از ' + IranMoney(goal.targetAmount, currency: goal.currency).display, style: const TextStyle(color: NojinColors.text2, fontSize: 11)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: goal.progress, minHeight: 8, backgroundColor: NojinColors.border),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: Text(IranNumber.format((goal.progress * 100).round()) + '٪ پیشرفت', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
          if (goal.remainingAmount > 0)
            Text('مانده: ' + IranMoney(goal.remainingAmount, currency: goal.currency).display, style: const TextStyle(color: NojinColors.text3, fontSize: 11)),
          if (goal.dueAt != null)
            Text('  ·  ' + IranDate.fromDateTime(goal.dueAt!).display, style: const TextStyle(color: NojinColors.text3, fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: () => _details(context, ref), child: const Text('جزئیات و ثبت پس‌انداز')),
      ]),
    );
  }

  Future<void> _details(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _GoalDetails(goal: goal),
    );
    ref.invalidate(financeGoalsProvider);
  }
}

class _GoalDetails extends ConsumerWidget {
  const _GoalDetails({required this.goal});
  final FinanceGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(financeGoalEntriesProvider(goal.id));
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .78,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(goal.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(goal.type.label, style: const TextStyle(color: NojinColors.text2)),
          const SizedBox(height: 10),
          Text(
            IranMoney(goal.currentAmount, currency: goal.currency).display,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: NojinColors.indigo),
          ),
          Text('از هدف ' + IranMoney(goal.targetAmount, currency: goal.currency).display, style: const TextStyle(color: NojinColors.text3, fontSize: 11)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: goal.progress, minHeight: 7, borderRadius: BorderRadius.circular(20)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: FilledButton.icon(
              onPressed: () => _entry(context, ref, false),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('افزایش پس‌انداز'),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: goal.currentAmount == 0 ? null : () => _entry(context, ref, true),
              icon: const Icon(Icons.remove, size: 18),
              label: const Text('برداشت'),
            )),
          ]),
          const SizedBox(height: 14),
          const Text('تاریخچه', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Expanded(
            child: entries.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('هنوز پس‌اندازی برای این هدف ثبت نشده است.'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            item.isWithdrawal ? Icons.remove_circle_outline : Icons.add_circle_outline,
                            color: item.isWithdrawal ? NojinColors.danger : NojinColors.success,
                          ),
                          title: Text(
                            (item.isWithdrawal ? '− ' : '+ ') +
                                IranMoney(item.amount, currency: goal.currency).display,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(IranDate.fromDateTime(item.occurredAt).display),
                        );
                      },
                    ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _entry(BuildContext context, WidgetRef ref, bool withdrawal) async {
    final draft = await showModalBottomSheet<_EntryDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _GoalEntryForm(goal: goal, withdrawal: withdrawal),
    );
    if (draft == null) return;
    try {
      final repo = await ref.read(financeRepositoryProvider.future);
      await repo.addGoalEntry(
        goalId: goal.id,
        amount: draft.amount,
        isWithdrawal: withdrawal,
        note: draft.note,
      );
      ref.invalidate(financeGoalEntriesProvider(goal.id));
      ref.invalidate(financeGoalsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

class _GoalForm extends StatefulWidget {
  const _GoalForm();
  @override State<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<_GoalForm> {
  final title = TextEditingController();
  final amount = TextEditingController();
  final note = TextEditingController();
  FinanceGoalType type = FinanceGoalType.goal;
  IranCurrency currency = IranCurrency.toman;
  DateTime? dueAt;

  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('هدف مالی جدید', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      SegmentedButton<FinanceGoalType>(
        segments: const [
          ButtonSegment(value: FinanceGoalType.goal, label: Text('هدف مالی')),
          ButtonSegment(value: FinanceGoalType.emergencyFund, label: Text('صندوق اضطراری')),
        ],
        selected: {type},
        onSelectionChanged: (value) => setState(() => type = value.first),
      ),
      const SizedBox(height: 10),
      TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان')),
      const SizedBox(height: 10),
      DropdownButtonFormField<IranCurrency>(
        initialValue: currency,
        decoration: const InputDecoration(labelText: 'واحد پول'),
        items: const [
          DropdownMenuItem(value: IranCurrency.toman, child: Text('تومان')),
          DropdownMenuItem(value: IranCurrency.rial, child: Text('ریال')),
        ],
        onChanged: (value) => setState(() => currency = value ?? currency),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: amount,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'مبلغ هدف (' + (currency == IranCurrency.toman ? 'تومان' : 'ریال') + ')'),
      ),
      const SizedBox(height: 10),
      OutlinedButton(
        onPressed: _pickDate,
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(dueAt == null ? 'بدون مهلت' : 'مهلت: ' + IranDate.fromDateTime(dueAt!).display),
        ),
      ),
      const SizedBox(height: 10),
      TextField(controller: note, maxLines: 2, decoration: const InputDecoration(labelText: 'یادداشت (اختیاری)')),
      const SizedBox(height: 14),
      FilledButton(onPressed: _submit, child: const Text('ایجاد هدف')),
    ]),
  );

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: dueAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'انتخاب مهلت هدف',
      cancelText: 'لغو',
      confirmText: 'انتخاب',
    );
    if (date != null) setState(() => dueAt = date);
  }

  void _submit() {
    final value = int.tryParse(IranNumber.toEnglish(amount.text).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (title.text.trim().isEmpty || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عنوان و مبلغ هدف را کامل کنید.')));
      return;
    }
    Navigator.pop(context, _GoalDraft(title.text, type, value, currency, dueAt, note.text));
  }
}

class _GoalDraft {
  const _GoalDraft(this.title, this.type, this.targetAmount, this.currency, this.dueAt, this.note);
  final String title;
  final FinanceGoalType type;
  final int targetAmount;
  final IranCurrency currency;
  final DateTime? dueAt;
  final String note;
}

class _GoalEntryForm extends StatefulWidget {
  const _GoalEntryForm({required this.goal, required this.withdrawal});
  final FinanceGoal goal;
  final bool withdrawal;
  @override State<_GoalEntryForm> createState() => _GoalEntryFormState();
}

class _GoalEntryFormState extends State<_GoalEntryForm> {
  final amount = TextEditingController();
  final note = TextEditingController();

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(widget.withdrawal ? 'برداشت از هدف' : 'افزایش پس‌انداز', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Text('موجودی فعلی: ' + IranMoney(widget.goal.currentAmount, currency: widget.goal.currency).display),
      const SizedBox(height: 10),
      TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مبلغ')),
      const SizedBox(height: 10),
      TextField(controller: note, decoration: const InputDecoration(labelText: 'یادداشت (اختیاری)')),
      const SizedBox(height: 14),
      FilledButton(onPressed: _submit, child: const Text('ثبت')),
    ]),
  );

  void _submit() {
    final value = int.tryParse(IranNumber.toEnglish(amount.text).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (value <= 0 || (widget.withdrawal && value > widget.goal.currentAmount)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ واردشده معتبر نیست.')));
      return;
    }
    Navigator.pop(context, _EntryDraft(value, note.text));
  }
}

class _EntryDraft {
  const _EntryDraft(this.amount, this.note);
  final int amount;
  final String note;
}

class _GoalEmpty extends StatelessWidget {
  const _GoalEmpty();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: NojinColors.surface,
      borderRadius: BorderRadius.circular(NojinRadii.lg),
      border: Border.all(color: NojinColors.border),
    ),
    child: const Column(children: [
      Icon(Icons.flag_outlined, size: 40, color: NojinColors.indigo),
      SizedBox(height: 10),
      Text('هنوز هدف مالی ثبت نشده است.', style: TextStyle(fontWeight: FontWeight.w700)),
      SizedBox(height: 6),
      Text('برای خرید، پس‌انداز یا صندوق اضطراری یک هدف مشخص تعریف کنید.', textAlign: TextAlign.center, style: TextStyle(color: NojinColors.text2, fontSize: 12)),
    ]),
  );
}
