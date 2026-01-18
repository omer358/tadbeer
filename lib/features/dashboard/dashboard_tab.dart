import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/data.dart';
import '../../widgets/components.dart';
import '../../widgets/insight_banner.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        final income = state.income;
        final fixed = profile.totalFixed;
        final variableSpent = state.expenses;
        final safe = state.balance;

        double bnplSpent = 0;
        for (final t in txns) {
          if (t.isBnpl) bnplSpent += t.amount;
        }

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

            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatCard(
                      label: t(lang, 'income'),
                      value: fmtSAR(income),
                      sub: '${t(lang, 'fixed')}: ${fmtSAR(fixed)}',
                      imagePath: 'assets/incom.png',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: t(lang, 'spent'),
                      value: fmtSAR(variableSpent),
                      sub: '${t(lang, 'bnpl')}: ${fmtSAR(bnplSpent)}',
                      imagePath: 'assets/total_spending.png',
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 10),
            IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: StatCard(
                          label: t(lang, 'safeToSpend'),
                          value: fmtSAR(safe),
                          sub: safe < 0
                              ? (lang == 'ar' ? 'تجاوزت الحد' : 'Over budget')
                              : (lang == 'ar' ? 'ضمن الحدود' : 'Within limits'),
                          imagePath: 'assets/remain_balance.png',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant.withOpacity(0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Image.asset(
                                      'assets/bank_statement.png',
                                      height: 28,
                                      width: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    t(lang, 'bankStatement'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              FilledButton.tonal(
                                onPressed: () => _openStatement(context, lang),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  minimumSize: const Size(0, 36),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(t(lang, 'importStatement')),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fade(delay: 100.ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            if (goal != null)
              Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionTitle(
                            icon: const Icon(Icons.flag_rounded, size: 18),
                            title: t(lang, 'goals'),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      goal.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lang == 'ar'
                                          ? 'الهدف: ${fmtSAR(target)} خلال $deadline شهر'
                                          : 'Target: ${fmtSAR(target)} in $deadline months',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
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
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fade(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.1, end: 0)
            else
              Card(
                    child: ListTile(
                      title: Text(t(lang, 'addGoal')),
                      trailing: const Icon(Icons.add),
                      onTap: () => _openAddGoal(
                        context,
                        lang,
                        income,
                        fixed,
                        variableSpent,
                      ),
                    ),
                  )
                  .animate()
                  .fade(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.1, end: 0),

            if (state.dashboardSuggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionTitle(
                        icon: const Icon(Icons.lightbulb_outline, size: 18),
                        title: lang == 'ar' ? 'اقتراحات' : 'Suggestions',
                      ),
                      const SizedBox(height: 10),
                      ...state.dashboardSuggestions.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InsightBanner(
                            lang: lang,
                            severity: s.type == 'WARNING' ? 'warning' : 'info',
                            title: s.title,
                            message: s.description,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade().slideY(),
            ],

            const SizedBox(height: 12),
            Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionTitle(
                          icon: const Icon(
                            Icons.receipt_long_rounded,
                            size: 18,
                          ),
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
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.sell_outlined,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        x.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${catLabel(lang, x.category)} • ${x.date.toString().substring(0, 10)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                              fontSize: 11,
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
                          ).animate().fade().slideX();
                        }),
                      ],
                    ),
                  ),
                )
                .animate()
                .fade(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0),

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
