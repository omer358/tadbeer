import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/data.dart';
import '../../widgets/components.dart';
import '../expenses/bloc/expenses_bloc.dart';
import '../settings/bloc/settings_bloc.dart';
import '../transactions/add_expense_dialog.dart';
import '../common/statement_upload_dialog.dart';
import '../../domain/entities/transaction.dart';

class ExpensesTab extends StatefulWidget {
  const ExpensesTab({super.key});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final lang = context.select(
      (SettingsBloc b) => b.state.locale.languageCode,
    );

    return BlocBuilder<ExpensesBloc, ExpensesState>(
      builder: (context, state) {
        if (state.loading && state.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = state.transactions.where((x) {
          if (filter == 'all') return true;
          if (filter == 'bnpl') return x.category == 'bnpl';
          return x.category == filter;
        }).toList();

        return ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t(lang, 'expenses'),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () => _openStatement(context, lang),
                          child: Row(
                            children: [
                              const Icon(Icons.upload_file_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(t(lang, 'importStatement')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => _openAddExpense(context, lang),
                          child: Row(
                            children: [
                              const Icon(Icons.add, size: 18),
                              const SizedBox(width: 6),
                              Text(t(lang, 'addExpense')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(lang == 'ar' ? 'الكل' : 'All', 'all'),
                        ...categories
                            .where((c) => c.key != 'other')
                            .map(
                              (c) => _chip(lang == 'ar' ? c.ar : c.en, c.key),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...filtered.take(12).map((x) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  x.description,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${catLabel(lang, x.category)} • ${x.date.toString().substring(0, 10)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            fmtSAR(x.amount),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      if (x.isBnpl) ...[
                        const SizedBox(height: 10),
                        SoftBadge(
                          lang == 'ar' ? 'تم اكتشاف تقسيط' : 'BNPL detected',
                          bg: Colors.amber.withOpacity(0.18),
                          fg: Colors.amber.shade900,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _chip(String label, String value) {
    final selected = filter == value;
    return InkWell(
      onTap: () => setState(() => filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _openAddExpense(BuildContext context, String lang) async {
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddExpenseDialog(lang: lang),
    );
    if (res != null) {
      final txn = TransactionEntity(
        id: const Uuid().v4(),
        amount: (res['amount'] as int?)?.toDouble() ?? 0.0,
        description: res['description'] ?? '',
        category: res['category'] ?? 'other',
        date: DateTime.parse(res['date'] ?? todayISO()),
        isBnpl: res['bnpl'] == true,
      );
      context.read<ExpensesBloc>().add(AddExpense(txn));
    }
  }

  Future<void> _openStatement(BuildContext context, String lang) async {
    await showDialog(
      context: context,
      builder: (_) => StatementUploadDialog(lang: lang),
    );
  }
}
