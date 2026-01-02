import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/anggaran.dart';
import '../models/transaksi.dart';
import 'anggaran_service.dart';
import 'transaksi_service.dart';

/// Service untuk menampilkan notifikasi anggaran
/// Dipanggil setiap kali transaksi baru ditambahkan
class BudgetNotificationService {
  final _anggaranService = AnggaranService();
  final _transaksiService = TransaksiService();

  /// Cek dan tampilkan notifikasi jika anggaran terlampaui
  /// Dipanggil SETIAP KALI transaksi baru disimpan
  Future<void> checkAndNotify() async {
    try {
      // Get semua anggaran yang ada
      final allAnggaran = _anggaranService.getAll();
      if (allAnggaran.isEmpty) return;

      // Get semua transaksi
      final allTransaksi = _transaksiService.getAllTransaksi();
      if (allTransaksi.isEmpty) return;

      // Cek setiap anggaran
      for (final anggaran in allAnggaran) {
        final totalExpense = _calculateExpenseForBudget(anggaran, allTransaksi);

        // Jika pengeluaran >= batas anggaran, tampilkan notifikasi
        if (totalExpense >= anggaran.limit) {
          _showNotification(anggaran.name);
        }
      }
    } catch (e) {
      print('Error checking budget: $e');
    }
  }

  /// Hitung total pengeluaran untuk satu anggaran tertentu
  int _calculateExpenseForBudget(
      Anggaran anggaran, List<Transaksi> allTransaksi) {
    try {
      // Filter transaksi yang sesuai dengan anggaran
      final filtered = allTransaksi.where((t) {
        try {
          final tDate = DateTime.parse(t.tanggal);

          // Cek apakah dalam range periode anggaran
          final isInRange = tDate.isAfter(
                  anggaran.startDate.subtract(const Duration(days: 1))) &&
              tDate.isBefore(anggaran.endDate.add(const Duration(days: 1)));

          // Cek apakah kategori sama dan tipe pengeluaran
          final isExpense = t.tipe.toLowerCase() == 'pengeluaran';
          final isSameCategory =
              t.kategori.toLowerCase() == anggaran.category.toLowerCase();

          return isInRange && isExpense && isSameCategory;
        } catch (_) {
          return false;
        }
      }).toList();

      // Hitung total
      int total = 0;
      for (final t in filtered) {
        try {
          final amount = int.parse(t.jumlah.replaceAll(RegExp(r'[^\d]'), ''));
          total += amount;
        } catch (_) {
          continue;
        }
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Tampilkan notifikasi di bagian bawah layar (Snackbar)
  void _showNotification(String budgetName) {
    Get.snackbar(
      'Anggaran Terlampaui',
      'Anggaran "$budgetName" telah melebihi batas',
      backgroundColor: const Color(0xFF1E88E5), // Biru
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }
}
