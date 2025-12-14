import 'package:get/get.dart';
import 'package:your_money/app/modules/Dompet/controllers/dompet_controller.dart';

class DompetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DompetController>(() => DompetController());
  }
}
