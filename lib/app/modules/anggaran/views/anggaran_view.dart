import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/data/models/anggaran.dart';
import 'package:your_money/app/modules/anggaran/controllers/anggaran_controller.dart';

class AnggaranView extends StatefulWidget {
  const AnggaranView({super.key});

  @override
  State<AnggaranView> createState() => _AnggaranViewState();
}

class _AnggaranViewState extends State<AnggaranView> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  String? _period; // Jenis Periode

  static const Color _blue = Color(0xFF1E88E5);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _blue, width: 1.2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      _dateCtrl.text = _formatDate(picked);
      setState(() {});
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AnggaranController>()) {
      Get.put(AnggaranController());
    }
    final anggaranCtrl = Get.find<AnggaranController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back<void>(),
        ),
        title:
            const Text('Buat Anggaran', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              final name = _nameCtrl.text.trim();
              final amountStr = _amountCtrl.text.replaceAll('.', '').trim();
              final category = _categoryCtrl.text.trim();
              final period = _period ?? 'Bulanan';
              final dateText = _dateCtrl.text.trim();

              if (name.isEmpty ||
                  amountStr.isEmpty ||
                  category.isEmpty ||
                  dateText.isEmpty) {
                Get.snackbar('Validasi', 'Lengkapi semua field',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }

              final limit = int.tryParse(amountStr) ?? 0;
              if (limit <= 0) {
                Get.snackbar('Validasi', 'Jumlah anggaran tidak valid',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }

              // Parse dd/MM/yyyy
              DateTime? start;
              try {
                final parts = dateText.split('/');
                final d = int.parse(parts[0]);
                final m = int.parse(parts[1]);
                final y = int.parse(parts[2]);
                start = DateTime(y, m, d);
              } catch (_) {}
              if (start == null) {
                Get.snackbar('Validasi', 'Tanggal tidak valid',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }

              DateTime end;
              switch (period) {
                case 'Harian':
                  end = start;
                  break;
                case 'Mingguan':
                  end = start.add(const Duration(days: 6));
                  break;
                default: // Bulanan
                  end = DateTime(start.year, start.month + 1, 0);
              }

              final a = Anggaran.newBudget(
                name: name,
                limit: limit,
                category: category,
                period: period,
                startDate: start,
                endDate: end,
              );

              anggaranCtrl.add(a).then((_) {
                Get.back<void>();
                Get.snackbar('Sukses', 'Anggaran disimpan',
                    snackPosition: SnackPosition.BOTTOM);
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Anggaran Bulanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Batas Anggaran : Rp 0',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 20),
            const Text('Nama Anggaran'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: _inputDecoration('Masukan nama'),
            ),
            const SizedBox(height: 16),
            const Text('Jumlah Anggran'),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Masukan jumlah'),
            ),
            const SizedBox(height: 16),
            const Text('Kategori'),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryCtrl,
              decoration: _inputDecoration('Masukan Kategori'),
            ),
            const SizedBox(height: 16),
            const Text('Jenis Periode'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _period,
              items: const [
                DropdownMenuItem(value: 'Harian', child: Text('Harian')),
                DropdownMenuItem(value: 'Mingguan', child: Text('Mingguan')),
                DropdownMenuItem(value: 'Bulanan', child: Text('Bulanan')),
              ],
              onChanged: (v) => setState(() => _period = v),
              decoration: _inputDecoration('Pilih jenis periode',
                  suffixIcon: const Icon(Icons.arrow_drop_down)),
            ),
            const SizedBox(height: 16),
            const Text('Tanggal Mulai'),
            const SizedBox(height: 8),
            TextField(
              controller: _dateCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: _inputDecoration('Pilih tanggal',
                  suffixIcon: const Icon(Icons.calendar_today_outlined)),
            ),
          ],
        ),
      ),
    );
  }
}
