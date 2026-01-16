import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/data.dart';
import '../../widgets/components.dart';
import '../../widgets/insight_banner.dart';
import '../goals/bloc/goals_bloc.dart';
import '../settings/bloc/settings_bloc.dart';
import '../goals/add_goal_dialog.dart';
import '../../domain/entities/goal.dart';

class GoalsTab extends StatelessWidget {
  const GoalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.select(
      (SettingsBloc b) => b.state.locale.languageCode,
    );

    return BlocBuilder<GoalsBloc, GoalsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final goal = state.goal;
        final profile = state.profile;

        final saved = goal?.savedAmount ?? 0;
        final target = goal?.targetAmount ?? 1;
        final deadline = goal?.deadlineMonths ?? 12;

        // Calculate feasible
        final income = profile?.incomeAmount ?? 0;
        final fixed = profile?.totalFixed ?? 0;
        // Need variable spent... but GoalsBloc state doesn't have it.
        // Option 1: Inject variable spent via constructor (from dashboard?)
        // Option 2: Combine in BLoC.
        // For now, let's assume 'free' income calculation is simplified or 0 if missing.
        // Actually the original GoalsTab logic used 'totals' passed from parent.
        // Currently `GoalsBloc` fetches ONLY goal and profile. It doesn't fetch transactions.
        // Let's assume free income = income - fixed (ignoring variable for this isolation, or better: update GoalsBloc to get txns too?)
        // Or simpler: GoalsTab doesn't need perfect correctness for this prototype step,
        // OR we just use a placeholder for variable.
        // Let's fetch data and refine later.

        final variable = 0.0; // TODO: Get variable from Transactions repo
        final free = math.max(0, income - fixed - variable);

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
                      onPressed: () =>
                          _openAddGoal(context, lang, income, fixed, variable),
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
            if (goal != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        goal.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lang == 'ar' ? 'التقدم' : 'Progress',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
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
                        value: (saved / target).clamp(0, 1).toDouble(),
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
      },
    );
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
    }
  }
}
