// main.dart
// SmartSpend MVP UI (Flutter) — matches the React prototype screens/frames.
//
// Run:
//   flutter create smartspend_mvp
//   replace lib/main.dart with this file
//   flutter run
//
// Notes:
// - Charts here are lightweight CustomPainter (no deps). If you prefer a chart lib, swap Pie/Line widgets.
// - File/voice/camera are placeholders for hackathon demo.

import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartSpendPrototypeApp());
}

// =====================
// Data + i18n
// =====================

class CategoryDef {
  final String key;
  final String en;
  final String ar;
  const CategoryDef(this.key, this.en, this.ar);
}

const categories = <CategoryDef>[
  CategoryDef('restaurants', 'Restaurants', 'مطاعم'),
  CategoryDef('delivery', 'Delivery', 'توصيل'),
  CategoryDef('transport', 'Transport', 'مواصلات'),
  CategoryDef('shopping', 'Shopping', 'تسوق'),
  CategoryDef('bnpl', 'BNPL / Installments', 'تقسيط / BNPL'),
  CategoryDef('bills', 'Bills', 'فواتير'),
  CategoryDef('other', 'Other', 'أخرى'),
];

String catLabel(String lang, String key) {
  final c = categories.firstWhere(
    (x) => x.key == key,
    orElse: () => const CategoryDef('other', 'Other', 'أخرى'),
  );
  return lang == 'ar' ? c.ar : c.en;
}

String fmtSAR(num n) {
  final v = n.isFinite ? n : 0;
  return 'SAR ${v.round()}';
}

