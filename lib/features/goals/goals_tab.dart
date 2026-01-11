import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/data.dart';
import '../../widgets/components.dart';
import '../../widgets/insight_banner.dart';

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
                      child: MiniInfoCard(
                        label: lang == 'ar' ? 'المدخر' : 'Saved',
                        value: fmtSAR(saved),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MiniInfoCard(
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
                SuggestionCard(
                  title: lang == 'ar'
                      ? 'خفض المطاعم 15%'
                      : 'Reduce dining by 15%',
                  desc: lang == 'ar'
                      ? 'سيوفر هذا مبلغ يساعدك تصل الهدف أسرع.'
                      : 'This saves money that moves your goal forward faster.',
                ),
                const SizedBox(height: 8),
                SuggestionCard(
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
