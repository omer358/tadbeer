import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'core/data.dart';
import 'widgets/components.dart';
import 'features/dashboard/dashboard_tab.dart';
import 'features/expenses/expenses_tab.dart';
import 'features/goals/goals_tab.dart';
import 'features/settings/settings_tab.dart';
import 'features/transactions/add_expense_dialog.dart';
import 'features/goals/add_goal_dialog.dart';
import 'features/common/statement_upload_dialog.dart';
import 'features/goals/coach_dialog.dart';

class AppShell extends StatefulWidget {
  final String lang;
  final bool dark;
  final VoidCallback onToggleLang;
  final ValueChanged<bool> onToggleDark;
  final Map<String, dynamic> initial;

  const AppShell({
    super.key,
    required this.lang,
    required this.dark,
    required this.onToggleLang,
    required this.onToggleDark,
    required this.initial,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int tab = 0;
  String month = '2026-01';

  late Map<String, dynamic> profile;
  late Map<String, dynamic> budgets;
  late Map<String, dynamic> goal;
  late List<Map<String, dynamic>> txns;

  @override
  void initState() {
    super.initState();
    profile = Map<String, dynamic>.from(widget.initial['profile'] as Map);
    budgets = Map<String, dynamic>.from(widget.initial['budgets'] as Map);
    goal = Map<String, dynamic>.from(widget.initial['goal'] as Map);
    txns = List<Map<String, dynamic>>.from(widget.initial['txns'] as List);
  }

  String get lang => widget.lang;

  int fixedSum() {
    final rows = (profile['fixedRows'] as List).cast<Map>();
    int s = 0;
    for (final r in rows) {
      s += (r['amount'] as int?) ?? 0;
    }
    return s;
  }

  Map<String, num> totals() {
    final income = (profile['incomeAmount'] as num?) ?? 0;
    final fixed = fixedSum();

    num variableSpent = 0;
    num bnplSpent = 0;
    for (final t in txns) {
      if (t['direction'] != 'debit') continue;
      final amt = (t['amount'] as num?) ?? 0;
      variableSpent += amt;
      if (t['category'] == 'bnpl') bnplSpent += amt;
    }

    // "Safe to spend" = Income - Fixed - Variable
    // If variable includes BNPL, then BNPL is already subtracted.
    final safe = income - fixed - variableSpent;
    return {
      'income': income,
      'fixed': fixed,
      'variable': variableSpent,
      'bnpl': bnplSpent,
      'safe': safe,
    };
  }

  Map<String, num> byCategory() {
    final map = <String, num>{};
    for (final t in txns) {
      if (t['direction'] != 'debit') continue;
      final c = t['category'] as String;
      final a = (t['amount'] as num?) ?? 0;
      map[c] = (map[c] ?? 0) + a;
    }
    return map;
  }

  List<Map<String, dynamic>> donutData() {
    final c = byCategory();
    final list = c.entries
        .map((e) => {'key': e.key, 'value': e.value})
        .toList();
    list.sort((a, b) => (b['value'] as num).compareTo(a['value'] as num));
    return list;
  }

  List<Map<String, num>> burnRate() {
    // Mock burn rate data for chart
    return [
      {'day': 1, 'spent': 500, 'expected': 400},
      {'day': 7, 'spent': 2200, 'expected': 2800},
      {'day': 14, 'spent': 4100, 'expected': 5600},
      {'day': 21, 'spent': 7800, 'expected': 8400},
    ];
  }

  Map<String, dynamic> aiBanner() {
    // Simple rule-based logic to show an insight
    final t = totals();
    final safe = (t['safe'] as num?) ?? 0;
    final bnpl = (t['bnpl'] as num?) ?? 0;

    if (safe < 0) {
      return {
        'severity': 'warning',
        'title': lang == 'ar' ? 'تجاوزت الميزانية!' : 'Over budget!',
        'message': lang == 'ar'
            ? 'أنت تصرف أكثر من دخلك. توقف فوراً وشاور المدرب.'
            : 'Spending exceeds income. Stop now & check Coach.',
      };
    }
    if (bnpl > 1500) {
      return {
        'severity': 'warning',
        'title': lang == 'ar' ? 'تحذير تقسيط' : 'BNPL Alert',
        'message': lang == 'ar'
            ? 'التزاماتك الشهرية القادمة مرتفعة. خفف المصاريف.'
            : 'Future monthly commitments are high. Slow down.',
      };
    }
    return {
      'severity': 'success',
      'title': lang == 'ar' ? 'وضعك ممتاز' : 'On track',
      'message': lang == 'ar'
          ? 'استمر، خطتك ماشية تمام وتقدر توفر أكثر.'
          : 'Great job. You are saving well this month.',
    };
  }

  void addExpense(Map<String, dynamic> txn) {
    final id = 't_${math.Random().nextInt(999999)}';
    setState(() {
      txns.insert(0, {...txn, 'id': id});
    });
  }

  void addGoal(Map<String, dynamic> g) {
    setState(() {
      goal['type'] = g['type'];
      goal['name'] = g['name'];
      goal['target'] = g['target'];
      goal['deadlineMonths'] = g['deadlineMonths'];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Note: 'scheme' was unused in original build method except for passing to children via context.

    final content = [
      DashboardTab(
        lang: lang,
        totals: totals(),
        budgets: budgets,
        byCategory: byCategory(),
        donut: donutData(),
        burn: burnRate(),
        goal: goal,
        txns: txns,
        ai: aiBanner(),
        onAddExpense: () => _openAddExpense(context),
        onAddGoal: () => _openAddGoal(context),
        onImport: () =>
            _openCoach(context), // Dashboard Insight banner 'details' -> Coach
      ),
      ExpensesTab(
        lang: lang,
        txns: txns,
        onAddExpense: () => _openAddExpense(context),
        onImport: () => _openStatement(context),
      ),
      GoalsTab(
        lang: lang,
        goal: goal,
        totals: totals(),
        onAddGoal: () => _openAddGoal(context),
      ),
      SettingsTab(
        lang: lang,
        dark: widget.dark,
        onToggleDark: widget.onToggleDark,
        onToggleLang: widget.onToggleLang,
        onImport: () => _openStatement(context),
      ),
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
        onDestinationSelected: (i) => setState(() => tab = i),
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
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddExpenseDialog(lang: lang),
    );
    if (res != null) {
      addExpense(res);
    }
  }

  Future<void> _openAddGoal(BuildContext context) async {
    final totalsMap = totals();
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddGoalDialog(
        lang: lang,
        income: (totalsMap['income'] ?? 0).toDouble(),
        fixed: (totalsMap['fixed'] ?? 0).toDouble(),
        variable: (totalsMap['variable'] ?? 0).toDouble(),
      ),
    );
    if (res != null) {
      addGoal(res);
    }
  }

  Future<void> _openStatement(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => StatementUploadDialog(lang: lang),
    );
    // In a real app, we would process result
  }

  Future<void> _openCoach(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => CoachDialog(lang: lang, totals: totals(), goal: goal),
    );
  }
}
