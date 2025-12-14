import 'package:get/get.dart';
import 'package:your_money/app/modules/pengigat/controllers/pengingat_controller.dart';

class PengingatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengingatController>(() => PengingatController());
  }
}
