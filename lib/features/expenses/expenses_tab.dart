import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // Filter & Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionTitle(
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    title: t(lang, 'expenses'),
                    right: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => _openStatement(context, lang),
                          tooltip: t(lang, 'importStatement'),
                          icon: const Icon(Icons.upload_file_rounded, size: 20),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: () => _openAddExpense(context, lang),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text(t(lang, 'addExpense')),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _chip(lang == 'ar' ? 'الكل' : 'All', 'all'),
                        const SizedBox(width: 8),
                        ...categories
                            .where((c) => c.key != 'other')
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _chip(lang == 'ar' ? c.ar : c.en, c.key),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: -0.1, end: 0),

            const SizedBox(height: 16),

            if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang == 'ar' ? 'لا توجد مصروفات' : 'No expenses found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade()
            else
              ...filtered.map((x) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.sell_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  x.description,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      if (x.isBnpl) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SoftBadge(
                              lang == 'ar'
                                  ? 'تم اكتشاف تقسيط'
                                  : 'BNPL detected',
                              bg: Colors.amber.withOpacity(0.1),
                              fg: Colors.amber.shade900,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ).animate().fade().slideX();
              }),
          ],
        );
      },
    );
  }

  Widget _chip(String label, String value) {
    final selected = filter == value;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => setState(() => filter = value),
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: selected
              ? scheme.primary
              : scheme.surfaceContainerHighest.withOpacity(0.5),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
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
