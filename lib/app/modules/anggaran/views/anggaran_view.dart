import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:your_money/app/data/models/anggaran.dart';
import 'package:your_money/app/data/categories.dart';
import 'package:your_money/app/modules/anggaran/controllers/anggaran_controller.dart';

/// Custom formatter untuk input currency dengan format Rp dan titik pemisah ribuan
/// Contoh: 10000 -> "10.000"
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika input kosong, return kosong
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hapus semua karakter non-digit
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Jika tidak ada digit, return kosong
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(
          text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    // Format dengan titik pemisah ribuan
    final formatted = _formatCurrency(digitsOnly);

    // Hitung posisi cursor yang tepat
    // Jika user menghapus karakter, posisi cursor dari belakang
    // Jika user menambah karakter, posisi cursor mengikuti
    int newCursorPos = formatted.length;

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Format string angka dengan titik pemisah ribuan
  /// Contoh: "10000" -> "10.000"
  String _formatCurrency(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    final length = digits.length;

    for (int i = 0; i < length; i++) {
      // Tambah titik setiap 3 digit dari belakang (kecuali di awal)
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }
}

class AnggaranView extends StatefulWidget {
  const AnggaranView({super.key});

  @override
  State<AnggaranView> createState() => _AnggaranViewState();
}

class _AnggaranViewState extends State<AnggaranView> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  String? _selectedCategory;
  final _dateCtrl = TextEditingController();

  String? _period; // Jenis Periode

  bool _nameError = false;
  bool _amountError = false;
  bool _categoryError = false;
  bool _dateError = false;

  String _displayAmount = '0'; // Track displayed amount

  static const Color _blue = Color(0xFF1E88E5);
  static const List<String> _periodOptions = [
    'Harian',
    'Mingguan',
    'Bulanan',
    'Tahunan'
  ];

  @override
  void initState() {
    super.initState();
    // Add listener to update display amount when user types
    _amountCtrl.addListener(_updateDisplayAmount);
  }

  void _updateDisplayAmount() {
    setState(() {
      // Get digits only from formatted text
      final digitsOnly = _amountCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
      _displayAmount = digitsOnly.isEmpty ? '0' : digitsOnly;
    });
  }

  String _formatDisplayAmount(String amount) {
    if (amount == '0' || amount.isEmpty) return '0';

    final buffer = StringBuffer();
    final length = amount.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(amount[i]);
    }

    return buffer.toString();
  }

  @override
  void dispose() {
    _amountCtrl.removeListener(_updateDisplayAmount);
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint,
      {Widget? suffixIcon, Widget? prefixIcon, bool isError = false}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: isError ? Colors.red.shade400 : Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: isError ? Colors.red.shade600 : _blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    // Theme builder untuk customize date picker dengan warna biru
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      // Customize theme dengan warna biru
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _blue, // Warna header & selected date
              onPrimary: Colors.white, // Text di header
              surface: Colors.white, // Background
              onSurface: Colors.black87, // Text umum
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _blue, // Warna text button (OK, CANCEL)
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _dateCtrl.text = _formatDate(picked);
      setState(() {});
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  /// Get icon untuk kategori tertentu
  IconData _getIconForCategory(String categoryLabel) {
    try {
      final category = kDefaultCategories.firstWhere(
        (c) => c.label == categoryLabel,
        orElse: () => kDefaultCategories.last,
      );
      return category.icon;
    } catch (_) {
      return Icons.category;
    }
  }

  /// Show center modal untuk pilih kategori
  Future<void> _showCategoryModal() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Kategori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: kDefaultCategories.length,
                  itemBuilder: (context, index) {
                    final category = kDefaultCategories[index];
                    final isSelected = _selectedCategory == category.label;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      leading: Icon(
                        category.icon,
                        color: _blue,
                        size: 24,
                      ),
                      title: Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? _blue : Colors.black87,
                        ),
                      ),
                      onTap: () {
                        setState(() => _selectedCategory = category.label);
                        Navigator.pop(context);
                      },
                      hoverColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show center modal untuk pilih jenis periode
  Future<void> _showPeriodModal() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Jenis Periode',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _periodOptions.length,
                itemBuilder: (context, index) {
                  final period = _periodOptions[index];
                  final isSelected = _period == period;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      period,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? _blue : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: _blue,
                            size: 24,
                          )
                        : null,
                    onTap: () {
                      setState(() => _period = period);
                      Navigator.pop(context);
                    },
                    hoverColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AnggaranController>()) {
      Get.put(AnggaranController());
    }
    final anggaranCtrl = Get.find<AnggaranController>();
    return Scaffold(
      backgroundColor: Colors.white,
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
              try {
                final name = _nameCtrl.text.trim();
                final amountStr = _amountCtrl.text.replaceAll('.', '').trim();
                final category =
                    (_selectedCategory ?? _categoryCtrl.text).trim();
                final period = _period ?? 'Bulanan';
                final dateText = _dateCtrl.text.trim();

                // Reset error flags
                _nameError = name.isEmpty;
                _amountError = amountStr.isEmpty;
                _categoryError = category.isEmpty;
                _dateError = dateText.isEmpty;
                setState(() {});
                if (_nameError ||
                    _amountError ||
                    _categoryError ||
                    _dateError) {
                  return; // do not proceed, errors are shown via red borders
                }

                final limit = int.tryParse(amountStr) ?? 0;
                if (limit <= 0) {
                  _amountError = true;
                  setState(() {});
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
                  _dateError = true;
                  setState(() {});
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
                  Get.snackbar(
                    'Sukses',
                    'Anggaran disimpan',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green.shade600,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(12),
                    borderRadius: 12,
                  );
                }).catchError((e) {
                  // Silent failure per requirement: no notifications
                });
              } catch (e) {
                // Silent failure per requirement
              }
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
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Batas Anggaran : ',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: 'Rp ${_formatDisplayAmount(_displayAmount)}',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Nama Anggaran'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: _inputDecoration('Masukan nama', isError: _nameError),
            ),
            const SizedBox(height: 16),
            const Text('Jumlah Anggran'),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: _inputDecoration(
                'Masukan jumlah',
                prefixIcon: Align(
                  alignment: Alignment.center,
                  widthFactor: 0.5,
                  child: Text(
                    'Rp ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                isError: _amountError,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Kategori'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showCategoryModal,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _categoryError
                        ? Colors.red.shade400
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    if (_selectedCategory != null) ...[
                      Icon(
                        _getIconForCategory(_selectedCategory!),
                        color: _blue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedCategory!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ] else
                      Expanded(
                        child: Text(
                          'Pilih Kategori',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Jenis Periode'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showPeriodModal,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    if (_period != null)
                      Expanded(
                        child: Text(
                          _period!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Text(
                          'Pilih jenis periode',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tanggal Mulai'),
            const SizedBox(height: 8),
            TextField(
              controller: _dateCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: _inputDecoration('Pilih tanggal',
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                  isError: _dateError),
            ),
          ],
        ),
      ),
    );
  }
}
