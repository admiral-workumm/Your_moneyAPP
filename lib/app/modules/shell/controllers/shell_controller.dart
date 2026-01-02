import 'package:get/get.dart';
import '../../grafik/controllers/grafik_controller.dart';

import '../../Dompet/controllers/dompet_controller.dart';


class ShellController extends GetxController {
  final tabIndex = 0.obs;

  bool _argsHandled = false;

  void changeTab(int idx) {
    tabIndex.value = idx;

    // Refresh Dompet saat buka tab Dompet
    if (idx == 1 && Get.isRegistered<DompetController>()) {
      Get.find<DompetController>().refreshSaldo();
    }
    // Refresh Grafik saat buka tab Grafik
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
