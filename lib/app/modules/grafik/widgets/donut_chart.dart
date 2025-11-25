import 'dart:math' as math;
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

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

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

      // percent text
      final pDx = center.dx + centerRadius * math.cos(mid);
      final pDy = center.dy + centerRadius * math.sin(mid);
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

      // name label outside
      final tn = TextPainter(
        text: TextSpan(
            text: s.name,
            style: const TextStyle(fontSize: 13, color: Colors.black)),
        textDirection: TextDirection.ltr,
      )..layout();
      final nameRadius = arcOuter + 40.0;
      final nDx = center.dx + nameRadius * math.cos(mid);
      final nDy = center.dy + nameRadius * math.sin(mid);
      final onRight = math.cos(mid) >= 0;
      final arcPoint = Offset(center.dx + arcOuter * math.cos(mid),
          center.dy + arcOuter * math.sin(mid));
      double nX;
      if (onRight) {
        final ideal = nDx + 6;
        final overflow = ideal + tn.width + 4 > size.width;
        nX = overflow ? (arcPoint.dx + 20) : ideal;
      } else {
        nX = nDx - tn.width - 6;
      }
      double nY = nDy - tn.height / 2;
      nY = nY.clamp(4.0, size.height - tn.height - 4.0);

      final labelAttach = onRight
          ? Offset(nX - 6, nY + tn.height / 2)
          : Offset(nX + tn.width + 6, nY + tn.height / 2);
      final linePaint = Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      final midPoint = Offset(
        arcPoint.dx + (labelAttach.dx - arcPoint.dx) * 0.35,
        arcPoint.dy + (labelAttach.dy - arcPoint.dy) * 0.35,
      );
      canvas.drawLine(arcPoint, midPoint, linePaint);
      canvas.drawLine(midPoint, labelAttach, linePaint);

      tn.paint(canvas, Offset(nX, nY));

      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
