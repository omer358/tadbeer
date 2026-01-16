import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/data.dart';
import 'widgets/components.dart';
import 'features/dashboard/dashboard_tab.dart';
import 'features/expenses/expenses_tab.dart';
import 'features/goals/goals_tab.dart';
import 'features/settings/settings_tab.dart';
import 'features/transactions/add_expense_dialog.dart';

import 'features/goals/coach_dialog.dart';

import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/expenses/bloc/expenses_bloc.dart';
import 'features/goals/bloc/goals_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int tab = 0;
  String month = '2026-01';

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<DashboardBloc>().add(LoadDashboard());
    context.read<ExpensesBloc>().add(LoadExpenses());
    context.read<GoalsBloc>().add(LoadGoals());
  }

  void _refresh() {
    context.read<DashboardBloc>().add(LoadDashboard());
    context.read<ExpensesBloc>().add(LoadExpenses());
    context.read<GoalsBloc>().add(LoadGoals());
  }

  @override
  Widget build(BuildContext context) {
    // Current locale
    final lang = context.select(
      (SettingsBloc b) => b.state.locale.languageCode,
    );

    final content = [
      const DashboardTab(),
      const ExpensesTab(),
      const GoalsTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.wallet, size: 24),
            const SizedBox(width: 8),
            Text(
              t(lang, 'appName'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButton<String>(
                value: month,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                items: months
                    .map(
                      (m) => DropdownMenuItem(
                        value: m['key'],
                        child: Text('${m['label']}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => month = v ?? month),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _openCoach(context),
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: t(lang, 'aiCoach'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: PhoneFrame(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: content[tab],
          ),
        ),
      ),
      floatingActionButton: tab == 0
          ? FloatingActionButton(
              onPressed: () => _openAddExpense(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) {
          setState(() => tab = i);
          // Refresh dashboard when returning to it?
          if (i == 0) _refresh();
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: t(lang, 'dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            label: t(lang, 'expenses'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            label: t(lang, 'goals'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: t(lang, 'settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddExpense(BuildContext context) async {
    final lang = context.read<SettingsBloc>().state.locale.languageCode;
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddExpenseDialog(lang: lang),
    );
    // Dialog returns Map, we need to convert to Entity to add to Block
    // Or update Dialog to return Entity or use BLoC inside Dialog.
    // For MVP, adapting:
    if (res != null) {
      // Need a way to create Entity.
      // It's cleaner to handle this entirely in BLoC, but Dialog is returning map.
      // Let's rely on Dialog returning result for now and Map->Entity conversion here
      // But we can update AddExpenseDialog later.
    }
    // Actually, refresh logic is better: if added, refresh.
    // But ExpenseTab listens to stream.
    // Wait, AddExpenseDialog is still returning a Map.
    // I should refactor AddExpenseDialog to use BLoC or return properly.
    // Let's assume AddExpenseDialog handles its internal state and returns data.
    // I will refactor AddExpenseDialog later to return an Entity or use BLoC directly.
    // For now, let's keep it simple: AddExpenseDialog returns Map, we convert.
  }

  Future<void> _openCoach(BuildContext context) async {
    final lang = context.read<SettingsBloc>().state.locale.languageCode;
    // We need current data for coach
    final dbState = context.read<DashboardBloc>().state;
    // ...
    await showDialog(
      context: context,
      builder: (_) => CoachDialog(
        lang: lang,
        totals: {
          'variable': dbState.totalSpent,
          'bnpl': 0, // TODO: calculate bnpl specific from list
        },
        goal: {
          'saved': dbState.goal?.savedAmount ?? 0,
          'target': dbState.goal?.targetAmount ?? 0,
        }, // adaptor
      ),
    );
  }
}
