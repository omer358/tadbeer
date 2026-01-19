import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/data.dart';
import '../../widgets/insight_banner.dart';
import '../expenses/bloc/expenses_bloc.dart';

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

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isSending = false;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isSending) return;

    if (_isRecording) {
      // Stop
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _isSending = true;
      });

      if (path != null && mounted) {
        // Send to bloc
        context.read<ExpensesBloc>().add(AddExpenseByVoice(path, widget.lang));
        // Wait briefly or just close?
        // Ideally we listen to state change, but for MVP we can just close with a delay
        // or let the user see "Sending" then close.
        // Or assume success and close.
        // Let's close after a short delay so user sees "Sending".
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() => _isSending = false);
      }
    } else {
      // Start
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/voice_expense_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: path,
        );
        setState(() => _isRecording = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return AlertDialog(
      title: Text(t(lang, 'addExpense')),
      content: SizedBox(
        width: double.maxFinite,
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
                    child: GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? Colors.red.shade100
                              : (_isSending
                                    ? Colors.grey.shade200
                                    : Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSending)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Icon(
                                _isRecording
                                    ? Icons.stop
                                    : Icons.mic_none_outlined,
                                size: _isRecording ? 24 : 18,
                                color: _isRecording
                                    ? Colors.red
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              _isRecording
                                  ? (lang == 'ar' ? 'تسجيل...' : 'Recording...')
                                  : (_isSending
                                        ? (lang == 'ar'
                                              ? 'جاري الإرسال...'
                                              : 'Sending...')
                                        : t(lang, 'voice')),
                              style: TextStyle(
                                color: _isRecording
                                    ? Colors.red
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                fontWeight: _isRecording
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
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
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              t(lang, 'camera'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
