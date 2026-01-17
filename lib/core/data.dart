// Material package removed since not used

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
    'appName': 'Tadbeer',
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
    'error.timeout': 'Connection timed out. Please try again.',
    'error.noInternet': 'No internet connection. Please check your connection.',
    'error.server': 'We encountered a technical issue. Please try again later.',
    'error.unknown': 'An unexpected error occurred.',
  },
  'ar': {
    'appName': 'تدبير',
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
    'error.timeout':
        'عذراً، استغرق الاتصال وقتاً طويلاً. يرجى المحاولة مرة أخرى.',
    'error.noInternet':
        'عذراً، لا يوجد اتصال بالانترنت. يرجى التحقق من اتصالك.',
    'error.server': 'واجهنا مشكلة فنية. يرجى المحاولة في وقت لاحق.',
    'error.unknown': 'حدث خطأ غير متوقع.',
  },
};

String t(String lang, String key) => (i18n[lang]?[key]) ?? key;
