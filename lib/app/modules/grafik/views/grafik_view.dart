import 'dart:math' as math;

import 'package:flutter/material.dart';

class GrafikView extends StatefulWidget {
  const GrafikView({super.key});

  @override
  State<GrafikView> createState() => _GrafikViewState();
}

class _GrafikViewState extends State<GrafikView> {
  static const _blue = Color(0xFF1E88E5);
  static const _blueDark = Color(0xFF1565C0);

  // sample data (percent sum should be 100)
  final List<_Segment> segments = const [
    _Segment(name: 'Makanan', percent: 50, color: Color(0xFF0D6EFF)),
    _Segment(name: 'Hiburan', percent: 32, color: Color(0xFF64B5F6)),
    _Segment(name: 'Minuman', percent: 18, color: Color(0xFF90CAF9)),
  ];

  int month = 10;
  int year = 2025;

  void _prevMonth() {
    setState(() {
      month -= 1;
      if (month < 1) {
        month = 12;
        year -= 1;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      month += 1;
      if (month > 12) {
        month = 1;
        year += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomSpacer = 78 + bottomInset + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          // HEADER with month selector
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 12, 16, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_blue, _blueDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 4),
                    const Text('Analisis',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    // month selector
                    Row(
                      children: [
                        IconButton(
                          onPressed: _prevMonth,
                          icon: const Icon(Icons.chevron_left,
                              color: Colors.white),
                          splashRadius: 20,
                        ),
                        Text('$month / $year',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(Icons.chevron_right,
                              color: Colors.white),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // small chips row
                Row(
                  children: const [
                    _SmallChip(
                        label: 'Pengeluaran',
                        icon: Icons.shopping_bag_outlined),
                    SizedBox(width: 8),
                    _SmallChip(label: 'Pemasukan', icon: Icons.savings),
                    SizedBox(width: 8),
                    _SmallChip(label: 'Buku', icon: Icons.book),
                  ],
                ),
              ],
            ),
          ),

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 20, 16, bottomSpacer),
              child: Column(
                children: [
                  // donut chart with labels
                  SizedBox(
                    height: 240,
                    child: Center(
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(220, 220),
                              painter: _DonutPainter(segments: segments),
                            ),
                            // inner white circle sized to match the painted donut hole
                            Builder(builder: (ctx) {
                              const double paintSize = 220.0;
                              const double stroke = 36.0;
                              final double radius = paintSize / 2;
                              // outer arc center = radius - stroke/2; inner radius = outer - stroke
                              // correct geometry:
                              // drawArc used center radius = R - stroke/2, so
                              // innermost arc edge = R - stroke
                              final double arcInner = radius - stroke;
                              // expand a couple pixels to ensure the center is fully white (covers anti-aliased gap)
                              final double innerDiameter =
                                  ((arcInner + 2.0) * 2).clamp(0.0, paintSize);
                              return Container(
                                width: innerDiameter,
                                height: innerDiameter,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text('Pengeluaran',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 6),
                                    Text('Rp 300,000',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // list of categories
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      children: segments
                          .map((s) => Column(
                                children: [
                                  _CategoryRow(
                                      name: s.name,
                                      percent: '${s.percent}%',
                                      amount: _amountFor(s)),
                                  if (s != segments.last)
                                    const Divider(height: 0),
                                ],
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _amountFor(_Segment s) {
    // fake amounts corresponding to percent (for demo)
    final total = 300000;
    final a = (total * s.percent / 100).round();
    final formatted = a
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
    return 'Rp$formatted';
  }
}

class _Segment {
  final String name;
  final int percent;
  final Color color;
  const _Segment(
      {required this.name, required this.percent, required this.color});

  double get fraction => percent / 100.0;
}

class _DonutPainter extends CustomPainter {
  final List<_Segment> segments;
  const _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;
    final stroke = 36.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    double start = -math.pi / 2; // top
    for (final s in segments) {
      final sweep = s.fraction * 2 * math.pi;
      paint.shader = null;
      paint.color = s.color;
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - stroke / 2),
          start,
          sweep,
          false,
          paint);

      // percent text inside ring (center of stroke)
      final mid = start + sweep / 2;
      // compute correct ring geometry
      final centerRadius = radius - stroke / 2; // where arc is centered
      final arcOuter = radius; // outermost edge of arc
      final pctRadius =
          centerRadius; // middle of the ring (where percent should sit)
      final pDx = center.dx + pctRadius * math.cos(mid);
      final pDy = center.dy + pctRadius * math.sin(mid);
      final percentText = TextSpan(
        text: '${s.percent}%',
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(0, 1))
            ]),
      );
      final tp =
          TextPainter(text: percentText, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(pDx - tp.width / 2, pDy - tp.height / 2));

      // name label outside the ring (aligned left/right per side) with a short leader line
      final nameText = TextSpan(
          text: s.name,
          style: const TextStyle(fontSize: 13, color: Colors.black));
      final tn = TextPainter(text: nameText, textDirection: TextDirection.ltr);
      tn.layout();

      final nameRadius = arcOuter +
          40.0; // distance from center for the name (moved further out)
      final nDx = center.dx + nameRadius * math.cos(mid);
      final nDy = center.dy + nameRadius * math.sin(mid);

      // determine side and compute anchor so text doesn't overlap the arc
      final bool onRight = math.cos(mid) >= 0;
      double nX;
      if (onRight) {
        nX = nDx + 6; // small gap from radial line
      } else {
        nX = nDx - tn.width - 6; // align text to the left of the radial line
      }
      double nY = nDy - tn.height / 2;

      // clamp to canvas bounds
      nX = nX.clamp(4.0, size.width - tn.width - 4.0);
      nY = nY.clamp(4.0, size.height - tn.height - 4.0);

      // leader line from arc outer to a point near the text
      final arcPoint = Offset(center.dx + arcOuter * math.cos(mid),
          center.dy + arcOuter * math.sin(mid));
      final labelAttach = onRight
          ? Offset(nX - 6, nY + tn.height / 2)
          : Offset(nX + tn.width + 6, nY + tn.height / 2);
      final linePaint = Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      // draw a short straight line then a horizontal cap to the text
      // midPoint closer to the arc to make the leader line subtle but visible
      final midPoint = Offset(
          arcPoint.dx + (labelAttach.dx - arcPoint.dx) * 0.35,
          arcPoint.dy + (labelAttach.dy - arcPoint.dy) * 0.35);
      canvas.drawLine(arcPoint, midPoint, linePaint);
      canvas.drawLine(midPoint, labelAttach, linePaint);

      // paint the name
      tn.paint(canvas, Offset(nX, nY));

      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SmallChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SmallChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final String percent;
  final String amount;
  const _CategoryRow(
      {required this.name, required this.percent, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
          Text(percent, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 20),
          Text(amount,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
