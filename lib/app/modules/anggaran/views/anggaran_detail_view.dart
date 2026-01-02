import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/data/models/anggaran.dart';

class AnggaranDetailView extends StatelessWidget {
  const AnggaranDetailView({super.key});

  String _fmtRupiah(int value) {
    final formatted = value
        .abs()
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
    return value < 0 ? '-$formatted' : formatted;
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final day = d.day.toString().padLeft(2, '0');
    final month = months[d.month - 1];
    return '$day $month ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final Anggaran? anggaran = args?['anggaran'] as Anggaran?;
    final int current = args?['current'] as int? ?? 0;

    if (anggaran == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Anggaran'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: Get.back,
          ),
        ),
        body: const Center(child: Text('Data anggaran tidak tersedia')),
      );
    }

    final int remaining = anggaran.limit - current;
    final double pct = anggaran.limit == 0 ? 0 : current / anggaran.limit;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        title: const Text('Detail Anggaran',
            style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anggaran.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(anggaran.category,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          anggaran.period,
                          style: const TextStyle(
                              color: Color(0xFF1E88E5),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: Color(0xFF1E88E5)),
                      const SizedBox(width: 8),
                      Text(
                        '${_fmtDate(anggaran.startDate)} - ${_fmtDate(anggaran.endDate)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progres',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      minHeight: 16,
                      value: pct.clamp(0, 1),
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pct >= 1
                            ? Colors.red.shade400
                            : const Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Terpakai: Rp ${_fmtRupiah(current)}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('${(pct * 100).round()}%',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: pct >= 1
                                  ? Colors.red.shade400
                                  : const Color(0xFF1E88E5))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  _InfoRow(
                      label: 'Batas Anggaran',
                      value: 'Rp ${_fmtRupiah(anggaran.limit)}'),
                  const Divider(height: 24),
                  _InfoRow(
                      label: 'Sudah Dipakai',
                      value: 'Rp ${_fmtRupiah(current)}'),
                  const Divider(height: 24),
                  _InfoRow(
                    label: remaining >= 0 ? 'Sisa Anggaran' : 'Melebihi Batas',
                    value: 'Rp ${_fmtRupiah(remaining.abs())}',
                    valueColor: remaining < 0 ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
