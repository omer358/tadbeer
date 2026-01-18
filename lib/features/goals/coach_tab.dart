import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/locator.dart';
import '../../widgets/insight_banner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/dashboard/bloc/dashboard_bloc.dart';
import '../../features/settings/bloc/settings_bloc.dart';
import 'bloc/coach_bloc.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

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
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: path,
        );

        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      debugPrint('Recording Error: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
      if (path != null) {
        final lang = context.read<SettingsBloc>().state.locale.languageCode;
        context.read<CoachBloc>().add(SendVoice(path, lang));
      }
    } catch (e) {
      debugPrint('Stop Recording Error: $e');
    }
  }

  void _send() {
    final text = _controller.text.trim();
    final lang = context.read<SettingsBloc>().state.locale.languageCode;
    if (text.isNotEmpty) {
      context.read<CoachBloc>().add(SendQuery(text, lang));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.select(
      (SettingsBloc b) => b.state.locale.languageCode,
    );
    // 3. Suggestions from DashboardBloc
    final coachSuggestions = context.select(
      (DashboardBloc b) => b.state.coachingSuggestions,
    );

    // If suggestions are available, use them. Else empty list or fallback.
    // The UI handles whatever list is passed.
    // If we want to strictly use only backend suggestions:
    // final suggestions = coachSuggestions.map((s) => '${s.title}: ${s.description}').toList();
    // But existing UI expects strings.

    return Column(
      children: [
        // Chat List (containing Summary)
        Expanded(
          child: BlocBuilder<CoachBloc, CoachState>(
            builder: (context, state) {
              final isLoading = state.status == CoachStatus.loading;
              final msgCount = state.messages.length;
              // Items: Summary + (EmptyState OR Messages) + (LoadingIndicator)
              final itemCount =
                  1 + (msgCount == 0 ? 1 : msgCount) + (isLoading ? 1 : 0);

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  // 1. Summary Header
                  if (index == 0) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).colorScheme.surface,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  lang == 'ar' ? 'ملخص سريع' : 'Quick summary',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (coachSuggestions.isEmpty)
                              Text(
                                lang == 'ar'
                                    ? 'لا توجد اقتراحات حالياً'
                                    : 'No suggestions currently.',
                              )
                            else
                              ...coachSuggestions.map(
                                (s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: InsightBanner(
                                    lang: lang,
                                    severity: s.type == "WARNING"
                                        ? 'warning'
                                        : 'info',
                                    title: s.title,
                                    message: s.description,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ).animate().fade().slideY(),
                    );
                  }

                  // 2. Empty State
                  if (msgCount == 0 && index == 1) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            lang == 'ar'
                                ? 'كيف يمكنني مساعدتك اليوم؟'
                                : 'How can I help you today?',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ).animate().fade().scale(),
                    );
                  }

                  // Adjust index for messages (subtract 1 for summary)
                  final msgIndex = index - 1;

                  // 3. Typing Indicator
                  if (isLoading && msgIndex == msgCount) {
                    return Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                          left: 16,
                          right: 16,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            20,
                          ).copyWith(bottomLeft: const Radius.circular(4)),
                        ),
                        child: const _TypingIndicator(),
                      ),
                    ).animate().fade().slideX(begin: -0.1, end: 0);
                  }

                  // 4. Chat Message
                  final msg = state.messages[msgIndex];
                  return Align(
                    alignment: msg.isUser
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                        left: 16,
                        right: 16,
                      ),
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
                      child: msg.isUser
                          ? Text(
                              msg.text,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                            )
                          : MarkdownBody(
                              data: msg.text,
                              styleSheet:
                                  MarkdownStyleSheet.fromTheme(
                                    Theme.of(context),
                                  ).copyWith(
                                    p: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                    strong: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                    ),
                  ).animate().fade().slideY(begin: 0.1, end: 0);
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
                style: IconButton.styleFrom(
                  backgroundColor: _isRecording
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor: _isRecording
                      ? Theme.of(context).colorScheme.onError
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                onPressed: _toggleRecording,
                icon: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
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

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 20,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Dot(controller: _controller, delay: 0.0),
            const SizedBox(width: 4),
            _Dot(controller: _controller, delay: 0.2),
            const SizedBox(width: 4),
            _Dot(controller: _controller, delay: 0.4),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AnimationController controller;
  final double delay;

  const _Dot({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double opacity =
            (math.sin((controller.value * 2 * math.pi) + (delay * math.pi)) +
                1) /
            2;
        return Opacity(
          opacity: 0.5 + (opacity * 0.5),
          child: Transform.translate(
            offset: Offset(0, -4 * opacity),
            child: child,
          ),
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
