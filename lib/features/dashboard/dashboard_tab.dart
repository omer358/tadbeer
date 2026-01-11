import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/data.dart';
import '../../widgets/components.dart';
import '../../widgets/insight_banner.dart';
import '../../widgets/charts.dart';

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
              child: StatCard(
                label: t(lang, 'income'),
                value: fmtSAR(totals['income'] ?? 0),
                sub: '${t(lang, 'fixed')}: ${fmtSAR(totals['fixed'] ?? 0)}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
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
              child: StatCard(
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
                      child: MiniInfoCard(
                        label: lang == 'ar' ? 'المدخر' : 'Saved',
                        value: fmtSAR(saved),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MiniInfoCard(
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
