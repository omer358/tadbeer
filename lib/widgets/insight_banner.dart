import 'package:flutter/material.dart';
import '../core/data.dart';
import 'components.dart';

class InsightBanner extends StatelessWidget {
  final String lang;
  final String title;
  final String message;
  final String severity; // warning|success|info
  final VoidCallback? onDetails;

  const InsightBanner({
    super.key,
    required this.lang,
    required this.title,
    required this.message,
    this.severity = 'warning',
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWarn = severity == 'warning';
    final isOk = severity == 'success';

    Color iconColor = isWarn
        ? Colors.amber.shade700
        : isOk
        ? Colors.green.shade600
        : Colors.lightBlue.shade600;
    IconData icon = isWarn
        ? Icons.warning_amber_rounded
        : isOk
        ? Icons.check_circle_outline
        : Icons.auto_awesome;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SoftBadge(
                        t(lang, 'insight'),
                        bg: scheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (onDetails != null)
              TextButton(onPressed: onDetails, child: Text(t(lang, 'details'))),
          ],
        ),
      ),
    );
  }
}
