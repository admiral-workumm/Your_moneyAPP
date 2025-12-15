import 'package:get/get.dart';
import 'package:your_money/app/data/models/anggaran.dart';
import 'package:your_money/app/data/services/anggaran_service.dart';

class AnggaranController extends GetxController {
  final list = <Anggaran>[].obs;
  final _service = AnggaranService();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    list.assignAll(_service.getAll());
  }

  Future<void> add(Anggaran a) async {
    try {
      await _service.addAnggaran(a);
      load();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _service.deleteAnggaran(id);
      load();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAnggaran(Anggaran a) async {
    try {
      await _service.updateAnggaran(a);
      load();
    } catch (e) {
      rethrow;
    }
  }
}
