import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/data.dart';
import '../../features/dashboard/bloc/dashboard_bloc.dart';
import '../../features/settings/bloc/settings_bloc.dart';

class CoachTab extends StatelessWidget {
  const CoachTab({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.select(
      (SettingsBloc b) => b.state.locale.languageCode,
    );
    final dbState = context.select((DashboardBloc b) => b.state);

    final variable = dbState.totalSpent;
    final bnpl = 0.0; // Placeholder as per original Code
    final ratio = variable <= 0 ? 0 : bnpl / variable;

    final saved = dbState.goal?.savedAmount ?? 0;
    final target = dbState.goal?.targetAmount ?? 1;
    final deadline = dbState.goal?.deadlineMonths ?? 12;
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            ),
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: () {},
              child: Text(lang == 'ar' ? 'إرسال (نموذج)' : 'Send (prototype)'),
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
    );
  }
}
