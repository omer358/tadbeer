import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/data.dart';

class DonutChart extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const DonutChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.fold<num>(0, (a, b) => a + ((b['value'] as num?) ?? 0));
    return LayoutBuilder(
      builder: (context, c) {
        return CustomPaint(
          painter: _DonutPainter(
            items: items,
            total: total <= 0 ? 1 : total,
            scheme: Theme.of(context).colorScheme,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  fmtSAR(total),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  final num total;
  final ColorScheme scheme;

  _DonutPainter({
    required this.items,
    required this.total,
    required this.scheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.38;
    final stroke = r * 0.36;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = scheme.surfaceContainerHighest;

    canvas.drawCircle(center, r, basePaint);

    final colors = <Color>[
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      Colors.amber,
      Colors.green,
      Colors.pinkAccent,
      Colors.cyan,
    ];

    double start = -math.pi / 2;
    for (int i = 0; i < items.length; i++) {
      final v = (items[i]['value'] as num?) ?? 0;
      if (v <= 0) continue;
      final sweep = (v / total) * (2 * math.pi);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        start,
        sweep.toDouble(),
        false,
        paint,
      );
      start += sweep.toDouble();
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.total != total ||
        oldDelegate.scheme != scheme;
  }
}

class MiniLineChart extends StatelessWidget {
  final List<Map<String, num>> data;
  const MiniLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinePainter(data: data, scheme: Theme.of(context).colorScheme),
      child: const SizedBox.expand(),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<Map<String, num>> data;
  final ColorScheme scheme;

  _LinePainter({required this.data, required this.scheme});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final pad = 10.0;
    final w = size.width;
    final h = size.height;

    double minX = data.first['day']!.toDouble();
    double maxX = data.last['day']!.toDouble();
    double maxY = 1;

    for (final p in data) {
      maxY = math.max(
        maxY,
        math.max(p['spent']!.toDouble(), p['expected']!.toDouble()),
      );
    }

    Offset mapPoint(double x, double y) {
      final nx = (x - minX) / math.max(1e-9, (maxX - minX));
      final ny = 1 - (y / math.max(1e-9, maxY));
      return Offset(pad + nx * (w - 2 * pad), pad + ny * (h - 2 * pad));
    }

    // grid
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = scheme.outlineVariant.withOpacity(0.6);

    final rows = 4;
    for (int i = 0; i <= rows; i++) {
      final y = pad + (h - 2 * pad) * (i / rows);
      canvas.drawLine(Offset(pad, y), Offset(w - pad, y), grid);
    }

    Path lineFor(String key) {
      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final x = data[i]['day']!.toDouble();
        final y = data[i][key]!.toDouble();
        final pt = mapPoint(x, y);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      return path;
    }

    final expectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = scheme.tertiary;

    final spentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = scheme.primary;

    canvas.drawPath(lineFor('expected'), expectedPaint);
    canvas.drawPath(lineFor('spent'), spentPaint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.scheme != scheme;
  }
}
