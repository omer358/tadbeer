import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/data.dart';
import '../../widgets/components.dart';
import '../../widgets/insight_banner.dart';
// import '../../widgets/charts.dart';
import '../../features/dashboard/bloc/dashboard_bloc.dart';
import '../../features/settings/bloc/settings_bloc.dart';
import '../../features/expenses/bloc/expenses_bloc.dart';
import '../../features/goals/bloc/goals_bloc.dart';
import '../../features/transactions/add_expense_dialog.dart';
import '../../features/goals/add_goal_dialog.dart';
import '../../features/common/statement_upload_dialog.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/goal.dart';
import 'package:uuid/uuid.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.select(
      (SettingsBloc b) => b.state.locale.languageCode,
    );

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = state.profile;
        final txns = state.recentTransactions;
        final goal = state.goal;
        final stateBudgets = state.budgets;

        // Calculations
        final income = profile.incomeAmount;
        final fixed = profile.totalFixed;

        double variableSpent = 0;
        double bnplSpent = 0;
        for (final t in txns) {
          if (t.direction != 'debit') continue;
          variableSpent += t.amount;
          if (t.isBnpl) bnplSpent += t.amount;
        }

        final safe = income - fixed - variableSpent;

        final saved = goal?.savedAmount ?? 0;
        final target = goal?.targetAmount ?? 1;
        final deadline = goal?.deadlineMonths ?? 12;
        final pct = (saved / (target == 0 ? 1 : target) * 100)
            .clamp(0, 100)
            .round();

        // AI Banner logic embedded or helper
        // ... (reuse logic or keep simple)

        return ListView(
          children: [
            // InsightBanner( ... ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: t(lang, 'income'),
                    value: fmtSAR(income),
                    sub: '${t(lang, 'fixed')}: ${fmtSAR(fixed)}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: t(lang, 'spent'),
                    value: fmtSAR(variableSpent),
                    sub: '${t(lang, 'bnpl')}: ${fmtSAR(bnplSpent)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: t(lang, 'safeToSpend'),
                    value: fmtSAR(safe),
                    sub: safe < 0
                        ? (lang == 'ar' ? 'تجاوزت الحد' : 'Over budget')
                        : (lang == 'ar' ? 'ضمن الحدود' : 'Within limits'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            t(lang, 'importStatement'),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.tonal(
                            onPressed: () => _openStatement(context, lang),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.upload_file_outlined,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(t(lang, 'upload')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Charts (Donut)
            // ...
            if (goal != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionTitle(
                        icon: const Icon(Icons.flag_outlined, size: 18),
                        title: t(lang, 'goals'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  goal.name,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lang == 'ar'
                                      ? 'الهدف: ${fmtSAR(target)} خلال $deadline شهر'
                                      : 'Target: ${fmtSAR(target)} in $deadline months',
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
                          SoftBadge('$pct%'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: (saved / (target == 0 ? 1 : target))
                            .clamp(0, 1)
                            .toDouble(),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: ListTile(
                  title: Text(t(lang, 'addGoal')),
                  trailing: const Icon(Icons.add),
                  onTap: () =>
                      _openAddGoal(context, lang, income, fixed, variableSpent),
                ),
              ),

            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionTitle(
                      icon: const Icon(Icons.receipt_long_outlined, size: 18),
                      title: t(lang, 'recent'),
                      right: TextButton.icon(
                        onPressed: () => _openAddExpense(context, lang),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(t(lang, 'addExpense')),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...txns.take(5).map((x) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    x.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
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
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        );
      },
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
      context.read<DashboardBloc>().add(LoadDashboard()); // Refresh dashboard
    }
  }

  Future<void> _openAddGoal(
    BuildContext context,
    String lang,
    double income,
    double fixed,
    double variable,
  ) async {
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddGoalDialog(
        lang: lang,
        income: income,
        fixed: fixed,
        variable: variable,
      ),
    );
    if (res != null) {
      final g = Goal(
        id: const Uuid().v4(),
        name: res['name'],
        type: res['type'],
        targetAmount: (res['target'] as int).toDouble(),
        savedAmount: 0,
        deadlineMonths: res['deadlineMonths'],
      );
      context.read<GoalsBloc>().add(AddGoal(g));
      context.read<DashboardBloc>().add(LoadDashboard());
    }
  }

  Future<void> _openStatement(BuildContext context, String lang) async {
    await showDialog(
      context: context,
      builder: (_) => StatementUploadDialog(lang: lang),
    );
  }
}
