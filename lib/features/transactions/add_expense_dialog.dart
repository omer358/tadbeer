import 'package:flutter/material.dart';
import '../../core/data.dart';
import '../../widgets/insight_banner.dart';

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
