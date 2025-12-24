import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/data/models/transaksi.dart';
import 'package:your_money/app/data/services/transaksi_service.dart';
import 'package:your_money/app/modules/home/controllers/home_controller.dart';
import 'package:your_money/app/modules/Dompet/controllers/dompet_controller.dart';
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

  // Service untuk menyimpan transaksi
  final _transaksiService = TransaksiService();

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
    if (Get.isRegistered<DompetController>()) {
      _dompetController = Get.find<DompetController>();
      ever<List<WalletItem>>(_dompetController!.wallets, (_) {
        _syncDompetOptions();
      });
      _syncDompetOptions();
    }
    // Reset form setiap kali buka (jika tidak dalam edit mode)
    if (editingTransaksi.value == null) {
      _resetForm();
    }
  }

  void _syncDompetOptions() {
    final source = _dompetController?.wallets ?? <WalletItem>[];
    final active = source.where((w) => (w.active ?? true)).toList();
    dompetOptions.assignAll(active.map((w) => w.name));
    _dompetNameToId
      ..clear()
      ..addAll({for (final w in active) w.name: w.id});

    if (dompetOptions.isEmpty) {
      jenisDompet.value = null;
    } else if (jenisDompet.value != null &&
        !dompetOptions.contains(jenisDompet.value)) {
      jenisDompet.value = dompetOptions.first;
    }
  }

  /// Fungsi untuk memilih tanggal
  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      tanggalC.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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

    // Refresh DompetController jika ada
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
