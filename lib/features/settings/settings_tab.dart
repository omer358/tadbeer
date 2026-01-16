import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/data.dart';
import '../../widgets/components.dart';
import '../settings/bloc/settings_bloc.dart';
import '../common/statement_upload_dialog.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final lang = state.locale.languageCode;
        final dark = state.themeMode == ThemeMode.dark;
        final scheme = Theme.of(context).colorScheme;

        return ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t(lang, 'settings'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lang == 'ar'
                          ? 'تحكم بالخصوصية والمظهر.'
                          : 'Control privacy and appearance.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            dark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t(lang, 'theme'),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      dark ? t(lang, 'dark') : t(lang, 'light'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: dark,
                      onChanged: (_) =>
                          context.read<SettingsBloc>().add(ToggleTheme()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.language_outlined,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t(lang, 'language'),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () =>
                          context.read<SettingsBloc>().add(ToggleLanguage()),
                      child: Text(
                        lang == 'ar' ? t('ar', 'english') : t('en', 'arabic'),
                      ),
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
                      icon: const Icon(Icons.upload_file_outlined, size: 18),
                      title: t(lang, 'importStatement'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lang == 'ar'
                          ? 'ارفع CSV أو PDF لتحليل مصروفاتك.'
                          : 'Upload CSV or PDF to analyze spending.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () => _openStatement(context, lang),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upload_file_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(t(lang, 'upload')),
                        ],
                      ),
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
                      icon: const Icon(Icons.shield_outlined, size: 18),
                      title: t(lang, 'privacy'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonal(
                      onPressed: () {},
                      child: Text(
                        lang == 'ar' ? 'تصدير البيانات' : 'Export data',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete_outline, size: 18),
                          const SizedBox(width: 8),
                          Text(t(lang, 'deleteAccount')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_outlined),
              label: Text(t(lang, 'logout')),
            ),
            const SizedBox(height: 10),
            Text(
              lang == 'ar'
                  ? 'ملاحظة: هذا نموذج UX للعرض في الهاكاثون (بدون اتصال حقيقي بالبنوك).'
                  : 'Note: This is a hackathon UX prototype (no real bank connectivity).',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openStatement(BuildContext context, String lang) async {
    await showDialog(
      context: context,
      builder: (_) => StatementUploadDialog(lang: lang),
    );
  }
}
