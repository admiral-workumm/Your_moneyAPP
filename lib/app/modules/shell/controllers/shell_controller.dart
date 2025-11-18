import 'package:get/get.dart';

class ShellController extends GetxController {
  final tabIndex = 0.obs;

  bool _argsHandled = false;

  void changeTab(int idx) {
    tabIndex.value = idx;
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
