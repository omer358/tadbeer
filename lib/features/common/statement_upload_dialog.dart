import 'package:flutter/material.dart';
import '../../core/data.dart';
import '../../widgets/insight_banner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../expenses/bloc/expenses_bloc.dart';
import '../dashboard/bloc/dashboard_bloc.dart';

class StatementUploadDialog extends StatefulWidget {
  final String lang;
  const StatementUploadDialog({super.key, required this.lang});

  @override
  State<StatementUploadDialog> createState() => _StatementUploadDialogState();
}

class _StatementUploadDialogState extends State<StatementUploadDialog> {
  String? filePath;
  String? fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        filePath = result.files.single.path;
        fileName = result.files.single.name;
      });
    }
  }

  void _upload() {
    if (filePath != null) {
      context.read<ExpensesBloc>().add(UploadStatement(filePath!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final scheme = Theme.of(context).colorScheme;

    return BlocConsumer<ExpensesBloc, ExpensesState>(
      listenWhen: (previous, current) =>
          previous.uploadStatus != current.uploadStatus,
      listener: (context, state) {
        if (state.uploadStatus == UploadStatus.success) {
          context.read<DashboardBloc>().add(LoadDashboard(widget.lang));
        } else if (state.uploadStatus == UploadStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.uploadMessage ?? "Unknown"}'),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.uploadStatus == UploadStatus.loading;
        final isSuccess = state.uploadStatus == UploadStatus.success;

        if (isSuccess) {
          return AlertDialog(
            title: Text(t(lang, 'success')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(state.uploadMessage ?? 'File uploaded successfully!'),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t(lang, 'done')),
              ),
            ],
          );
        }

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
                          lang == 'ar'
                              ? 'اسحب الملف هنا'
                              : 'Sort your expenses',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang == 'ar' ? 'PDF فقط' : 'PDF only',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        if (isLoading)
                          const CircularProgressIndicator()
                        else
                          FilledButton.tonal(
                            onPressed: _pickFile,
                            child: Text(
                              lang == 'ar' ? 'اختيار ملف' : 'Choose PDF',
                            ),
                          ),
                        if (fileName != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            fileName!,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton(
              onPressed: (filePath != null && !isLoading) ? _upload : null,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(lang == 'ar' ? 'رفع' : 'Upload'),
            ),
          ],
        );
      },
    );
  }
}
