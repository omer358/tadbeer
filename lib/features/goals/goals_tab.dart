import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/data.dart';
import '../../widgets/components.dart';
import '../../widgets/insight_banner.dart';
import '../goals/bloc/goals_bloc.dart';
import '../settings/bloc/settings_bloc.dart';
import '../dashboard/bloc/dashboard_bloc.dart';
import '../goals/add_goal_dialog.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        final variable = 0.0; // TODO: Get variable from Transactions repo
        final free = math.max(0, income - fixed - variable);

        final req = (target - saved) / math.max(1, deadline);
        final feasible = req <= free;

        return ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SectionTitle(
                      icon: const Icon(Icons.flag_rounded, size: 18),
                      title: t(lang, 'goals'),
                    ),
                  ),
                  FilledButton(
                    onPressed: () =>
                        _openAddGoal(context, lang, income, fixed, variable),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 18),
                        const SizedBox(width: 6),
                        Text(t(lang, 'addGoal')),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: -0.1, end: 0),
            const SizedBox(height: 12),
            if (goal != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      goal.name,
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
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      color: Theme.of(context).colorScheme.primary,
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
              ).animate().fade().slideX(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionTitle(
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    title: lang == 'ar' ? 'اقتراحات' : 'Suggestions',
                  ),
                  const SizedBox(height: 10),
                  // Use DashboardBloc state for suggestions
                  Builder(
                    builder: (context) {
                      final goalSug = context.select(
                        (DashboardBloc b) => b.state.goalSuggestions,
                      );
                      if (goalSug.isEmpty) {
                        return Text(
                          lang == 'ar'
                              ? 'لا توجد اقتراحات حالياً'
                              : 'No suggestions currently.',
                        );
                      }
                      return Column(
                        children: goalSug
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: SuggestionCard(
                                  title: s.title,
                                  desc: s.description,
                                ).animate().fade().slideX(),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),
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
