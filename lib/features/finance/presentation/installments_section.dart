import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/icons/nojin_icons.dart';
import '../../../core/iran/iran_date.dart';
import '../../../core/iran/iran_money.dart';
import '../../../core/iran/iran_number.dart';
import '../../../core/layout/nojin_breakpoints.dart';
import '../../../core/theme/nojin_tokens.dart';
import '../application/finance_state.dart';
import '../domain/finance_models.dart';

class InstallmentsSection extends ConsumerWidget {
  const InstallmentsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeInstallmentPlansProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('اقساط', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            OutlinedButton.icon(
              onPressed: () => _create(context, ref),
              icon: const NojinIcon(NojinIconName.add, size: 17),
              label: const Text('قسط جدید'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        state.when(
          loading: () => const _InstallmentLoading(),
          error: (error, _) => _InstallmentError(
            message: error.toString(),
            onRetry: () => ref.invalidate(financeInstallmentPlansProvider),
          ),
          data: (plans) => plans.isEmpty
              ? const _InstallmentEmpty()
              : Column(
                  children: plans.map((plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PlanCard(plan: plan),
                  )).toList(),
                ),
        ),
      ],
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final draft = await showModalBottomSheet<_InstallmentDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _InstallmentForm(),
    );
    if (draft == null) return;
    try {
      final repo = await ref.read(financeRepositoryProvider.future);
      await repo.createInstallmentPlan(
        title: draft.title,
        totalAmount: draft.totalAmount,
        installmentCount: draft.installmentCount,
        currency: draft.currency,
        firstDueAt: draft.firstDueAt,
        intervalMonths: draft.intervalMonths,
        note: draft.note,
      );
      ref.invalidate(financeInstallmentPlansProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan});
  final FinanceInstallmentPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeInstallmentsProvider(plan.id));
    return InkWell(
      borderRadius: BorderRadius.circular(NojinRadii.lg),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _PlanDetails(plan: plan),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NojinColors.surface,
          borderRadius: BorderRadius.circular(NojinRadii.lg),
          border: Border.all(color: NojinColors.border),
        ),
        child: state.when(
          loading: () => const SizedBox(height: 58, child: Center(child: LinearProgressIndicator())),
          error: (error, _) => Text(error.toString()),
          data: (items) {
            final paid = items.where((item) => item.paidAt != null).length;
            final overdue = items.where((item) => item.statusAt(DateTime.now().toUtc()) == InstallmentStatus.overdue).length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(plan.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    Text(IranMoney(plan.totalAmount, currency: plan.currency).display, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    Text('${IranNumber.format(paid)} از ${IranNumber.format(plan.installmentCount)} پرداخت شده', style: const TextStyle(fontSize: 11, color: NojinColors.text2)),
                    Text('هر قسط: ${IranMoney(plan.installmentAmount, currency: plan.currency).display}', style: const TextStyle(fontSize: 11, color: NojinColors.text2)),
                    Text('شروع: ${IranDate.fromDateTime(plan.firstDueAt).display}', style: const TextStyle(fontSize: 11, color: NojinColors.text2)),
                    if (overdue > 0)
                      Text('${IranNumber.format(overdue)} قسط معوق', style: const TextStyle(fontSize: 11, color: NojinColors.danger, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: plan.installmentCount == 0 ? 0 : paid / plan.installmentCount,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlanDetails extends ConsumerWidget {
  const _PlanDetails({required this.plan});
  final FinanceInstallmentPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeInstallmentsProvider(plan.id));
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .82,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(plan.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'کل: ${IranMoney(plan.totalAmount, currency: plan.currency).display} · ${IranNumber.format(plan.installmentCount)} قسط',
              style: const TextStyle(color: NojinColors.text2),
            ),
            if (plan.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(plan.note, style: const TextStyle(color: NojinColors.text2, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(error.toString())),
                data: (items) => ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final status = item.statusAt(DateTime.now().toUtc());
                    return _InstallmentRow(
                      plan: plan,
                      item: item,
                      status: status,
                      onPay: status == InstallmentStatus.paid ? null : () => _pay(context, ref, item),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay(BuildContext context, WidgetRef ref, FinanceInstallment item) async {
    final accounts = await ref.read(financeAccountsProvider.future);
    final matching = accounts.where((account) => account.currency == plan.currency && !account.isArchived).toList();
    if (!context.mounted) return;
    if (matching.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('برای پرداخت این قسط، حساب ${plan.currency == IranCurrency.toman ? 'تومانی' : 'ریالی'} فعال ندارید.')),
      );
      return;
    }
    final accountId = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (_) => _PaymentAccountPicker(amount: item.amount, currency: plan.currency, accounts: matching),
    );
    if (accountId == null) return;
    try {
      final repo = await ref.read(financeRepositoryProvider.future);
      await repo.payInstallment(installmentId: item.id, accountId: accountId);
      ref.invalidate(financeInstallmentsProvider(plan.id));
      ref.invalidate(financeInstallmentPlansProvider);
      ref.invalidate(financeAccountsProvider);
      ref.invalidate(financeDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قسط با موفقیت پرداخت شد.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _InstallmentRow extends StatelessWidget {
  const _InstallmentRow({required this.plan, required this.item, required this.status, required this.onPay});
  final FinanceInstallmentPlan plan;
  final FinanceInstallment item;
  final InstallmentStatus status;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      InstallmentStatus.paid => NojinColors.success,
      InstallmentStatus.overdue => NojinColors.danger,
      InstallmentStatus.pending => NojinColors.warning,
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('قسط ${IranNumber.format(item.sequence)}', style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        'سررسید ${IranDate.fromDateTime(item.dueAt).display} · ${status.label}',
        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
      ),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(IranMoney(item.amount, currency: plan.currency).display, style: const TextStyle(fontWeight: FontWeight.w800)),
          if (onPay != null) ...[
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onPay, child: const Text('پرداخت')),
          ],
        ],
      ),
    );
  }
}

class _PaymentAccountPicker extends StatelessWidget {
  const _PaymentAccountPicker({required this.amount, required this.currency, required this.accounts});
  final int amount;
  final IranCurrency currency;
  final List<FinanceAccount> accounts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('انتخاب حساب پرداخت', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('مبلغ: ${IranMoney(amount, currency: currency).display}', style: const TextStyle(color: NojinColors.text2)),
          const SizedBox(height: 12),
          ...accounts.map((account) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, account.id),
              child: Row(children: [
                Expanded(child: Text(account.name)),
                Text(IranMoney(account.balance, currency: account.currency).display, style: const TextStyle(fontSize: 11)),
              ]),
            ),
          )),
        ],
      ),
    );
  }
}

