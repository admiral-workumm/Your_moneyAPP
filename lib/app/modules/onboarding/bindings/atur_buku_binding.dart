import 'package:get/get.dart';
import '../controllers/atur_buku_controller.dart';

class AturBukuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AturBukuController>(() => AturBukuController());
  }
}