String todayISO() {
  final d = DateTime.now();
  String two(int x) => x.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

const months = [
  {'key': '2026-01', 'label': 'Jan 2026'},
  {'key': '2025-12', 'label': 'Dec 2025'},
  {'key': '2025-11', 'label': 'Nov 2025'},
];

const i18n = {
  'en': {
    'appName': 'SmartSpend',
    'tagline': 'AI budget coach built for real life',
    'next': 'Next',
    'back': 'Back',
    'skip': 'Skip',
    'startNow': 'Start',
    'continue': 'Continue',
    'save': 'Save',
    'done': 'Done',
    'dashboard': 'Dashboard',
    'expenses': 'Expenses',
    'goals': 'Goals',
    'settings': 'Settings',
    'month': 'Month',
    'insight': 'Insight',
    'addExpense': 'Add expense',
    'addGoal': 'Add goal',
    'importStatement': 'Import statement',
    'upload': 'Upload',
    'voice': 'Voice',
    'camera': 'Camera',
    'aiCoach': 'AI Coach',
    'details': 'Details',
    'incomeTitle': 'Monthly income',
    'incomeSource': 'Income source',
    'payday': 'Payday',
    'fixedTitle': 'Fixed expenses',
    'variableTitle': 'Quick spend estimate',
    'goalTitle': 'Your financial goal',
    'feasibility': 'Check feasibility',
    'questionnaire': 'Quick questionnaire',
    'firstExpense': 'Add your last expense',
    'saveProgress': 'Save your progress',
    'oauth': 'Continue with',
    'email': 'Email',
    'later': 'Later',
    'safeToSpend': 'Safe to spend',
    'spent': 'Spent',
    'remaining': 'Remaining',
    'income': 'Income',
    'fixed': 'Fixed',
    'variable': 'Variable',
    'bnpl': 'BNPL',
    'burnRate': 'Burn rate',
    'categorySplit': 'Category split',
    'recent': 'Recent',
    'community': 'Community',
    'weeklyWinners': 'Weekly winners',
    'privacy': 'Privacy',
    'deleteAccount': 'Delete account',
    'logout': 'Logout',
    'theme': 'Theme',
    'language': 'Language',
    'dark': 'Dark',
    'light': 'Light',
    'arabic': 'Arabic',
    'english': 'English',
    'onboarding.s1t': 'Know where your money goes.',
    'onboarding.s1d': 'Log expenses fast. Get clarity instantly.',
    'onboarding.s2t': 'BNPL feels light — until it stacks.',
    'onboarding.s2d': 'We help you see the real cost and stay in control.',
    'onboarding.s3t': 'Personal plan + weekly coaching.',
    'onboarding.s3d': 'Set goals, track progress, and adjust with AI guidance.',
  },
  'ar': {
    'appName': 'سمارت سبند',
    'tagline': 'مدرب ميزانية بالذكاء الاصطناعي',
    'next': 'التالي',
    'back': 'رجوع',
    'skip': 'تخطي',
    'startNow': 'ابدأ',
    'continue': 'متابعة',
    'save': 'حفظ',
    'done': 'تم',
    'dashboard': 'الرئيسية',
    'expenses': 'المصروفات',
    'goals': 'الأهداف',
    'settings': 'الإعدادات',
    'month': 'الشهر',
    'insight': 'تنبيه',
    'addExpense': 'إضافة مصروف',
    'addGoal': 'إضافة هدف',
    'importStatement': 'رفع كشف حساب',
    'upload': 'رفع',
    'voice': 'صوت',
    'camera': 'كاميرا',
    'aiCoach': 'المدرب الذكي',
    'details': 'تفاصيل',
    'incomeTitle': 'الدخل الشهري',
    'incomeSource': 'مصدر الدخل',
    'payday': 'يوم الراتب',
    'fixedTitle': 'مصروفات ثابتة',
    'variableTitle': 'تقدير سريع للمصروف',
    'goalTitle': 'هدفك المالي',
    'feasibility': 'تحقق من الواقعية',
    'questionnaire': 'أسئلة سريعة',
    'firstExpense': 'سجل آخر مصروف',
    'saveProgress': 'احفظ بياناتك',
    'oauth': 'تابع باستخدام',
    'email': 'البريد',
    'later': 'لاحقاً',
    'safeToSpend': 'المتاح للإنفاق',
    'spent': 'المصروف',
    'remaining': 'المتبقي',
    'income': 'الدخل',
    'fixed': 'الثابت',
    'variable': 'المتغير',
    'bnpl': 'تقسيط',
    'burnRate': 'معدل الصرف',
    'categorySplit': 'توزيع المصروف',
    'recent': 'آخر العمليات',
    'community': 'المجتمع',
    'weeklyWinners': 'أبطال الأسبوع',
    'privacy': 'الخصوصية',
    'deleteAccount': 'حذف الحساب',
    'logout': 'تسجيل خروج',
    'theme': 'المظهر',
    'language': 'اللغة',
    'dark': 'داكن',
    'light': 'فاتح',
    'arabic': 'العربية',
    'english': 'الإنجليزية',
    'onboarding.s1t': 'اعرف فلوسك رايحة فين.',
    'onboarding.s1d': 'سجل مصروفاتك بسرعة… وشوف الصورة كاملة.',
    'onboarding.s2t': 'التقسيط يبان بسيط… لكنه يتراكم.',
    'onboarding.s2d': 'نساعدك تتحكم وتوقف النزيف قبل نهاية الشهر.',
    'onboarding.s3t': 'خطة شخصية + ملخص أسبوعي.',
    'onboarding.s3d': 'حدد هدف وامشي عليه بخطوات واضحة.',
  },
};

String t(String lang, String key) => (i18n[lang]?[key] as String?) ?? key;

// =====================
// App root
// =====================

class SmartSpendPrototypeApp extends StatefulWidget {
  const SmartSpendPrototypeApp({super.key});

  @override
  State<SmartSpendPrototypeApp> createState() => _SmartSpendPrototypeAppState();
}

class _SmartSpendPrototypeAppState extends State<SmartSpendPrototypeApp> {
  String lang = 'ar';
  bool dark = false;
  Map<String, dynamic>? boot;

  @override
  Widget build(BuildContext context) {
    final dir = lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        cardTheme: const CardThemeData(
          elevation: 1.5,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        cardTheme: const CardThemeData(
          elevation: 1.5,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: dir,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: boot == null
          ? OnboardingFlow(
              lang: lang,
              onToggleLang: () =>
                  setState(() => lang = lang == 'ar' ? 'en' : 'ar'),
              onComplete: (payload) => setState(() => boot = payload),
            )
          : AppShell(
              lang: lang,
              dark: dark,
              onToggleLang: () =>
                  setState(() => lang = lang == 'ar' ? 'en' : 'ar'),
              onToggleDark: (v) => setState(() => dark = v),
              initial: boot!,
            ),
    );
  }
}

// =====================
// Layout helpers
// =====================

class PhoneFrame extends StatelessWidget {
  final Widget child;
  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ),
    );
  }
}

class SoftBadge extends StatelessWidget {
  final String text;
  final Color? bg;
  final Color? fg;
  const SoftBadge(this.text, {super.key, this.bg, this.fg});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final b = bg ?? scheme.surfaceContainerHighest;
    final f = fg ?? scheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: b,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: f),
      ),
    );
  }
}

class InsightBanner extends StatelessWidget {
  final String lang;
  final String title;
  final String message;
  final String severity; // warning|success|info
  final VoidCallback? onDetails;