class _InstallmentForm extends StatefulWidget {
  const _InstallmentForm();
  @override State<_InstallmentForm> createState() => _InstallmentFormState();
}

class _InstallmentFormState extends State<_InstallmentForm> {
  final title = TextEditingController();
  final total = TextEditingController();
  final count = TextEditingController(text: '12');
  final interval = TextEditingController(text: '1');
  final note = TextEditingController();
  FinanceCurrencySelection currency = FinanceCurrencySelection.toman;
  DateTime firstDueAt = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    title.dispose();
    total.dispose();
    count.dispose();
    interval.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('قسط جدید', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان', hintText: 'مثلاً خرید لپ‌تاپ')),
          const SizedBox(height: 12),
          TextField(
            controller: total,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'مبلغ کل (${currency == FinanceCurrencySelection.toman ? 'تومان' : 'ریال'})'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<FinanceCurrencySelection>(
            initialValue: currency,
            decoration: const InputDecoration(labelText: 'واحد پول'),
            items: const [
              DropdownMenuItem(value: FinanceCurrencySelection.toman, child: Text('تومان')),
              DropdownMenuItem(value: FinanceCurrencySelection.rial, child: Text('ریال')),
            ],
            onChanged: (value) => setState(() => currency = value ?? currency),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: count, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد اقساط'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: interval, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'فاصله (ماه)'))),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _pickDate,
            child: Align(alignment: Alignment.centerRight, child: Text('اولین سررسید: ${IranDate.fromDateTime(firstDueAt).display}')),
          ),
          const SizedBox(height: 12),
          TextField(controller: note, maxLines: 2, decoration: const InputDecoration(labelText: 'یادداشت (اختیاری)')),
          const SizedBox(height: 16),
          FilledButton(onPressed: _submit, child: const Text('ساخت برنامه اقساط')),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: firstDueAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'انتخاب اولین سررسید',
      cancelText: 'لغو',
      confirmText: 'انتخاب',
    );
    if (picked != null) setState(() => firstDueAt = picked);
  }

  void _submit() {
    final totalAmount = int.tryParse(IranNumber.toEnglish(total.text).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final installmentCount = int.tryParse(IranNumber.toEnglish(count.text).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final intervalMonths = int.tryParse(IranNumber.toEnglish(interval.text).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (title.text.trim().isEmpty || totalAmount <= 0 || installmentCount <= 0 || intervalMonths <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عنوان، مبلغ، تعداد و فاصله اقساط را کامل کنید.')));
      return;
    }
    Navigator.pop(
      context,
      _InstallmentDraft(
        title: title.text,
        totalAmount: totalAmount,
        installmentCount: installmentCount,
        currency: currency == FinanceCurrencySelection.toman ? IranCurrency.toman : IranCurrency.rial,
        firstDueAt: firstDueAt,
        intervalMonths: intervalMonths,
        note: note.text,
      ),
    );
  }
}

enum FinanceCurrencySelection { toman, rial }

class _InstallmentDraft {
  const _InstallmentDraft({required this.title, required this.totalAmount, required this.installmentCount, required this.currency, required this.firstDueAt, required this.intervalMonths, required this.note});
  final String title;
  final int totalAmount;
  final int installmentCount;
  final IranCurrency currency;
  final DateTime firstDueAt;
  final int intervalMonths;
  final String note;
}

class _InstallmentEmpty extends StatelessWidget {
  const _InstallmentEmpty();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: NojinColors.surface, borderRadius: BorderRadius.circular(NojinRadii.lg), border: Border.all(color: NojinColors.border)),
    child: const Column(children: [
      Text('هنوز برنامه اقساطی ثبت نشده است.', style: TextStyle(fontWeight: FontWeight.w700)),
      SizedBox(height: 6),
      Text('برای هر خرید قسطی، مبلغ کل، تعداد و سررسیدها را ثبت کنید و پرداخت هر قسط را به حساب مالی متصل کنید.', textAlign: TextAlign.center, style: TextStyle(color: NojinColors.text2, fontSize: 12)),
    ]),
  );
}

class _InstallmentLoading extends StatelessWidget {
  const _InstallmentLoading();
  @override Widget build(BuildContext context) => const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: LinearProgressIndicator());
}

class _InstallmentError extends StatelessWidget {
  const _InstallmentError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: NojinColors.surface, borderRadius: BorderRadius.circular(NojinRadii.lg), border: Border.all(color: NojinColors.border)),
    child: Column(children: [
      const Text('بارگذاری اقساط انجام نشد', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      Text(message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: NojinColors.text3, fontSize: 11)),
      const SizedBox(height: 8),
      OutlinedButton(onPressed: onRetry, child: const Text('تلاش دوباره')),
    ]),
  );
}
