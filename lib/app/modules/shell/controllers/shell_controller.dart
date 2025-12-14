import 'package:get/get.dart';
import '../../grafik/controllers/grafik_controller.dart';

class ShellController extends GetxController {
  final tabIndex = 0.obs;

  bool _argsHandled = false;

  void changeTab(int idx) {
    tabIndex.value = idx;
    if (idx == 2 && Get.isRegistered<GrafikController>()) {
      Get.find<GrafikController>().refreshData();
    }
  }

  /// Set initial tab from incoming arguments only once.
  void setInitialFromArgs(dynamic args) {
    if (_argsHandled) return;
    _argsHandled = true;
    try {
      if (args is Map && args['tab'] is int) {
        tabIndex.value = args['tab'] as int;
      }
    } catch (_) {
      // ignore
    }
  }
}
