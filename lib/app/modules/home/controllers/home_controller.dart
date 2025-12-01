import 'package:get/get.dart';

class HomeController extends GetxController {
  var saldoTotal = 1000000.obs;
  var pemasukan = 500000.obs;
  var pengeluaran = 200000.obs;

  var selectedDate = DateTime.now().obs;

  void previousMonth() {
    selectedDate.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month - 1,
    );
  }

  void nextMonth() {
    selectedDate.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month + 1,
    );
  }
}
