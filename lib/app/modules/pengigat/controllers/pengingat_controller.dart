import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/pengingat_model.dart';

class PengingatController extends GetxController {
  final _box = GetStorage();
  final pengingatList = <PengingatModel>[].obs;

  static const _pengingatKey = 'pengingat_list';

  @override
  void onInit() {
    super.onInit();
    _loadPengingat();
  }

  void _loadPengingat() {
    final stored = _box.read(_pengingatKey);
    if (stored is List) {
      pengingatList.assignAll(
        stored
            .cast<Map>()
            .map((e) => PengingatModel.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
    }
  }

  void _persistPengingat() {
    _box.write(_pengingatKey, pengingatList.map((p) => p.toJson()).toList());
  }

  void addPengingat(int hours, int minutes, String periode) {
    final newId = pengingatList.isEmpty
        ? 1
        : (pengingatList.map((p) => p.id).reduce((a, b) => a > b ? a : b)) + 1;

    final newPengingat = PengingatModel(
      id: newId,
      hours: hours,
      minutes: minutes,
      periode: periode,
      isActive: true,
    );

    pengingatList.add(newPengingat);
    _persistPengingat();
  }

  void deletePengingat(int id) {
    pengingatList.removeWhere((p) => p.id == id);
    _persistPengingat();
  }

  void togglePengingat(int id) {
    final idx = pengingatList.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      pengingatList[idx] = pengingatList[idx].copyWith(
        isActive: !pengingatList[idx].isActive,
      );
      _persistPengingat();
    }
  }

  void updatePengingat(
    int id,
    int hours,
    int minutes,
    String periode,
  ) {
    final idx = pengingatList.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      pengingatList[idx] = pengingatList[idx].copyWith(
        hours: hours,
        minutes: minutes,
        periode: periode,
      );
      _persistPengingat();
    }
  }
}
