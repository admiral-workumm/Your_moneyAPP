import 'package:get/get.dart';
import 'package:your_money/app/modules/catatkeuangan/controllers/catatkeuangan_controller.dart';

class CatatKeuanganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatatKeuanganController>(() => CatatKeuanganController());
  }
}
