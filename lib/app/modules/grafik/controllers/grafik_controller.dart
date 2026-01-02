import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/data/models/transaksi.dart';
import 'package:your_money/app/data/services/transaksi_service.dart';
import 'package:your_money/app/modules/grafik/widgets/segment.dart';

class GrafikController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final pemasukanTotal = 0.obs;
  final pengeluaranTotal = 0.obs;
  final pemasukanSegments = <Segment>[].obs;
  final pengeluaranSegments = <Segment>[].obs;

  final _service = TransaksiService();

  static const List<Color> _palette = [
    Color(0xFF0D6EFF),
    Color(0xFF1565C0),
    Color(0xFF64B5F6),
    Color(0xFF90CAF9),
    Color(0xFF42A5F5),
    Color(0xFF81D4FA),
  ];

  @override
  void onInit() {
    super.onInit();
    _load();
    ever<DateTime>(selectedDate, (_) => _load());
  }

  void previousMonth() {
    selectedDate.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month - 1,
    );
  }

  void nextMonth() {
    selectedDate.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month + 1,
    );
  }

  void refreshData() => _load();

  String get monthLabel => _formatMonth(selectedDate.value);

  String formatRupiah(int value) {
    final raw = value.abs().toString();
    final formatted = raw.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    final prefix = value < 0 ? '- ' : '';
    return 'Rp ${prefix.isEmpty ? '' : prefix}$formatted';
  }

  void _load() {
    final transaksi = _service.getTransaksiByMonth(selectedDate.value);

    final pemasukan = transaksi.where((t) => t.tipe == 'pemasukan').toList();
    final pengeluaran =
        transaksi.where((t) => t.tipe == 'pengeluaran').toList();

    pemasukanTotal.value =
        pemasukan.fold<int>(0, (sum, t) => sum + _parseJumlah(t.jumlah));
    pengeluaranTotal.value =
        pengeluaran.fold<int>(0, (sum, t) => sum + _parseJumlah(t.jumlah));

    pemasukanSegments.assignAll(_buildSegments(pemasukan));
    pengeluaranSegments.assignAll(_buildSegments(pengeluaran));
  }

  List<Segment> _buildSegments(List<Transaksi> list) {
    if (list.isEmpty) return [];

    final grouped = <String, int>{};
    for (final t in list) {
      grouped[t.kategori] = (grouped[t.kategori] ?? 0) + _parseJumlah(t.jumlah);
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    if (total <= 0) return [];

    final percents = <int>[];
    var sumPct = 0;
    for (final e in entries) {
      final pct = ((e.value / total) * 100).floor();
      percents.add(pct);
      sumPct += pct;
    }

    var diff = 100 - sumPct;
    var i = 0;
    while (diff > 0 && percents.isNotEmpty) {
      percents[i % percents.length] += 1;
      diff--;
      i++;
    }

    final segments = <Segment>[];
    for (var idx = 0; idx < entries.length; idx++) {
      final percent = percents[idx];
      if (percent <= 0) continue;
      segments.add(
        Segment(
          name: entries[idx].key.isEmpty ? 'Lainnya' : entries[idx].key,
          percent: percent,
          color: _palette[idx % _palette.length],
          nominal: entries[idx].value,
        ),
      );
    }
    return segments;
  }

  int _parseJumlah(String raw) {
    return int.tryParse(raw.replaceAll('.', '')) ?? 0;
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
