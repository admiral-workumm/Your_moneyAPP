import 'package:get/get.dart';
import '../controllers/shell_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../Dompet/controllers/dompet_controller.dart';
import '../../grafik/controllers/grafik_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(() => ShellController());
    // ensure HomeController available for Home tab
    Get.lazyPut<HomeController>(() => HomeController());
    // ensure DompetController available for Dompet tab
    Get.lazyPut<DompetController>(() => DompetController());
    // ensure GrafikController available for Grafik tab
    Get.lazyPut<GrafikController>(() => GrafikController());
  }
}
