import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/data.dart';
import '../../core/locator.dart';
import '../../features/dashboard/bloc/dashboard_bloc.dart';
import '../../features/settings/bloc/settings_bloc.dart';
import 'bloc/coach_bloc.dart';

class CoachTab extends StatelessWidget {
  const CoachTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoachBloc>(),
      child: const _CoachView(),
    );
  }
}

class _CoachView extends StatefulWidget {
  const _CoachView();

  @override
  State<_CoachView> createState() => _CoachViewState();
}

class _CoachViewState extends State<_CoachView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<CoachBloc>().add(SendQuery(text));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.select(
      (SettingsBloc b) => b.state.locale.languageCode,
    );

    // Reuse old logic for summary header
    final dbState = context.select((DashboardBloc b) => b.state);
    final variable = dbState.totalSpent;
    final bnpl = 0.0;
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

    return Column(
      children: [
        // Summary Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Container(
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
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
        ),

        // Chat List
        Expanded(
          child: BlocBuilder<CoachBloc, CoachState>(
            builder: (context, state) {
              if (state.messages.isEmpty) {
                return Center(
                  child: Text(
                    lang == 'ar'
                        ? 'كيف يمكنني مساعدتك اليوم؟'
                        : 'How can I help you today?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount:
                    state.messages.length +
                    (state.status == CoachStatus.loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final msg = state.messages[index];
                  return Align(
                    alignment: msg.isUser
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomRight: msg.isUser
                              ? const Radius.circular(4)
                              : null,
                          bottomLeft: !msg.isUser
                              ? const Radius.circular(4)
                              : null,
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: msg.isUser
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Input Area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: lang == 'ar'
                        ? 'اكتب رسالتك...'
                        : 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _send,
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
