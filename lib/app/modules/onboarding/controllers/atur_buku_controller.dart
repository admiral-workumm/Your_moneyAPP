import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/modules/home/controllers/home_controller.dart';

class AturBukuController extends GetxController {
  final namaPenggunaC = TextEditingController();
  final namaBukuC = TextEditingController();

  void onNext() {
    // Store the data before navigating
    if (namaPenggunaC.text.isNotEmpty && namaBukuC.text.isNotEmpty) {
      final homeC = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : Get.put(HomeController(), permanent: true);
      homeC.addOrUpdateAccount({
        'userName': namaPenggunaC.text,
        'bookName': namaBukuC.text,
      });
      Get.offAllNamed('/home');
    }
  }

  @override
  void onClose() {
    namaPenggunaC.dispose();
    namaBukuC.dispose();
    super.onClose();
  }
}
