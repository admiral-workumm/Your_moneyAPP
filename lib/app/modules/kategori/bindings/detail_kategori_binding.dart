import 'package:get/get.dart';
import '../controllers/detail_kategori_controller.dart';

class DetailKategoriBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailKategoriController>(
      () => DetailKategoriController(),
    );
  }
}
