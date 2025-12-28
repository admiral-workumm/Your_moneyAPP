import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:your_money/app/data/models/transaksi.dart';
import 'package:your_money/app/data/services/transaksi_service.dart';

class DetailKategoriController extends GetxController {
  // Observable variables
  final selectedMonth = DateTime.now().obs;
  final expandedDates = <String>[].obs;
  final transactionsByDate = <String, List<Transaksi>>{}.obs;
  final selectedType = 'semua'.obs; // 'semua', 'pemasukan', 'pengeluaran'

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

  // Calculate total pemasukan untuk kategori di bulan ini
  double get totalPemasukan {
    double total = 0;
    transactionsByDate.forEach((date, transactions) {
      for (var txn in transactions) {
        if (txn.tipe == 'pemasukan') {
          final amount =
              double.tryParse(txn.jumlah.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          total += amount;
        }
      }
    });
    return total;
  }

  // Get total based on transaction type (first transaction in the category)
  double get totalAmount {
    return totalPemasukan > 0 ? totalPemasukan : totalPengeluaran;
  }

  // Check if this category has income transactions
  bool get isIncomeCategory {
    return totalPemasukan > 0;
  }

  // Get filtered total based on selected type
  double get filteredTotal {
    if (selectedType.value == 'pemasukan') {
      return totalPemasukan;
    } else if (selectedType.value == 'pengeluaran') {
      return totalPengeluaran;
    }
    return totalPemasukan + totalPengeluaran;
  }

  // Get filtered transactions by type
  Map<String, List<Transaksi>> get filteredTransactions {
    if (selectedType.value == 'semua') {
      return transactionsByDate;
    }

    final filtered = <String, List<Transaksi>>{};
    transactionsByDate.forEach((date, transactions) {
      final matchingTxns =
          transactions.where((txn) => txn.tipe == selectedType.value).toList();
      if (matchingTxns.isNotEmpty) {
        filtered[date] = matchingTxns;
      }
    });
    return filtered;
  }

  // Count transaksi untuk kategori di bulan ini (filtered)
  int get totalTransactions {
    int count = 0;
    filteredTransactions.forEach((date, transactions) {
      count += transactions.length;
    });
    return count;
  }

  // Change selected type
  void setSelectedType(String type) {
    selectedType.value = type;
    // Reset expansions
    expandedDates.clear();
    if (filteredTransactions.isNotEmpty) {
      expandedDates.add(filteredTransactions.keys.first);
    }
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
