import 'package:get/get.dart';
import '../controllers/shell_controller.dart';
import '../../home/controllers/home_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(() => ShellController());
    // ensure HomeController available for Home tab
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
