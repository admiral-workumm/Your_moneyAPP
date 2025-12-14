import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/grafik_controller.dart';
import '../widgets/donut_chart.dart';
import '../widgets/small_chip.dart';
import '../widgets/segment.dart';

enum ChartType { pengeluaran, pemasukan, anggaran }

class GrafikView extends StatefulWidget {
  const GrafikView({super.key});

  @override
  State<GrafikView> createState() => _GrafikViewState();
}

class _GrafikViewState extends State<GrafikView> {
  static const _blue = Color(0xFF1E88E5);
  static const _blueDark = Color(0xFF1565C0);

  late final GrafikController controller;

  ChartType chartType = ChartType.pengeluaran;

  final List<_Budget> _budgets = [
    _Budget(
      name: 'Makan Mingguan',
      start: DateTime(2025, 1, 20),
      end: DateTime(2025, 1, 25),
      current: 100000,
      limit: 200000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<GrafikController>()) {
      Get.put(GrafikController());
    }
    controller = Get.find<GrafikController>();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomSpacer = 78 + bottomInset + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Obx(() {
        final segments = chartType == ChartType.pengeluaran
            ? controller.pengeluaranSegments
            : controller.pemasukanSegments;
        final total = chartType == ChartType.pengeluaran
            ? controller.pengeluaranTotal.value
            : controller.pemasukanTotal.value;

        return Column(
          children: [
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
                      Row(
                        children: [
                          IconButton(
                            onPressed: controller.previousMonth,
                            icon: const Icon(Icons.chevron_left,
                                color: Colors.white),
                            splashRadius: 20,
                          ),
                          Text(controller.monthLabel,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          IconButton(
                            onPressed: controller.nextMonth,
                            icon: const Icon(Icons.chevron_right,
                                color: Colors.white),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SmallChip(
                        label: 'Pengeluaran',
                        icon: Icons.shopping_bag_outlined,
                        selected: chartType == ChartType.pengeluaran,
                        onTap: () => setState(() {
                          chartType = ChartType.pengeluaran;
                        }),
                      ),
                      const SizedBox(width: 8),
                      SmallChip(
                        label: 'Pemasukan',
                        icon: Icons.savings,
                        selected: chartType == ChartType.pemasukan,
                        onTap: () => setState(() {
                          chartType = ChartType.pemasukan;
                        }),
                      ),
                      const SizedBox(width: 8),
                      SmallChip(
                        label: 'Anggaran',
                        icon: Icons.book,
                        selected: chartType == ChartType.anggaran,
                        onTap: () => setState(() {
                          chartType = ChartType.anggaran;
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 20, 16, bottomSpacer),
                child: Column(
                  children: [
                    if (chartType != ChartType.anggaran) ...[
                      if (segments.isEmpty)
                        _EmptyState(
                          label:
                              'Belum ada ${chartType == ChartType.pengeluaran ? 'pengeluaran' : 'pemasukan'} di ${controller.monthLabel}',
                        )
                      else ...[
                        DonutChart(
                          segments: segments,
                          width: 320,
                          height: 220,
                          centerBuilder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                chartType == ChartType.pengeluaran
                                    ? 'Pengeluaran'
                                    : 'Pemasukan',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(_totalLabel(total),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
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
                      ],
                    ] else ...[
                      Column(
                        children: _budgets
                            .map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _BudgetCard(budget: b),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _amountFor(Segment s) => controller.formatRupiah(s.nominal);

  String _totalLabel(int total) => controller.formatRupiah(total);
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

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insert_chart_outlined,
                color: Color(0xFF1E88E5)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF3A3A3A))),
          ),
        ],
      ),
    );
  }
}

// Budget model
class _Budget {
  final String name;
  final DateTime start;
  final DateTime end;
  final int current;
  final int limit;
  const _Budget({
    required this.name,
    required this.start,
    required this.end,
    required this.current,
    required this.limit,
  });
  double get progress => limit == 0 ? 0 : current / limit;
}

// Budget card widget
class _BudgetCard extends StatelessWidget {
  final _Budget budget;
  static const _blue = Color(0xFF0D6EFF);
  const _BudgetCard({required this.budget});

  String _fmt(int v) => v
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  String _dateFmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / ${d.year}'; // sesuai contoh screenshot

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(budget.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              Column(
                children: const [
                  Icon(Icons.notifications_active_outlined, color: _blue),
                  SizedBox(height: 4),
                  Text('Anggaran',
                      style: TextStyle(
                          color: _blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: _blue),
              const SizedBox(width: 8),
              Text('${_dateFmt(budget.start)} ~ ${_dateFmt(budget.end)}',
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final pct = budget.progress.clamp(0, 1);
              final barWidth = c.maxWidth;
              final filled = barWidth * pct;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      height: 26,
                      width: filled,
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text('Rp ${_fmt(budget.current)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${(pct * 100).round()}%',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        Text('Rp ${_fmt(budget.limit)}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