  const InsightBanner({
    super.key,
    required this.lang,
    required this.title,
    required this.message,
    this.severity = 'warning',
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWarn = severity == 'warning';
    final isOk = severity == 'success';

    Color iconColor = isWarn
        ? Colors.amber.shade700
        : isOk
        ? Colors.green.shade600
        : Colors.lightBlue.shade600;
    IconData icon = isWarn
        ? Icons.warning_amber_rounded
        : isOk
        ? Icons.check_circle_outline
        : Icons.auto_awesome;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SoftBadge(
                        t(lang, 'insight'),
                        bg: scheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (onDetails != null)
              TextButton(onPressed: onDetails, child: Text(t(lang, 'details'))),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final Widget icon;
  final String title;
  final Widget? right;
  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconTheme(
          data: IconThemeData(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          child: icon,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (right != null) right!,
      ],
    );
  }
}

// =====================
// Onboarding Flow (8 steps)
// =====================

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
                              child: _MiniInfoCard(
                                label: lang == 'ar'
                                    ? 'مدة مقترحة'
                                    : 'Suggested deadline',
                                value:
                                    '${feasibility!['suggestedDeadline']} ${lang == 'ar' ? 'شهر' : 'months'}',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniInfoCard(
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

class _MiniInfoCard extends StatelessWidget {
  final String label;
  final String value;
  const _MiniInfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// =====================
// App shell + tabs
// =====================

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
    for (final c in categories) {
      map[c.key] = 0;
    }
    for (final t in txns) {
      if (t['direction'] != 'debit') continue;
      final k = '${t['category']}';
      map[k] = (map[k] ?? 0) + ((t['amount'] as num?) ?? 0);
    }
    return map;
  }

  List<Map<String, dynamic>> donutData() {
    final bc = byCategory();
    final items = bc.entries
        .where((e) => e.value > 0)
        .map(
          (e) => {
            'key': e.key,
            'name': catLabel(lang, e.key),
            'value': e.value,
          },
        )
        .toList();
    items.sort((a, b) => (b['value'] as num).compareTo(a['value'] as num));
    return items;
  }

  List<Map<String, num>> burnRate() {
    final v = totals()['variable'] ?? 0;
    const days = 14;
    final expectedDaily = (v / days);
    return List.generate(days, (i) {
      final day = i + 1;
      final expected = (expectedDaily * day).round();
      final spent = math
          .min(v.toInt(), expected + (i % 3 == 0 ? 120 : -40))
          .toInt();
      return {
        'day': day.toDouble(),
        'spent': spent.toDouble(),
        'expected': expected.toDouble(),
      };
    });
  }

  Map<String, dynamic> aiBanner() {
    final tot = totals();
    final variable = (tot['variable'] ?? 0).toDouble();
    final bnpl = (tot['bnpl'] ?? 0).toDouble();
    final ratio = variable <= 0 ? 0 : (bnpl / variable);
    final warn = ratio > 0.3;
    final pct = (ratio * 100).round();

    return {
      'severity': warn ? 'warning' : 'success',
      'title': warn
          ? (lang == 'ar' ? 'خفض التقسيط' : 'Reduce BNPL')
          : (lang == 'ar' ? 'وضع ممتاز' : 'On track'),
      'message': warn
          ? (lang == 'ar'
                ? 'التقسيط الآن $pct%. حاول تخفيضه إلى 30% لتحسين الادخار.'
                : 'BNPL is $pct%. Try reducing it to 30% to improve savings.')
          : (lang == 'ar'
                ? 'التزامك جيد هذا الشهر. استمر.'
                : 'You’re doing well this month. Keep it up.'),
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
    final scheme = Theme.of(context).colorScheme;

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
        onImport: () => _openStatement(context),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(lang, 'appName'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              t(lang, 'tagline'),
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: month,
              items: months
                  .map(
                    (m) => DropdownMenuItem(
                      value: m['key']!,
                      child: Text(m['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => month = v ?? month),
            ),
          ),
          IconButton(
            onPressed: () => _openCoach(context),
            icon: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(width: 4),
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
    if (res != null) addExpense(res);
  }

  Future<void> _openAddGoal(BuildContext context) async {
    final tot = totals();
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddGoalDialog(
        lang: lang,
        income: (tot['income'] ?? 0).toDouble(),
        fixed: (tot['fixed'] ?? 0).toDouble(),
        variable: (tot['variable'] ?? 0).toDouble(),
      ),
    );
    if (res != null) addGoal(res);
  }

  Future<void> _openStatement(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => StatementUploadDialog(lang: lang),
    );
  }

  Future<void> _openCoach(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => CoachDialog(lang: lang, totals: totals(), goal: goal),
    );
  }
}

// =====================
// Tabs
// =====================

class DashboardTab extends StatelessWidget {
  final String lang;
  final Map<String, num> totals;
  final Map<String, dynamic> budgets;
  final Map<String, num> byCategory;
  final List<Map<String, dynamic>> donut;
  final List<Map<String, num>> burn;
  final Map<String, dynamic> goal;
  final List<Map<String, dynamic>> txns;
  final Map<String, dynamic> ai;
  final VoidCallback onAddExpense;
  final VoidCallback onAddGoal;
  final VoidCallback onImport;

  const DashboardTab({
    super.key,
    required this.lang,
    required this.totals,
    required this.budgets,
    required this.byCategory,
    required this.donut,
    required this.burn,
    required this.goal,
    required this.txns,
    required this.ai,
    required this.onAddExpense,
    required this.onAddGoal,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final community = [
      {
        'name': 'Noura',
        'badge': lang == 'ar' ? 'سلسلة أهداف' : 'Goal streak',
        'note': lang == 'ar' ? 'التزمت 4 أسابيع' : '4-week streak',
      },
      {
        'name': 'Fahad',
        'badge': lang == 'ar' ? 'تقسيط أقل' : 'BNPL down',
        'note': lang == 'ar' ? 'خفض التقسيط 20%' : 'Down 20%',
      },
      {
        'name': 'Maha',
        'badge': lang == 'ar' ? 'مطاعم أقل' : 'Dining down',
        'note': lang == 'ar' ? 'أقل 3 أيام' : '3 days under limit',
      },
    ];

    final saved = (goal['saved'] as num?) ?? 0;
    final target = (goal['target'] as num?) ?? 1;
    final deadline = (goal['deadlineMonths'] as num?) ?? 12;
    final pct = (saved / math.max(1, target) * 100).clamp(0, 100).round();

    return ListView(
      children: [
        InsightBanner(
          lang: lang,
          severity: '${ai['severity']}',
          title: '${ai['title']}',
          message: '${ai['message']}',
          onDetails: onImport,
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: t(lang, 'income'),
                value: fmtSAR(totals['income'] ?? 0),
                sub: '${t(lang, 'fixed')}: ${fmtSAR(totals['fixed'] ?? 0)}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: t(lang, 'spent'),
                value: fmtSAR(totals['variable'] ?? 0),
                sub: '${t(lang, 'bnpl')}: ${fmtSAR(totals['bnpl'] ?? 0)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: t(lang, 'safeToSpend'),
                value: fmtSAR(totals['safe'] ?? 0),
                sub: (totals['safe'] ?? 0) < 0
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.tonal(
                        onPressed: onImport,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload_file_outlined, size: 18),
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionTitle(
                  icon: const Icon(Icons.pie_chart_outline, size: 18),
                  title: t(lang, 'categorySplit'),
                ),
                const SizedBox(height: 12),
                SizedBox(height: 190, child: DonutChart(items: donut)),
              ],
            ),
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
                  icon: const Icon(Icons.show_chart, size: 18),
                  title: t(lang, 'burnRate'),
                ),
                const SizedBox(height: 12),
                SizedBox(height: 200, child: MiniLineChart(data: burn)),
              ],
            ),
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
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  title: t(lang, 'goals'),
                  right: TextButton.icon(
                    onPressed: onAddGoal,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(t(lang, 'addGoal')),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${goal['name']}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lang == 'ar'
                                ? 'الهدف: ${fmtSAR(target)} خلال $deadline شهر'
                                : 'Target: ${fmtSAR(target)} in $deadline months',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    SoftBadge('$pct%'),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (saved / math.max(1, target)).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(99),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniInfoCard(
                        label: lang == 'ar' ? 'المدخر' : 'Saved',
                        value: fmtSAR(saved),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniInfoCard(
                        label: lang == 'ar'
                            ? 'المطلوب شهرياً'
                            : 'Monthly required',
                        value: fmtSAR(
                          ((target - saved) / math.max(1, deadline)).round(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                    onPressed: onAddExpense,
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
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '${x['description']}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${catLabel(lang, '${x['category']}')} • ${x['date']}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          fmtSAR(x['amount'] as num? ?? 0),
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

        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionTitle(
                  icon: const Icon(Icons.people_alt_outlined, size: 18),
                  title: t(lang, 'weeklyWinners'),
                ),
                const SizedBox(height: 10),
                ...community.map((x) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: scheme.surfaceContainerHighest.withOpacity(0.5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '${x['name']}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${x['note']}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        SoftBadge('${x['badge']}'),
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
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              sub,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpensesTab extends StatefulWidget {
  final String lang;
  final List<Map<String, dynamic>> txns;
  final VoidCallback onAddExpense;
  final VoidCallback onImport;

  const ExpensesTab({
    super.key,
    required this.lang,
    required this.txns,
    required this.onAddExpense,
    required this.onImport,
  });

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final scheme = Theme.of(context).colorScheme;

    final filtered = widget.txns.where((x) {
      if (filter == 'all') return true;
      if (filter == 'bnpl') return '${x['category']}' == 'bnpl';
      return '${x['category']}' == filter;
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: widget.onImport,
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
                      onPressed: widget.onAddExpense,
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
                        .map((c) => _chip(lang == 'ar' ? c.ar : c.en, c.key)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...filtered.take(12).map((x) {
          final isBnpl = '${x['category']}' == 'bnpl';
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
                              '${x['description']}',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${catLabel(lang, '${x['category']}')} • ${x['date']}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        fmtSAR(x['amount'] as num? ?? 0),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  if (isBnpl) ...[
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
}

class GoalsTab extends StatelessWidget {
  final String lang;
  final Map<String, dynamic> goal;
  final Map<String, num> totals;
  final VoidCallback onAddGoal;

  const GoalsTab({
    super.key,
    required this.lang,
    required this.goal,
    required this.totals,
    required this.onAddGoal,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final income = (totals['income'] ?? 0).toDouble();
    final fixed = (totals['fixed'] ?? 0).toDouble();
    final variable = (totals['variable'] ?? 0).toDouble();

    final free = math.max(0, income - fixed - variable);
    final saved = (goal['saved'] as num?) ?? 0;
    final target = (goal['target'] as num?) ?? 1;
    final deadline = (goal['deadlineMonths'] as num?) ?? 12;
    final req = (target - saved) / math.max(1, deadline);
    final feasible = req <= free;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t(lang, 'goals'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: onAddGoal,
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 18),
                      const SizedBox(width: 6),
                      Text(t(lang, 'addGoal')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${goal['name']}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lang == 'ar' ? 'التقدم' : 'Progress',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SoftBadge(
                      feasible
                          ? (lang == 'ar' ? 'قابل للتنفيذ' : 'Feasible')
                          : (lang == 'ar' ? 'غير واقعي' : 'Not feasible'),
                      bg: feasible
                          ? Colors.green.withOpacity(0.15)
                          : Colors.amber.withOpacity(0.18),
                      fg: feasible
                          ? Colors.green.shade900
                          : Colors.amber.shade900,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (saved / math.max(1, target)).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(99),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniInfoCard(
                        label: lang == 'ar' ? 'المدخر' : 'Saved',
                        value: fmtSAR(saved),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniInfoCard(
                        label: lang == 'ar' ? 'المتبقي' : 'Remaining',
                        value: fmtSAR(target - saved),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InsightBanner(
                  lang: lang,
                  severity: feasible ? 'success' : 'warning',
                  title: lang == 'ar' ? 'صحة الهدف' : 'Goal health',
                  message: feasible
                      ? (lang == 'ar'
                            ? 'مطلوب ادخار ${fmtSAR(req.round())} شهرياً. المتاح لديك تقريباً ${fmtSAR(free.round())}.'
                            : 'You need to save ${fmtSAR(req.round())}/mo. You have ~${fmtSAR(free.round())} free.')
                      : (lang == 'ar'
                            ? 'المطلوب ${fmtSAR(req.round())} شهرياً أكبر من المتاح ${fmtSAR(free.round())}. اقترح تمديد المدة.'
                            : 'Required ${fmtSAR(req.round())}/mo exceeds free ${fmtSAR(free.round())}. Extend the deadline.'),
                ),
              ],
            ),
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
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  title: lang == 'ar' ? 'اقتراحات' : 'Suggestions',
                ),
                const SizedBox(height: 10),
                _SuggestionCard(
                  title: lang == 'ar'
                      ? 'خفض المطاعم 15%'
                      : 'Reduce dining by 15%',
                  desc: lang == 'ar'
                      ? 'سيوفر هذا مبلغ يساعدك تصل الهدف أسرع.'
                      : 'This saves money that moves your goal forward faster.',
                ),
                const SizedBox(height: 8),
                _SuggestionCard(
                  title: lang == 'ar'
                      ? 'تجميد التقسيط الجديد'
                      : 'Freeze new BNPL',
                  desc: lang == 'ar'
                      ? 'اكتفِ بالأقساط الحالية هذا الشهر.'
                      : 'Stick to existing installments this month.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final String desc;
  const _SuggestionCard({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  final String lang;
  final bool dark;
  final VoidCallback onToggleLang;
  final ValueChanged<bool> onToggleDark;
  final VoidCallback onImport;

  const SettingsTab({
    super.key,
    required this.lang,
    required this.dark,
    required this.onToggleLang,
    required this.onToggleDark,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t(lang, 'settings'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  lang == 'ar'
                      ? 'تحكم بالخصوصية والمظهر.'
                      : 'Control privacy and appearance.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        dark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t(lang, 'theme'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  dark ? t(lang, 'dark') : t(lang, 'light'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(value: dark, onChanged: onToggleDark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.language_outlined,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t(lang, 'language'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: onToggleLang,
                  child: Text(
                    lang == 'ar' ? t('ar', 'english') : t('en', 'arabic'),
                  ),
                ),
              ],
            ),
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
                  icon: const Icon(Icons.upload_file_outlined, size: 18),
                  title: t(lang, 'importStatement'),
                ),
                const SizedBox(height: 10),
                Text(
                  lang == 'ar'
                      ? 'ارفع CSV أو PDF لتحليل مصروفاتك.'
                      : 'Upload CSV or PDF to analyze spending.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: onImport,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(t(lang, 'upload')),
                    ],
                  ),
                ),
              ],
            ),
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
                  icon: const Icon(Icons.shield_outlined, size: 18),
                  title: t(lang, 'privacy'),
                ),
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: () {},
                  child: Text(lang == 'ar' ? 'تصدير البيانات' : 'Export data'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline, size: 18),
                      const SizedBox(width: 8),
                      Text(t(lang, 'deleteAccount')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout_outlined),
          label: Text(t(lang, 'logout')),
        ),
        const SizedBox(height: 10),
        Text(
          lang == 'ar'
              ? 'ملاحظة: هذا نموذج UX للعرض في الهاكاثون (بدون اتصال حقيقي بالبنوك).'
              : 'Note: This is a hackathon UX prototype (no real bank connectivity).',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

// =====================
// Dialogs
// =====================

class AddExpenseDialog extends StatefulWidget {
  final String lang;
  const AddExpenseDialog({super.key, required this.lang});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  int amount = 58;
  String desc = 'AlBaik';
  String date = todayISO();
  String category = 'restaurants';
  bool bnpl = false;

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return AlertDialog(
      title: Text(t(lang, 'addExpense')),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'المبلغ' : 'Amount',
                      ),
                      controller: TextEditingController(
                        text: amount.toString(),
                      ),
                      onChanged: (v) => amount = int.tryParse(v) ?? amount,
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
                      controller: TextEditingController(text: date),
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
                            date =
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
                controller: TextEditingController(text: desc),
                onChanged: (v) => desc = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
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
                onChanged: (v) => setState(() => category = v ?? category),
              ),
              const SizedBox(height: 12),
              Container(
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
                      child: Text(
                        lang == 'ar' ? 'عملية تقسيط' : 'BNPL / Installment',
                      ),
                    ),
                    Switch(
                      value: bnpl,
                      onChanged: (v) => setState(() => bnpl = v),
                    ),
                  ],
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
                title: lang == 'ar' ? 'الذكاء الاصطناعي' : 'AI',
                message: lang == 'ar'
                    ? 'سيتم التصنيف تلقائياً ويمكنك التعديل.'
                    : 'We’ll auto-categorize and you can override.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t(lang, 'back')),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop({
              'amount': amount,
              'description': desc,
              'date': date,
              'category': bnpl ? 'bnpl' : category,
              'direction': 'debit',
              'bnpl': bnpl,
            });
          },
          child: Text(t(lang, 'save')),
        ),
      ],
    );
  }
}

class AddGoalDialog extends StatefulWidget {
  final String lang;
  final double income;
  final double fixed;
  final double variable;

  const AddGoalDialog({
    super.key,
    required this.lang,
    required this.income,
    required this.fixed,
    required this.variable,
  });

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  String type = 'car';
  String name = 'Car';
  int target = 25000;
  int deadlineMonths = 12;
  Map<String, dynamic>? result;

  @override
  void initState() {
    super.initState();
    if (widget.lang == 'ar') name = 'سيارة';
  }

  void check() {
    final free = math.max(0, widget.income - widget.fixed - widget.variable);
    final req = target / math.max(1, deadlineMonths);
    setState(() {
      result = {'free': free, 'req': req, 'feasible': req <= free};
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return AlertDialog(
      title: Text(t(lang, 'addGoal')),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: type,
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
                        final val = v ?? type;
                        setState(() {
                          type = val;
                          final map = {
                            'car': lang == 'ar' ? 'سيارة' : 'Car',
                            'travel': lang == 'ar' ? 'سفر' : 'Travel',
                            'wedding': lang == 'ar' ? 'زواج' : 'Wedding',
                            'emergency': lang == 'ar' ? 'طوارئ' : 'Emergency',
                          };
                          name = map[val] ?? name;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: deadlineMonths,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'المدة' : 'Deadline',
                      ),
                      items: const [6, 12, 18, 24]
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(
                                d == 12
                                    ? (lang == 'ar' ? 'سنة' : '1 year')
                                    : (lang == 'ar' ? '$d شهر' : '$d months'),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => deadlineMonths = v ?? deadlineMonths),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: lang == 'ar' ? 'اسم الهدف' : 'Goal name',
                ),
                controller: TextEditingController(text: name),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: lang == 'ar' ? 'المبلغ' : 'Target',
                ),
                controller: TextEditingController(text: target.toString()),
                onChanged: (v) => target = int.tryParse(v) ?? target,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: check,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, size: 18),
                          const SizedBox(width: 8),
                          Text(t(lang, 'feasibility')),
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
                          const Icon(Icons.mic_none_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(t(lang, 'voice')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (result != null) ...[
                const SizedBox(height: 12),
                InsightBanner(
                  lang: lang,
                  severity: (result!['feasible'] as bool)
                      ? 'success'
                      : 'warning',
                  title: lang == 'ar' ? 'نتيجة' : 'Result',
                  message: (result!['feasible'] as bool)
                      ? (lang == 'ar'
                            ? 'المطلوب ${fmtSAR((result!['req'] as num).round())} شهرياً، والمتاح ${fmtSAR((result!['free'] as num).round())}.'
                            : 'Need ${fmtSAR((result!['req'] as num).round())}/mo, free ~${fmtSAR((result!['free'] as num).round())}.')
                      : (lang == 'ar'
                            ? 'المطلوب ${fmtSAR((result!['req'] as num).round())} شهرياً أكبر من المتاح ${fmtSAR((result!['free'] as num).round())}.'
                            : 'Required ${fmtSAR((result!['req'] as num).round())}/mo exceeds free ${fmtSAR((result!['free'] as num).round())}.'),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t(lang, 'back')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop({
            'type': type,
            'name': name,
            'target': target,
            'deadlineMonths': deadlineMonths,
          }),
          child: Text(t(lang, 'save')),
        ),
      ],
    );
  }
}

class StatementUploadDialog extends StatefulWidget {
  final String lang;
  const StatementUploadDialog({super.key, required this.lang});

  @override
  State<StatementUploadDialog> createState() => _StatementUploadDialogState();
}

class _StatementUploadDialogState extends State<StatementUploadDialog> {
  String fileName = '';
  String notes = '';

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(t(lang, 'importStatement')),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: scheme.outlineVariant,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 28,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lang == 'ar' ? 'اسحب الملف هنا' : 'Drag & drop file here',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lang == 'ar'
                          ? 'CSV أو PDF (للعرض فقط)'
                          : 'CSV or PDF (prototype only)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonal(
                      onPressed: () =>
                          setState(() => fileName = 'statement_jan.csv'),
                      child: Text(lang == 'ar' ? 'اختيار ملف' : 'Choose file'),
                    ),
                    if (fileName.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        fileName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: lang == 'ar'
                      ? 'ملاحظات (اختياري)'
                      : 'Notes (optional)',
                ),
                minLines: 2,
                maxLines: 4,
                onChanged: (v) => notes = v,
              ),
              const SizedBox(height: 12),
              InsightBanner(
                lang: lang,
                severity: 'info',
                title: lang == 'ar'
                    ? 'ماذا يحدث بعد الرفع؟'
                    : 'What happens after upload?',
                message: lang == 'ar'
                    ? 'نستخرج العمليات، نصنفها، ونبني لك لوحة وتحليلات.'
                    : 'We extract transactions, categorize them, and generate insights.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t(lang, 'done')),
        ),
      ],
    );
  }
}

class CoachDialog extends StatefulWidget {
  final String lang;
  final Map<String, num> totals;
  final Map<String, dynamic> goal;
  const CoachDialog({
    super.key,
    required this.lang,
    required this.totals,
    required this.goal,
  });

  @override
  State<CoachDialog> createState() => _CoachDialogState();
}

class _CoachDialogState extends State<CoachDialog> {
  String prompt = '';

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    final variable = (widget.totals['variable'] ?? 0).toDouble();
    final bnpl = (widget.totals['bnpl'] ?? 0).toDouble();
    final ratio = variable <= 0 ? 0 : bnpl / variable;

    final saved = (widget.goal['saved'] as num?) ?? 0;
    final target = (widget.goal['target'] as num?) ?? 1;
    final deadline = (widget.goal['deadlineMonths'] as num?) ?? 12;
    final req = ((target - saved) / math.max(1, deadline)).round();

    final suggestions = <String>[
      ratio > 0.3
          ? (lang == 'ar'
                ? 'أوقف أي تقسيط جديد لمدة 30 يوم.'
                : 'Freeze new BNPL for 30 days.')
          : (lang == 'ar'
                ? 'حافظ على التقسيط تحت 30%.'
                : 'Keep BNPL under 30%.'),
      lang == 'ar'
          ? 'للوصول لهدفك: ادخر ${fmtSAR(req)} شهرياً.'
          : 'To hit your goal: save ${fmtSAR(req)} monthly.',
      lang == 'ar'
          ? 'ابدأ بالأكبر تأثيراً: مطاعم + توصيل + تقسيط.'
          : 'Start with the biggest levers: dining + delivery + BNPL.',
    ];

    return AlertDialog(
      title: Text(t(lang, 'aiCoach')),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      lang == 'ar' ? 'ملخص سريع' : 'Quick summary',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...suggestions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.auto_awesome, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(s)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: lang == 'ar' ? 'اسأل سؤال' : 'Ask a question',
                  hintText: lang == 'ar'
                      ? 'ليش مصروفي يزيد؟'
                      : 'Why am I overspending?',
                ),
                onChanged: (v) => prompt = v,
              ),
              const SizedBox(height: 10),
              FilledButton.tonal(
                onPressed: () => setState(() => prompt = ''),
                child: Text(
                  lang == 'ar' ? 'إرسال (نموذج)' : 'Send (prototype)',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lang == 'ar'
                    ? 'المدرب يقدم إرشادات تعليمية وليس نصيحة مالية.'
                    : 'Coach provides educational guidance, not financial advice.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t(lang, 'done')),
        ),
      ],
    );
  }
}

// =====================
// Charts (CustomPainter)
// =====================

class DonutChart extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const DonutChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.fold<num>(0, (a, b) => a + ((b['value'] as num?) ?? 0));
    return LayoutBuilder(
      builder: (context, c) {
        return CustomPaint(
          painter: _DonutPainter(
            items: items,
            total: total <= 0 ? 1 : total,
            scheme: Theme.of(context).colorScheme,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  fmtSAR(total),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  final num total;
  final ColorScheme scheme;

  _DonutPainter({
    required this.items,
    required this.total,
    required this.scheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.38;
    final stroke = r * 0.36;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = scheme.surfaceContainerHighest;

    canvas.drawCircle(center, r, basePaint);

    final colors = <Color>[
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      Colors.amber,
      Colors.green,
      Colors.pinkAccent,
      Colors.cyan,
    ];

    double start = -math.pi / 2;
    for (int i = 0; i < items.length; i++) {
      final v = (items[i]['value'] as num?) ?? 0;
      if (v <= 0) continue;
      final sweep = (v / total) * (2 * math.pi);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        start,
        sweep.toDouble(),
        false,
        paint,
      );
      start += sweep.toDouble();
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.total != total ||
        oldDelegate.scheme != scheme;
  }
}

class MiniLineChart extends StatelessWidget {
  final List<Map<String, num>> data;
  const MiniLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinePainter(data: data, scheme: Theme.of(context).colorScheme),
      child: const SizedBox.expand(),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<Map<String, num>> data;
  final ColorScheme scheme;

  _LinePainter({required this.data, required this.scheme});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final pad = 10.0;
    final w = size.width;
    final h = size.height;

    double minX = data.first['day']!.toDouble();
    double maxX = data.last['day']!.toDouble();
    double maxY = 1;

    for (final p in data) {
      maxY = math.max(
        maxY,
        math.max(p['spent']!.toDouble(), p['expected']!.toDouble()),
      );
    }

    Offset mapPoint(double x, double y) {
      final nx = (x - minX) / math.max(1e-9, (maxX - minX));
      final ny = 1 - (y / math.max(1e-9, maxY));
      return Offset(pad + nx * (w - 2 * pad), pad + ny * (h - 2 * pad));
    }

    // grid
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = scheme.outlineVariant.withOpacity(0.6);

    final rows = 4;
    for (int i = 0; i <= rows; i++) {
      final y = pad + (h - 2 * pad) * (i / rows);
      canvas.drawLine(Offset(pad, y), Offset(w - pad, y), grid);
    }

    Path lineFor(String key) {
      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final x = data[i]['day']!.toDouble();
        final y = data[i][key]!.toDouble();
        final pt = mapPoint(x, y);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      return path;
    }

    final expectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = scheme.tertiary;

    final spentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = scheme.primary;

    canvas.drawPath(lineFor('expected'), expectedPaint);
    canvas.drawPath(lineFor('spent'), spentPaint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.scheme != scheme;
  }
}
