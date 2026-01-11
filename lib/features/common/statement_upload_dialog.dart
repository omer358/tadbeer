import 'package:flutter/material.dart';
import '../../core/data.dart';
import '../../widgets/insight_banner.dart';

class StatementUploadDialog extends StatefulWidget {
  final String lang;
  const StatementUploadDialog({super.key, required this.lang});

  @override
  State<StatementUploadDialog> createState() => _StatementUploadDialogState();
}

class _StatementUploadDialogState extends State<StatementUploadDialog> {
  String fileName = '';
  String notes = '';

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(t(lang, 'importStatement')),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: scheme.outlineVariant,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 28,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lang == 'ar' ? 'اسحب الملف هنا' : 'Drag & drop file here',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lang == 'ar'
                          ? 'CSV أو PDF (للعرض فقط)'
                          : 'CSV or PDF (prototype only)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonal(
                      onPressed: () =>
                          setState(() => fileName = 'statement_jan.csv'),
                      child: Text(lang == 'ar' ? 'اختيار ملف' : 'Choose file'),
                    ),
                    if (fileName.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        fileName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: lang == 'ar'
                      ? 'ملاحظات (اختياري)'
                      : 'Notes (optional)',
                ),
                minLines: 2,
                maxLines: 4,
                onChanged: (v) => notes = v,
              ),
              const SizedBox(height: 12),
              InsightBanner(
                lang: lang,
                severity: 'info',
                title: lang == 'ar'
                    ? 'ماذا يحدث بعد الرفع؟'
                    : 'What happens after upload?',
                message: lang == 'ar'
                    ? 'نستخرج العمليات، نصنفها، ونبني لك لوحة وتحليلات.'
                    : 'We extract transactions, categorize them, and generate insights.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t(lang, 'done')),
        ),
      ],
    );
  }
}
