import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AturBukuController extends GetxController {
  final namaPenggunaC = TextEditingController();
  final namaBukuC = TextEditingController();
  final kartuDebitC = TextEditingController();

  final currencies = const ['IDR - Rupiah', 'USD - Dollar', 'EUR - Euro'];
  final selectedCurrency = 'IDR - Rupiah'.obs;

  void onNext() {
    Get.offAllNamed('/home');
  }

  @override
  void onClose() {
    namaPenggunaC.dispose();
    namaBukuC.dispose();
    kartuDebitC.dispose();
    super.onClose();
  }
}
