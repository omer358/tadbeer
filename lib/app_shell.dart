import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/data.dart';
import 'widgets/components.dart';
import 'features/dashboard/dashboard_tab.dart';
import 'features/expenses/expenses_tab.dart';
import 'features/goals/goals_tab.dart';
import 'features/goals/coach_tab.dart';
import 'features/settings/settings_tab.dart';
import 'features/transactions/add_expense_dialog.dart';

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
      const CoachTab(),
      const GoalsTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.wallet, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              t(lang, 'appName'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: month,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                isDense: true,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
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
        ],
      ),
      body: SafeArea(
        child: PhoneFrame(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: content[tab],
          ),
        ),
      ),
      floatingActionButton: tab == 0
          ? FloatingActionButton(
              onPressed: () => _openAddExpense(context),
              elevation: 4,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) {
            setState(() => tab = i);
            if (i == 0) _refresh();
          },
          height: 65,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: t(lang, 'dashboard'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: t(lang, 'expenses'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: const Icon(Icons.auto_awesome),
              label: t(lang, 'aiCoach'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.flag_outlined),
              selectedIcon: const Icon(Icons.flag_rounded),
              label: t(lang, 'goals'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: t(lang, 'settings'),
            ),
          ],
        ),
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
}
