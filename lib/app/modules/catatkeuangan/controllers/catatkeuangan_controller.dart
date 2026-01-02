import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:your_money/app/data/models/transaksi.dart';
import 'package:your_money/app/data/services/transaksi_service.dart';
import 'package:your_money/app/data/services/budget_notification_service.dart';
import 'package:your_money/app/modules/home/controllers/home_controller.dart';
import 'package:your_money/app/modules/Dompet/controllers/dompet_controller.dart';
import 'package:your_money/app/modules/grafik/controllers/grafik_controller.dart';
import 'package:your_money/app/routes/app_routes.dart';

class CatatKeuanganController extends GetxController {
  // Controller untuk text field
  final jumlahC = TextEditingController();
  final ketC = TextEditingController();
  final tanggalC = TextEditingController();

  // Observables (pakai Rx agar bisa reactive di Obx)
  final jenisDompet = RxnString();
  final kategori = RxnString();
  final tipeTransaksi =
      RxString('pengeluaran'); // 'pengeluaran' atau 'pemasukan'

  // Formatter untuk field jumlah (Rupiah)
  final rupiahFormatter = RupiahInputFormatter();

  // Service untuk menyimpan transaksi
  final _transaksiService = TransaksiService();

  // Service untuk notifikasi anggaran
  final _budgetNotificationService = BudgetNotificationService();

  // Mode edit
  var editingTransaksi = Rxn<Transaksi>();

  // Daftar pilihan dropdown
  final dompetOptions = <String>[].obs;
  // map wallet name -> wallet id (best-effort by current state)
  final _dompetNameToId = <String, String>{}.obs;

  DompetController? _dompetController;

