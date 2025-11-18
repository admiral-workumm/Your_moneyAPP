import 'package:get/get.dart';
import 'package:your_money/app/modules/catatkeuangan/views/catat_keuangan_view.dart';

class CatatKeuanganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatatKeuanganController>(() => CatatKeuanganController());
  }
}
