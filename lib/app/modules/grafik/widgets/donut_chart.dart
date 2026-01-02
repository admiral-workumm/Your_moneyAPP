import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'segment.dart';

class DonutChart extends StatelessWidget {
  final List<Segment> segments;
  final double width;
  final double height;
  final WidgetBuilder centerBuilder;
  final double strokeWidth;
  const DonutChart({
    super.key,
    required this.segments,
    required this.width,
    required this.height,
    required this.centerBuilder,
    this.strokeWidth = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 20, // extra for labels outside
      child: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: _DonutPainter(segments: segments, stroke: strokeWidth),
              ),
              // inner hole cover
              Builder(builder: (ctx) {
                final paintSize = math.min(width, height);
                final radius = paintSize / 2;
                final arcInner =
                    radius - strokeWidth; // inner edge of painted ring
                final innerDiameter =
                    ((arcInner + 2.0) * 2).clamp(0.0, paintSize);
                return Container(
                  width: innerDiameter,
                  height: innerDiameter,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: centerBuilder(ctx),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Segment> segments;
  final double stroke;
  const _DonutPainter({required this.segments, required this.stroke});

  IconData _iconForName(String name) {
    switch (name.toLowerCase()) {
      case 'makan':
        return Icons.restaurant;
      case 'hiburan':
        return Icons.sports_esports;
      case 'transportasi':
        return Icons.directions_bus;
      case 'belanja':
        return Icons.shopping_bag;
      case 'komunikasi':
        return Icons.smartphone;
      case 'kesehatan':
        return Icons.medical_services;
      case 'pendidikan':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'keluarga':
        return Icons.groups;
      case 'lainnya':
        return Icons.category;
      default:
        return Icons.category;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    final singleSegment = segments.length == 1;

    double start = -math.pi / 2; // start from top
    for (final s in segments) {
      final sweep = s.fraction * 2 * math.pi;
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - stroke / 2),
        start,
        sweep,
        false,
        paint,
      );

      final mid = start + sweep / 2;
      final centerRadius = radius - stroke / 2;
      final arcOuter = radius;

      if (singleSegment) {
        start += sweep;
        continue;
      }

      // percent text at radial middle of ring
      final percentRadius = radius - stroke * 0.5;
      final pDx = center.dx + percentRadius * math.cos(mid);
      final pDy = center.dy + percentRadius * math.sin(mid);
      final tp = TextPainter(
        text: TextSpan(
          text: '${s.percent}%',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(0, 1))
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pDx - tp.width / 2, pDy - tp.height / 2));

      // category icon badge outside (styled circle with border & shadow)
      // Move badge closer to the outer ring
      final nameRadius = arcOuter + 18.0;
      final bCx = center.dx + nameRadius * math.cos(mid);
      final bCy = center.dy + nameRadius * math.sin(mid);
      const badgeRadius = 16.0; // 32px diameter

      // Shadow under badge
      final shadowPaint = Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.fill
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 4);
      canvas.drawCircle(Offset(bCx, bCy + 2), badgeRadius, shadowPaint);

      // White badge fill
      final fillPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bCx, bCy), badgeRadius, fillPaint);

      // Colored border using segment color
      final borderPaint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(bCx, bCy), badgeRadius, borderPaint);

      // Icon inside badge
      final icon = _iconForName(s.name);
      const iconSize = 18.0;
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: s.color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      iconPainter.paint(
        canvas,
        Offset(bCx - iconPainter.width / 2, bCy - iconPainter.height / 2),
      );

      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
