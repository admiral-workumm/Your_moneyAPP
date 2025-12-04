import 'package:get/get.dart';

class DetailKategoriController extends GetxController {
  // Observable variables
  final selectedMonth = DateTime.now().obs;
  final expandedDates = <String>[].obs;

  // Format bulan untuk display
  String get formattedMonth {
    return '${selectedMonth.value.month.toString().padLeft(2, '0')} / ${selectedMonth.value.year}';
  }

  // Navigate ke bulan sebelumnya
  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
  }

  // Navigate ke bulan berikutnya
  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
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

  @override
  void onInit() {
    super.onInit();
    // Default: expand semua tanggal
    expandedDates.add('2025-10-10');
  }
}
