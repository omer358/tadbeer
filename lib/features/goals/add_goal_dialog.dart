import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/data.dart';

import '../../widgets/insight_banner.dart';

class AddGoalDialog extends StatefulWidget {
  final String lang;
  final double income;
  final double fixed;
  final double variable;

  const AddGoalDialog({
    super.key,
    required this.lang,
    required this.income,
    required this.fixed,
    required this.variable,
  });

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  String type = 'car';
  String name = 'Car';
  int target = 25000;
  int deadlineMonths = 12;
  Map<String, dynamic>? result;

  @override
  void initState() {
    super.initState();
    if (widget.lang == 'ar') name = 'سيارة';
  }

  void check() {
    final free = math.max(0, widget.income - widget.fixed - widget.variable);
    final req = target / math.max(1, deadlineMonths);
    setState(() {
      result = {'free': free, 'req': req, 'feasible': req <= free};
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return AlertDialog(
      title: Text(t(lang, 'addGoal')),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: type,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'النوع' : 'Type',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'car',
                          child: Text(lang == 'ar' ? 'سيارة' : 'Car'),
                        ),
                        DropdownMenuItem(
                          value: 'travel',
                          child: Text(lang == 'ar' ? 'سفر' : 'Travel'),
                        ),
                        DropdownMenuItem(
                          value: 'wedding',
                          child: Text(lang == 'ar' ? 'زواج' : 'Wedding'),
                        ),
                        DropdownMenuItem(
                          value: 'emergency',
                          child: Text(lang == 'ar' ? 'طوارئ' : 'Emergency'),
                        ),
                      ],
                      onChanged: (v) {
                        final val = v ?? type;
                        setState(() {
                          type = val;
                          final map = {
                            'car': lang == 'ar' ? 'سيارة' : 'Car',
                            'travel': lang == 'ar' ? 'سفر' : 'Travel',
                            'wedding': lang == 'ar' ? 'زواج' : 'Wedding',
                            'emergency': lang == 'ar' ? 'طوارئ' : 'Emergency',
                          };
                          name = map[val] ?? name;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: deadlineMonths,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'المدة' : 'Deadline',
                      ),
                      items: const [6, 12, 18, 24]
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(
                                d == 12
                                    ? (lang == 'ar' ? 'سنة' : '1 year')
                                    : (lang == 'ar' ? '$d شهر' : '$d months'),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => deadlineMonths = v ?? deadlineMonths),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: lang == 'ar' ? 'اسم الهدف' : 'Goal name',
                ),
                controller: TextEditingController(text: name),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: lang == 'ar' ? 'المبلغ' : 'Target',
                ),
                controller: TextEditingController(text: target.toString()),
                onChanged: (v) => target = int.tryParse(v) ?? target,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: check,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, size: 18),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              t(lang, 'feasibility'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                          const Icon(Icons.mic_none_outlined, size: 18),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              t(lang, 'voice'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (result != null) ...[
                const SizedBox(height: 12),
                InsightBanner(
                  lang: lang,
                  severity: (result!['feasible'] as bool)
                      ? 'success'
                      : 'warning',
                  title: lang == 'ar' ? 'نتيجة' : 'Result',
                  message: (result!['feasible'] as bool)
                      ? (lang == 'ar'
                            ? 'المطلوب ${fmtSAR((result!['req'] as num).round())} شهرياً، والمتاح ${fmtSAR((result!['free'] as num).round())}.'
                            : 'Need ${fmtSAR((result!['req'] as num).round())}/mo, free ~${fmtSAR((result!['free'] as num).round())}.')
                      : (lang == 'ar'
                            ? 'المطلوب ${fmtSAR((result!['req'] as num).round())} شهرياً أكبر من المتاح ${fmtSAR((result!['free'] as num).round())}.'
                            : 'Required ${fmtSAR((result!['req'] as num).round())}/mo exceeds free ${fmtSAR((result!['free'] as num).round())}.'),
                ),
              ],
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
          onPressed: () => Navigator.of(context).pop({
            'type': type,
            'name': name,
            'target': target,
            'deadlineMonths': deadlineMonths,
          }),
          child: Text(t(lang, 'save')),
        ),
      ],
    );
  }
}
