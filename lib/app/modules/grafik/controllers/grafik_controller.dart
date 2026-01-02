import 'package:get/get.dart';
import 'package:your_money/app/data/models/transaksi.dart';
import 'package:your_money/app/data/services/transaksi_service.dart';

class GrafikController extends GetxController {
  final _transaksiService = TransaksiService();

  // Observable data untuk grafik
  var totalPemasukan = 0.obs;
  var totalPengeluaran = 0.obs;
  var transaksiList = <Transaksi>[].obs;

  var selectedMonth = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  /// Refresh data grafik berdasarkan bulan yang dipilih
  void refreshData() {
    _loadChartData();
  }

  void _loadChartData() {
    final month = selectedMonth.value;

    // Ambil semua transaksi bulan ini
    transaksiList.value = _transaksiService.getTransaksiByMonth(month);

    // Hitung total
    totalPemasukan.value = _transaksiService.getTotalPemasukanMonth(month);
    totalPengeluaran.value = _transaksiService.getTotalPengeluaranMonth(month);

    print('[GrafikController] Loaded data for ${month.year}-${month.month}');
    print(
        '[GrafikController] Pemasukan: ${totalPemasukan.value}, Pengeluaran: ${totalPengeluaran.value}');
  }

  /// Ganti bulan dan refresh
  void changeMonth(DateTime newMonth) {
    selectedMonth.value = newMonth;
    _loadChartData();
  }

  /// Navigate ke bulan sebelumnya
  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
    _loadChartData();
  }

  /// Navigate ke bulan berikutnya
  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
    _loadChartData();
  }

  /// Format rupiah untuk tampilan
  String formatRupiah(int value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    final formatted = absValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return isNegative ? '-Rp$formatted' : 'Rp$formatted';
  }
}
