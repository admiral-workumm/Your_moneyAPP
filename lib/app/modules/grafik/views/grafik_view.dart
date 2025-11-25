import 'package:flutter/material.dart';
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

  // sample data (percent sum should be 100)
  final List<Segment> expenseSegments = const [
    Segment(name: 'Makanan', percent: 50, color: Color(0xFF0D6EFF)),
    Segment(name: 'Hiburan', percent: 32, color: Color(0xFF64B5F6)),
    Segment(name: 'Minuman', percent: 18, color: Color(0xFF90CAF9)),
  ];
  final List<Segment> incomeSegments = const [
    // gunakan palette biru juga agar konsisten
    Segment(name: 'Gaji', percent: 70, color: Color(0xFF0D6EFF)),
    Segment(name: 'Bonus', percent: 20, color: Color(0xFF64B5F6)),
    Segment(name: 'Investasi', percent: 10, color: Color(0xFF90CAF9)),
  ];
  ChartType chartType = ChartType.pengeluaran;
  List<Segment> get _segments =>
      chartType == ChartType.pengeluaran ? expenseSegments : incomeSegments;

  // sample anggaran data
  final List<_Budget> _budgets = [
    _Budget(
      name: 'Makan Mingguan',
      start: DateTime(2025, 1, 20),
      end: DateTime(2025, 1, 25),
      current: 100000,
      limit: 200000,
    ),
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

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 20, 16, bottomSpacer),
              child: Column(
                children: [
                  if (chartType != ChartType.anggaran) ...[
                    // donut chart with labels
                    DonutChart(
                      segments: _segments,
                      width: 320,
                      height: 220,
                      centerBuilder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            chartType == ChartType.pengeluaran
                                ? 'Pengeluaran'
                                : 'Pemasukan',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(_totalLabel(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                        ],
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
                        children: _segments
                            .map((s) => Column(
                                  children: [
                                    _CategoryRow(
                                        name: s.name,
                                        percent: '${s.percent}%',
                                        amount: _amountFor(s)),
                                    if (s != _segments.last)
                                      const Divider(height: 0),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ] else ...[
                    // anggaran cards list
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
      ),
    );
  }

  String _amountFor(Segment s) {
    final total = chartType == ChartType.pengeluaran ? 300000 : 500000;
    final a = (total * s.percent / 100).round();
    final formatted = a
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
    return 'Rp$formatted';
  }

  String _totalLabel() {
    final total = chartType == ChartType.pengeluaran ? 300000 : 500000;
    final formatted = total
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
    return 'Rp $formatted';
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
