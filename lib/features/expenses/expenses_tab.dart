import 'package:flutter/material.dart';
import '../../core/data.dart';
import '../../widgets/components.dart';

class ExpensesTab extends StatefulWidget {
  final String lang;
  final List<Map<String, dynamic>> txns;
  final VoidCallback onAddExpense;
  final VoidCallback onImport;

  const ExpensesTab({
    super.key,
    required this.lang,
    required this.txns,
    required this.onAddExpense,
    required this.onImport,
  });

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final scheme = Theme.of(context).colorScheme;

    final filtered = widget.txns.where((x) {
      if (filter == 'all') return true;
      if (filter == 'bnpl') return '${x['category']}' == 'bnpl';
      return '${x['category']}' == filter;
    }).toList();

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t(lang, 'expenses'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: widget.onImport,
                      child: Row(
                        children: [
                          const Icon(Icons.upload_file_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text(t(lang, 'importStatement')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: widget.onAddExpense,
                      child: Row(
                        children: [
                          const Icon(Icons.add, size: 18),
                          const SizedBox(width: 6),
                          Text(t(lang, 'addExpense')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(lang == 'ar' ? 'الكل' : 'All', 'all'),
                    ...categories
                        .where((c) => c.key != 'other')
                        .map((c) => _chip(lang == 'ar' ? c.ar : c.en, c.key)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...filtered.take(12).map((x) {
          final isBnpl = '${x['category']}' == 'bnpl';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${x['description']}',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${catLabel(lang, '${x['category']}')} • ${x['date']}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        fmtSAR(x['amount'] as num? ?? 0),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  if (isBnpl) ...[
                    const SizedBox(height: 10),
                    SoftBadge(
                      lang == 'ar' ? 'تم اكتشاف تقسيط' : 'BNPL detected',
                      bg: Colors.amber.withOpacity(0.18),
                      fg: Colors.amber.shade900,
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = filter == value;
    return InkWell(
      onTap: () => setState(() => filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
