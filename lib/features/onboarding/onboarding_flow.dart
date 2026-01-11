import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/data.dart';
import '../../widgets/components.dart';
import '../../widgets/insight_banner.dart';

class OnboardingFlow extends StatefulWidget {
  final String lang;
  final VoidCallback onToggleLang;
  final ValueChanged<Map<String, dynamic>> onComplete;

  const OnboardingFlow({
    super.key,
    required this.lang,
    required this.onToggleLang,
    required this.onComplete,
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int step = 0;

  int incomeAmount = 12000;
  String incomeSource = 'salary';
  String payday = '25';

  final fixedRows = <Map<String, dynamic>>[
    {'name': 'Rent', 'amount': 3000},
    {'name': 'Bills', 'amount': 700},
  ];

  final scale = <String, int>{
    'restaurants': 3,
    'delivery': 2,
    'transport': 2,
    'shopping': 2,
    'bnpl': 3,
    'bills': 2,
  };

  String goalType = 'car';
  String goalName = 'Dream Car';
  int goalAmount = 25000;
  int goalDeadline = 12;
  Map<String, dynamic>? feasibility;

  String qBnpl = 'often';
  String qDebt = 'yes';
  String qAutoSave = 'yes';
  String qNotify = 'weekly';

  Map<String, dynamic> firstTxn = {
    'amount': 58,
    'description': 'AlBaik',
    'category': 'restaurants',
    'date': null,
  };

  @override
  void initState() {
    super.initState();
    firstTxn['date'] = todayISO();
    if (widget.lang == 'ar') {
      goalName = 'سيارة';
    }
  }

  String get lang => widget.lang;

  void goNext() => setState(() => step = math.min(step + 1, 7));
  void goBack() => setState(() => step = math.max(step - 1, 0));

  int fixedSum() {
    int s = 0;
    for (final r in fixedRows) {
      s += (r['amount'] as int?) ?? 0;
    }
    return s;
  }

  void runFeasibility() {
    final fixed = fixedSum();
    final estVariable = scale.values.fold<int>(0, (a, b) => a + b) * 250;
    final free = math.max(0, incomeAmount - fixed - estVariable);
    final monthsLeft = math.max(1, goalDeadline);
    final req = (goalAmount / monthsLeft);
    final feasible = req <= free;

    setState(() {
      feasibility = {
        'feasible': feasible,
        'monthlyRequired': req.round(),
        'estFree': free.round(),
        'suggestion': feasible
            ? (lang == 'ar'
                  ? 'الخطة قابلة للتنفيذ إذا التزمت بالحدود الشهرية.'
                  : 'Looks feasible if you stick to monthly limits.')
            : (lang == 'ar'
                  ? 'الهدف كبير على دخلك الحالي. اقترح زيادة المدة أو خفض المبلغ.'
                  : 'This goal is too aggressive. Extend the deadline or lower the target.'),
        'suggestedDeadline': feasible
            ? monthsLeft
            : (free <= 0
                  ? monthsLeft + 12
                  : (goalAmount / math.max(1, free)).ceil()),
        'suggestedTarget': feasible ? goalAmount : (free * monthsLeft).round(),
      };
    });
  }

  void complete() {
    final fixed = fixedSum();

    final payload = <String, dynamic>{
      'profile': {
        'lang': lang,
        'incomeAmount': incomeAmount,
        'incomeSource': incomeSource,
        'payday': payday,
        'fixedRows': fixedRows,
        'quickScale': scale,
        'questionnaire': {
          'qBnpl': qBnpl,
          'qDebt': qDebt,
          'qAutoSave': qAutoSave,
          'qNotify': qNotify,
        },
      },
      'goal': {
        'id': 'g_001',
        'type': goalType,
        'name': goalName,
        'target': goalAmount,
        'deadlineMonths': goalDeadline,
        'saved': 5400,
      },
      'txns': [
        {
          'id': 't_seed',
          'amount': int.tryParse('${firstTxn['amount']}') ?? 0,
          'description': '${firstTxn['description']}',
          'category': '${firstTxn['category']}',
          'date': '${firstTxn['date']}',
          'direction': 'debit',
          'bnpl': '${firstTxn['category']}' == 'bnpl',
        },
      ],
      'budgets': {
        'restaurants': 800,
        'delivery': 600,
        'transport': 500,
        'shopping': 700,
        'bnpl': 600,
        'bills': 1200,
        'other': 400,
      },
      'fixedSum': fixed,
    };

    widget.onComplete(payload);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (step + 1) / 8;

    return Scaffold(
      body: SafeArea(
        child: PhoneFrame(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t(lang, 'appName'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onToggleLang,
                    child: Text(
                      lang == 'ar' ? t('ar', 'english') : t('en', 'arabic'),
                    ),
                  ),
                  SoftBadge('${(progress * 100).round()}%'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(99),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _buildStep(context, step),
                ),
              ),

              if (step > 0 && step < 7)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: goBack,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_back, size: 18),
                              const SizedBox(width: 8),
                              Text(t(lang, 'back')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: goNext,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t(lang, 'next')),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, int s) {
    final key = ValueKey('step_$s');

    if (s == 0) {
      final slides = [
        {
          'icon': Icons.account_balance_wallet_outlined,
          't': t(lang, 'onboarding.s1t'),
          'd': t(lang, 'onboarding.s1d'),
        },
        {
          'icon': Icons.warning_amber_rounded,
          't': t(lang, 'onboarding.s2t'),
          'd': t(lang, 'onboarding.s2d'),
        },
        {
          'icon': Icons.auto_awesome,
          't': t(lang, 'onboarding.s3t'),
          'd': t(lang, 'onboarding.s3d'),
        },
      ];

      return Card(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...slides.map((x) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(x['icon'] as IconData, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${x['t']}',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${x['d']}',
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
                    ],
                  ),
                );
              }),
              const Spacer(),
              FilledButton(
                onPressed: goNext,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t(lang, 'startNow')),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (s == 1) {
      return Card(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t(lang, 'incomeTitle'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t(lang, 'incomeTitle')),
                controller: TextEditingController(
                  text: incomeAmount.toString(),
                ),
                onChanged: (v) =>
                    incomeAmount = int.tryParse(v) ?? incomeAmount,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: incomeSource,
                      decoration: InputDecoration(
                        labelText: t(lang, 'incomeSource'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'salary',
                          child: Text(lang == 'ar' ? 'راتب' : 'Salary'),
                        ),
                        DropdownMenuItem(
                          value: 'freelance',
                          child: Text(lang == 'ar' ? 'عمل حر' : 'Freelance'),
                        ),
                        DropdownMenuItem(
                          value: 'business',
                          child: Text(lang == 'ar' ? 'تجارة' : 'Business'),
                        ),
                        DropdownMenuItem(
                          value: 'mixed',
                          child: Text(lang == 'ar' ? 'متعدد' : 'Mixed'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => incomeSource = v ?? incomeSource),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: payday,
                      decoration: InputDecoration(labelText: t(lang, 'payday')),
                      items: List.generate(28, (i) => (i + 1).toString())
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => payday = v ?? payday),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (s == 2) {
      return Card(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t(lang, 'fixedTitle'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: fixedRows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final r = fixedRows[i];
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: lang == 'ar' ? 'البند' : 'Item',
                            ),
                            controller: TextEditingController(
                              text: '${r['name']}',
                            ),
                            onChanged: (v) => r['name'] = v,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: lang == 'ar' ? 'المبلغ' : 'Amount',
                            ),
                            controller: TextEditingController(
                              text: '${r['amount']}',
                            ),
                            onChanged: (v) =>
                                r['amount'] = int.tryParse(v) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: () =>
                              setState(() => fixedRows.removeAt(i)),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    );
                  },
                ),
              ),
              FilledButton.tonal(
                onPressed: () =>
                    setState(() => fixedRows.add({'name': '', 'amount': 0})),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 18),
                    const SizedBox(width: 8),
                    Text(lang == 'ar' ? 'إضافة بند' : 'Add item'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (s == 3) {
      final keys = [
        'restaurants',
        'delivery',
        'transport',
        'shopping',
        'bnpl',
        'bills',
      ];
      return Card(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t(lang, 'variableTitle'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: keys.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final k = keys[i];
                    final v = scale[k] ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                catLabel(lang, k),
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            SoftBadge('$v/5'),
                          ],
                        ),
                        Slider(
                          value: v.toDouble(),
                          min: 0,
                          max: 5,
                          divisions: 5,
                          onChanged: (nv) =>
                              setState(() => scale[k] = nv.round()),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (s == 4) {
      return Card(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t(lang, 'goalTitle'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: goalType,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'النوع' : 'Type',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'car',
                          child: Text(lang == 'ar' ? 'سيارة' : 'Car'),
                        ),
                        DropdownMenuItem(
                          value: 'travel',
                          child: Text(lang == 'ar' ? 'سفر' : 'Travel'),
                        ),
                        DropdownMenuItem(
                          value: 'wedding',
                          child: Text(lang == 'ar' ? 'زواج' : 'Wedding'),
                        ),
                        DropdownMenuItem(
                          value: 'emergency',
                          child: Text(lang == 'ar' ? 'طوارئ' : 'Emergency'),
                        ),
                      ],
                      onChanged: (v) {
                        final val = v ?? goalType;
                        setState(() {
                          goalType = val;
                          final map = {
                            'car': lang == 'ar' ? 'سيارة' : 'Dream Car',
                            'travel': lang == 'ar' ? 'سفر' : 'Travel',
                            'wedding': lang == 'ar' ? 'زواج' : 'Wedding',
                            'emergency': lang == 'ar'
                                ? 'طوارئ'
                                : 'Emergency Fund',
                          };
                          goalName = map[val] ?? goalName;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: goalDeadline,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'المدة' : 'Deadline',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 6,
                          child: Text(lang == 'ar' ? '6 أشهر' : '6 months'),
                        ),
                        DropdownMenuItem(
                          value: 12,
                          child: Text(lang == 'ar' ? 'سنة' : '1 year'),
                        ),
                        DropdownMenuItem(
                          value: 18,
                          child: Text(lang == 'ar' ? '18 شهر' : '18 months'),
                        ),
                        DropdownMenuItem(
                          value: 24,
                          child: Text(lang == 'ar' ? 'سنتين' : '2 years'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => goalDeadline = v ?? goalDeadline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: lang == 'ar' ? 'اسم الهدف' : 'Goal name',
                ),
                controller: TextEditingController(text: goalName),
                onChanged: (v) => goalName = v,
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: lang == 'ar' ? 'المبلغ' : 'Target amount',
                ),
                controller: TextEditingController(text: goalAmount.toString()),
                onChanged: (v) => goalAmount = int.tryParse(v) ?? goalAmount,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: runFeasibility,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 18),
                    const SizedBox(width: 8),
                    Text(t(lang, 'feasibility')),
                  ],
                ),
              ),
              if (feasibility != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    color: (feasibility!['feasible'] as bool)
                        ? Colors.green.withOpacity(0.08)
                        : Colors.amber.withOpacity(0.12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (feasibility!['feasible'] as bool)
                                  ? (lang == 'ar' ? 'قابل للتنفيذ' : 'Feasible')
                                  : (lang == 'ar'
                                        ? 'غير واقعي'
                                        : 'Not feasible'),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          SoftBadge(
                            lang == 'ar'
                                ? 'مطلوب ${feasibility!['monthlyRequired']} شهرياً'
                                : '${feasibility!['monthlyRequired']}/mo required',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${feasibility!['suggestion']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (!(feasibility!['feasible'] as bool)) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: MiniInfoCard(
                                label: lang == 'ar'
                                    ? 'مدة مقترحة'
                                    : 'Suggested deadline',
                                value:
                                    '${feasibility!['suggestedDeadline']} ${lang == 'ar' ? 'شهر' : 'months'}',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MiniInfoCard(
                                label: lang == 'ar'
                                    ? 'هدف مقترح'
                                    : 'Suggested target',
                                value: fmtSAR(
                                  feasibility!['suggestedTarget'] as num,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (s == 5) {
      return Card(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t(lang, 'questionnaire'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: qBnpl,
                decoration: InputDecoration(
                  labelText: lang == 'ar'
                      ? 'هل تستخدم التقسيط؟'
                      : 'Do you use BNPL?',
                ),
                items: [
                  DropdownMenuItem(
                    value: 'never',
                    child: Text(lang == 'ar' ? 'أبداً' : 'Never'),
                  ),
                  DropdownMenuItem(
                    value: 'sometimes',
                    child: Text(lang == 'ar' ? 'أحياناً' : 'Sometimes'),
                  ),
                  DropdownMenuItem(
                    value: 'often',
                    child: Text(lang == 'ar' ? 'كثيراً' : 'Often'),
                  ),
                ],
                onChanged: (v) => setState(() => qBnpl = v ?? qBnpl),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: qDebt,
                decoration: InputDecoration(
                  labelText: lang == 'ar'
                      ? 'هل عندك ديون؟'
                      : 'Any current debt?',
                ),
                items: [
                  DropdownMenuItem(
                    value: 'no',
                    child: Text(lang == 'ar' ? 'لا' : 'No'),
                  ),
                  DropdownMenuItem(
                    value: 'yes',
                    child: Text(lang == 'ar' ? 'نعم' : 'Yes'),
                  ),
                ],
                onChanged: (v) => setState(() => qDebt = v ?? qDebt),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: qAutoSave,
                decoration: InputDecoration(
                  labelText: lang == 'ar'
                      ? 'تفضل ادخار تلقائي؟'
                      : 'Prefer auto-saving?',
                ),
                items: [
                  DropdownMenuItem(
                    value: 'yes',
                    child: Text(lang == 'ar' ? 'نعم' : 'Yes'),
                  ),
                  DropdownMenuItem(
                    value: 'no',
                    child: Text(lang == 'ar' ? 'لا' : 'No'),
                  ),
                ],
                onChanged: (v) => setState(() => qAutoSave = v ?? qAutoSave),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: qNotify,
                decoration: InputDecoration(
                  labelText: lang == 'ar'
                      ? 'متى تريد التذكير؟'
                      : 'Notification preference',
                ),
                items: [
                  DropdownMenuItem(
                    value: 'daily',
                    child: Text(lang == 'ar' ? 'يومي' : 'Daily'),
                  ),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text(lang == 'ar' ? 'أسبوعي' : 'Weekly'),
                  ),
                  DropdownMenuItem(
                    value: 'only',
                    child: Text(
                      lang == 'ar' ? 'عند تجاوز الحد' : 'Only on exceed',
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => qNotify = v ?? qNotify),
              ),
            ],
          ),
        ),
      );
    }

    if (s == 6) {
      return Card(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t(lang, 'firstExpense'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'المبلغ' : 'Amount',
                      ),
                      controller: TextEditingController(
                        text: '${firstTxn['amount']}',
                      ),
                      onChanged: (v) => firstTxn['amount'] =
                          int.tryParse(v) ?? firstTxn['amount'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'التاريخ' : 'Date',
                        suffixIcon: const Icon(Icons.calendar_month_outlined),
                      ),
                      controller: TextEditingController(
                        text: '${firstTxn['date']}',
                      ),
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(now.year - 2),
                          lastDate: DateTime(now.year + 1),
                          initialDate: now,
                        );
                        if (picked != null) {
                          setState(() {
                            firstTxn['date'] =
                                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: lang == 'ar' ? 'الوصف' : 'Description',
                ),
                controller: TextEditingController(
                  text: '${firstTxn['description']}',
                ),
                onChanged: (v) => firstTxn['description'] = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: '${firstTxn['category']}',
                decoration: InputDecoration(
                  labelText: lang == 'ar' ? 'التصنيف' : 'Category',
                ),
                items: categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.key,
                        child: Text(lang == 'ar' ? c.ar : c.en),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(
                  () => firstTxn['category'] = v ?? firstTxn['category'],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mic_none_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(t(lang, 'voice')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_camera_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(t(lang, 'camera')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InsightBanner(
                lang: lang,
                severity: 'info',
                title: lang == 'ar' ? 'تصنيف تلقائي' : 'Auto-categorized',
                message: lang == 'ar'
                    ? 'تم تصنيف العملية ويمكنك التعديل.'
                    : 'We categorized it — you can override anytime.',
              ),
            ],
          ),
        ),
      );
    }

    // s == 7
    return Card(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t(lang, 'saveProgress'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              lang == 'ar'
                  ? 'لتزامن بياناتك ومتابعة تقدمك عبر الأجهزة.'
                  : 'Sync your data and keep your progress across devices.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {},
                    child: Text('${t(lang, 'oauth')} Google'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {},
                    child: Text('${t(lang, 'oauth')} Apple'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: () {}, child: Text(t(lang, 'email'))),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: complete,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t(lang, 'continue')),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lang == 'ar'
                  ? 'نحن لا نطلب بيانات دخول البنك. يمكنك حذف بياناتك في أي وقت.'
                  : 'We never ask for bank credentials. You can delete your data anytime.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
