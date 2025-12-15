import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:your_money/app/data/models/transaksi.dart';
import 'package:your_money/app/data/services/transaksi_service.dart';

class DetailKategoriController extends GetxController {
  // Observable variables
  final selectedMonth = DateTime.now().obs;
  final expandedDates = <String>[].obs;
  final transactionsByDate = <String, List<Transaksi>>{}.obs;

  // Service
  final _transaksiService = TransaksiService();

  // Kategori yang sedang dilihat
  late String selectedKategori;

  // Format bulan untuk display
  String get formattedMonth {
    return '${selectedMonth.value.month.toString().padLeft(2, '0')} / ${selectedMonth.value.year}';
  }

  // Calculate total pengeluaran untuk kategori di bulan ini
  double get totalPengeluaran {
    double total = 0;
    transactionsByDate.forEach((date, transactions) {
      for (var txn in transactions) {
        if (txn.tipe == 'pengeluaran') {
          // Parse jumlah (bisa berupa "50000" atau "-50000")
          final amount =
              double.tryParse(txn.jumlah.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          total += amount;
        }
      }
    });
    return total;
  }

  // Count transaksi untuk kategori di bulan ini
  int get totalTransactions {
    int count = 0;
    transactionsByDate.forEach((date, transactions) {
      count += transactions.length;
    });
    return count;
  }

  // Navigate ke bulan sebelumnya
  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
    _loadTransactionsForMonth();
  }

  // Navigate ke bulan berikutnya
  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
    _loadTransactionsForMonth();
  }

  // Toggle expand/collapse untuk tanggal tertentu
  void toggleDateExpansion(String dateKey) {
    if (expandedDates.contains(dateKey)) {
      expandedDates.remove(dateKey);
    } else {
      expandedDates.add(dateKey);
    }
  }

  // Check apakah tanggal sedang di-expand
  bool isDateExpanded(String dateKey) {
    return expandedDates.contains(dateKey);
  }

  // Load transaksi untuk kategori di bulan yang dipilih
  void _loadTransactionsForMonth() {
    final allTransaksi = _transaksiService.getAllTransaksi();
    final Map<String, List<Transaksi>> grouped = {};

    for (var txn in allTransaksi) {
      // Filter berdasarkan kategori dan bulan
      if (txn.kategori == selectedKategori) {
        final txnDate = DateTime.tryParse(txn.tanggal);
        if (txnDate != null &&
            txnDate.year == selectedMonth.value.year &&
            txnDate.month == selectedMonth.value.month) {
          // Group by date
          final dateKey = txn.tanggal;
          if (!grouped.containsKey(dateKey)) {
            grouped[dateKey] = [];
          }
          grouped[dateKey]!.add(txn);
        }
      }
    }

    // Sort dates in descending order
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    transactionsByDate.clear();
    for (var date in sortedDates) {
      transactionsByDate[date] = grouped[date] ?? [];
    }

    // Auto-expand first date
    if (transactionsByDate.isNotEmpty) {
      expandedDates.clear();
      expandedDates.add(transactionsByDate.keys.first);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize locale data untuk bahasa Indonesia
    initializeDateFormatting('id_ID', null);

    // Get kategori dari arguments
    final args = Get.arguments as Map<String, dynamic>?;
    selectedKategori = args?['kategori'] as String? ?? '';

    // Load transaksi
    _loadTransactionsForMonth();
  }
}
