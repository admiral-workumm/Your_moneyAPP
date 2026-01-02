import 'package:get/get.dart';
import 'package:your_money/app/modules/catatkeuangan/controllers/catatkeuangan_controller.dart';
import 'package:your_money/app/modules/Dompet/controllers/dompet_controller.dart';

class CatatKeuanganBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure DompetController is available
    if (!Get.isRegistered<DompetController>()) {
      Get.put<DompetController>(DompetController(), permanent: true);
    }

    // Then create CatatKeuanganController
    Get.lazyPut<CatatKeuanganController>(() => CatatKeuanganController());
  }
}
