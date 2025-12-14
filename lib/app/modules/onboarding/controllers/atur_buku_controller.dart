import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:your_money/app/modules/home/controllers/home_controller.dart';

class AturBukuController extends GetxController {
  final namaPenggunaC = TextEditingController();
  final namaBukuC = TextEditingController();
  final _storage = GetStorage();

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

      // Simpan status onboarding selesai ke local storage
      _storage.write('onboarding_completed', true);
      _storage.write('user_name', namaPenggunaC.text);
      _storage.write('book_name', namaBukuC.text);
      print('[AturBukuController] Onboarding completed, data saved');

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
