import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CatatKeuanganController extends GetxController {
  // Controller untuk text field
  final jumlahC = TextEditingController();
  final ketC = TextEditingController();
  final tanggalC = TextEditingController();

  // Observables (pakai Rx agar bisa reactive di Obx)
  final jenisDompet = RxnString();
  final kategori = RxnString();

  // Daftar pilihan dropdown
  final dompetOptions = const [
    'Tunai',
    'E-Wallet',
    'Bank',
  ];

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

  /// Fungsi ketika tombol centang ditekan (simpan catatan)
  void onSimpan() {
    // Validasi sederhana
    if (jumlahC.text.isEmpty ||
        ketC.text.isEmpty ||
        jenisDompet.value == null ||
        tanggalC.text.isEmpty ||
        kategori.value == null) {
      Get.snackbar(
        'Peringatan',
        'Lengkapi semua data terlebih dahulu!',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // TODO: simpan data ke database / Firebase / local storage
    Get.snackbar(
      'Berhasil',
      'Catatan keuangan berhasil disimpan!',
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );

    // Tutup halaman setelah simpan
    Get.back();
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