  @override
  void onInit() {
    super.onInit();
    _initDompetController();
    // Reset form setiap kali buka (jika tidak dalam edit mode)
    if (editingTransaksi.value == null) {
      _resetForm();
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Re-sync dompet options saat view sudah ready
    _syncDompetOptions();
    print('[CatatKeuanganController] onReady - re-synced dompet options');
  }

  void _initDompetController() {
    try {
      if (Get.isRegistered<DompetController>()) {
        _dompetController = Get.find<DompetController>();
        print('[CatatKeuanganController] DompetController found, syncing...');

        // Setup listener untuk perubahan wallets
        ever<List<WalletItem>>(_dompetController!.wallets, (_) {
          print('[CatatKeuanganController] Wallets changed, re-syncing...');
          _syncDompetOptions();
        });

        // Sync dompet options saat inisialisasi
        _syncDompetOptions();
        print(
            '[CatatKeuanganController] Initial sync completed. Options: ${dompetOptions.length}');
      } else {
        print(
            '[CatatKeuanganController] WARNING: DompetController not registered!');
      }
    } catch (e) {
      print(
          '[CatatKeuanganController] Error initializing DompetController: $e');
    }
  }

  void _syncDompetOptions() {
    final source = _dompetController?.wallets ?? <WalletItem>[];
    print('[CatatKeuanganController] Syncing from ${source.length} wallets');

    final active = source.where((w) => (w.active ?? true)).toList();
    print('[CatatKeuanganController] ${active.length} active wallets found');

    dompetOptions.assignAll(active.map((w) => w.name));
    _dompetNameToId
      ..clear()
      ..addAll({for (final w in active) w.name: w.id});

    print('[CatatKeuanganController] Options updated: $dompetOptions');

    if (dompetOptions.isEmpty) {
      jenisDompet.value = null;
      print(
          '[CatatKeuanganController] No wallets available, setting jenisDompet to null');
    } else if (jenisDompet.value == null ||
        !dompetOptions.contains(jenisDompet.value)) {
      // Auto-select first wallet if none selected or current selection invalid
      jenisDompet.value = dompetOptions.first;
      print(
          '[CatatKeuanganController] Auto-selected first wallet: ${jenisDompet.value}');
    }
  }

  /// Fungsi untuk memilih tanggal
  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = _tryParseDate(tanggalC.text) ?? now;
    final first = DateTime(now.year - 3);
    final last = DateTime(now.year + 3);

    final picked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        const primary = Color(0xFF1E88E5);
        const onSurface = Colors.black87;
        const surface = Colors.white;
        DateTime temp = initial;

        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              surface: surface,
              onSurface: onSurface,
            ),
            dialogBackgroundColor: surface,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primary),
            ),
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            content: StatefulBuilder(
              builder: (context, setState) {
                return SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pilih Tanggal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CalendarDatePicker(
                        initialDate: temp,
                        firstDate: first,
                        lastDate: last,
                        onDateChanged: (d) => setState(() => temp = d),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, temp),
                            child: const Text('Pilih'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      tanggalC.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  /// Ambil nilai jumlah sebagai int dari teks terformat (mis. "10.000")
  int parseJumlah(String text) => RupiahInputFormatter.parseToInt(text);

  DateTime? _tryParseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final p = raw.split('-');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    } catch (_) {
      return null;
    }
  }

  /// Load transaksi untuk edit
  void loadTransaksiForEdit(Transaksi txn) {
    editingTransaksi.value = txn;
    jumlahC.text = txn.jumlah;
    ketC.text = txn.keterangan;
    tanggalC.text = txn.tanggal;
    // Prefer mapping by dompetId back to current wallet name (in case renamed)
    if (_dompetController != null) {
      final idx = _dompetController!.indexOfWallet(txn.dompetId);
      if (idx >= 0) {
        jenisDompet.value = _dompetController!.wallets[idx].name;
      } else {
        jenisDompet.value = txn.jenisDompet;
      }
    } else {
      jenisDompet.value = txn.jenisDompet;
    }
    kategori.value = txn.kategori;
    tipeTransaksi.value = txn.tipe;
    print(
        '[CatatKeuanganController] Loaded transaksi for edit: ${txn.kategori}');
  }

  /// Fungsi ketika tombol centang ditekan (simpan catatan)
  Future<void> onSimpan() async {
    print('[CatatKeuanganController] onSimpan() called!');

    if (dompetOptions.isEmpty) {
      Get.snackbar(
        'Tidak ada dompet',
        'Tambahkan dompet terlebih dahulu sebelum mencatat transaksi.',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Auto-select first wallet if none selected
    if (jenisDompet.value == null && dompetOptions.isNotEmpty) {
      jenisDompet.value = dompetOptions.first;
      print(
          '[CatatKeuanganController] Auto-selected wallet before save: ${jenisDompet.value}');
    }

    // Validasi sederhana
    if (jumlahC.text.isEmpty ||
        ketC.text.isEmpty ||
        jenisDompet.value == null ||
        tanggalC.text.isEmpty ||
        kategori.value == null) {
      print('[CatatKeuanganController] Validation failed!');
      Get.snackbar(
        'Peringatan',
        'Lengkapi semua data terlebih dahulu!',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Check apakah edit atau create
    final isEditing = editingTransaksi.value != null;

    if (isEditing) {
      // UPDATE mode
      final prev = editingTransaksi.value!;
      final selectedName = jenisDompet.value ?? '';
      final selectedId = _dompetNameToId[selectedName] ?? prev.dompetId;
      final updatedTxn = prev.copyWith(
        jumlah: jumlahC.text,
        keterangan: ketC.text,
        jenisDompet: selectedName,
        dompetId: selectedId,
        tanggal: tanggalC.text,
        kategori: kategori.value ?? '',
        tipe: tipeTransaksi.value,
      );
      await _transaksiService.updateTransaksi(updatedTxn);

      // Adjust wallet saldo based on changes
      try {
        if (Get.isRegistered<DompetController>()) {
          final dompet = Get.find<DompetController>();
          final oldAmount = int.tryParse(prev.jumlah.replaceAll('.', '')) ?? 0;
          final newAmount =
              int.tryParse(updatedTxn.jumlah.replaceAll('.', '')) ?? 0;

          // Revert old effect
          final oldDelta = prev.tipe == 'pemasukan' ? -oldAmount : oldAmount;
          dompet.adjustWalletSaldoById(prev.dompetId, oldDelta);

          // Apply new effect to possibly new wallet
          final newDelta =
              updatedTxn.tipe == 'pemasukan' ? newAmount : -newAmount;
          dompet.adjustWalletSaldoById(updatedTxn.dompetId, newDelta);
        }
      } catch (_) {}

      Get.snackbar(
        'Berhasil',
        'Catatan keuangan berhasil diperbarui!',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      // CREATE mode
      print('[CatatKeuanganController] CREATE mode - saving new transaction');
      final selectedName = jenisDompet.value ?? '';
      final selectedId = _dompetNameToId[selectedName] ?? '';
      final transaksi = Transaksi(
        id: '', // akan di-generate oleh service
        jumlah: jumlahC.text,
        keterangan: ketC.text,
        jenisDompet: selectedName,
        dompetId: selectedId,
        tanggal: tanggalC.text,
        kategori: kategori.value ?? '',
        tipe: tipeTransaksi.value,
      );

      // Simpan ke local storage (await untuk memastikan selesai)
      await _transaksiService.addTransaksi(transaksi);
      print('[CatatKeuanganController] Transaction saved successfully');

      // Cek dan tampilkan notifikasi anggaran (SETIAP KALI transaksi disimpan)
      await _budgetNotificationService.checkAndNotify();
      print('[CatatKeuanganController] Budget notification check completed');

      // Update saldo dompet langsung
      try {
        if (Get.isRegistered<DompetController>()) {
          final dompet = Get.find<DompetController>();
          final amount =
              int.tryParse(transaksi.jumlah.replaceAll('.', '')) ?? 0;
          final delta = transaksi.tipe == 'pemasukan' ? amount : -amount;
          dompet.adjustWalletSaldoById(transaksi.dompetId, delta);
        }
      } catch (_) {}

      Get.snackbar(
        'Berhasil',
        'Catatan keuangan berhasil disimpan!',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
    }

    // Reset form
    _resetForm();

    // Trigger refresh di HomeController dan DompetController SEBELUM back
    try {
      final homeController = Get.find<HomeController>();
      print('[CatatKeuanganController] Refreshing home controller...');
      homeController.refreshTransaksi();
      print('[CatatKeuanganController] Home controller refreshed!');
    } catch (e) {
      print('[CatatKeuanganController] HomeController error: $e');
    }

    try {
      if (Get.isRegistered<DompetController>()) {
        final dompetController = Get.find<DompetController>();
        print('[CatatKeuanganController] Refreshing dompet controller...');
        dompetController.refreshSaldo();
        print('[CatatKeuanganController] Dompet controller refreshed!');
      }
    } catch (e) {
      print('[CatatKeuanganController] DompetController error: $e');
    }

    // Refresh Grafik controller jika sudah di-register
    try {
      if (Get.isRegistered<GrafikController>()) {
        final grafikController = Get.find<GrafikController>();
        print('[CatatKeuanganController] Refreshing grafik controller...');
        grafikController.refreshData();
        print('[CatatKeuanganController] Grafik controller refreshed!');
      }
    } catch (e) {
      print('[CatatKeuanganController] GrafikController error: $e');
    }

    // Delay navigasi sampai snackbar selesai (1.5 detik) supaya tidak conflict
    print('[CatatKeuanganController] Waiting for snackbar to finish...');
    await Future.delayed(const Duration(milliseconds: 1600));

    // Navigasi langsung ke HOME (bukan Get.back)
    print('[CatatKeuanganController] Navigating back to HOME...');
    Get.offNamed(Routes.HOME);
  }

  /// Reset semua field form
  void _resetForm() {
    jumlahC.clear();
    ketC.clear();
    tanggalC.clear();
    jenisDompet.value = null;
    kategori.value = null;
    tipeTransaksi.value = 'pengeluaran';
    editingTransaksi.value = null; // Reset edit mode
  }

  /// Reset form untuk create baru (bukan edit)
  void resetFormForCreate() {
    print('[CatatKeuanganController] Resetting form for create...');
    _resetForm();
  }

  @override
  void onClose() {
    // Hapus controller text biar tidak leak memory
    jumlahC.dispose();
    ketC.dispose();
    tanggalC.dispose();
    super.onClose();
  }
}

/// Formatter Rupiah dengan pemisah ribuan (tanpa desimal), stabil untuk cursor
class RupiahInputFormatter extends TextInputFormatter {
  RupiahInputFormatter({String locale = 'id_ID'})
      : _formatter = NumberFormat.decimalPattern(locale);

  final NumberFormat _formatter;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.parse(digits);
    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Helper untuk parsing kembali ke int jika diperlukan
  static int parseToInt(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }
}
