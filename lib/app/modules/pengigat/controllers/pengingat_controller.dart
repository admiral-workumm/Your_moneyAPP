import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/pengingat_model.dart';
import '../../../services/notification_service.dart';

class PengingatController extends GetxController {
  final _box = GetStorage();
  final pengingatList = <PengingatModel>[].obs;
  final _notificationService = NotificationService();

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

    // Schedule notification
    _scheduleNotification(newPengingat);
  }

  void deletePengingat(int id) {
    pengingatList.removeWhere((p) => p.id == id);
    _persistPengingat();

    // Cancel notification
    _notificationService.cancelNotification(id);
  }

  void togglePengingat(int id) {
    final idx = pengingatList.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      pengingatList[idx] = pengingatList[idx].copyWith(
        isActive: !pengingatList[idx].isActive,
      );
      _persistPengingat();

      // Schedule or cancel notification based on active status
      if (pengingatList[idx].isActive) {
        _scheduleNotification(pengingatList[idx]);
      } else {
        _notificationService.cancelNotification(id);
      }
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

      // Reschedule notification
      if (pengingatList[idx].isActive) {
        _notificationService.cancelNotification(id);
        _scheduleNotification(pengingatList[idx]);
      }
    }
  }

  // Helper method untuk schedule notification berdasarkan periode
  void _scheduleNotification(PengingatModel pengingat) {
    final title = 'Pengingat Keuangan';
    final body = 'Jangan lupa catat pengeluaran Anda hari ini!';

    switch (pengingat.periode) {
      case 'Harian':
        _notificationService.scheduleDailyNotification(
          id: pengingat.id,
          title: title,
          body: body,
          hour: pengingat.hours,
          minute: pengingat.minutes,
        );
        break;
      case 'Mingguan':
        _notificationService.scheduleWeeklyNotification(
          id: pengingat.id,
          title: title,
          body: body,
          hour: pengingat.hours,
          minute: pengingat.minutes,
          dayOfWeek: DateTime.monday, // Default ke Senin
        );
        break;
      case 'Bulanan':
        _notificationService.scheduleMonthlyNotification(
          id: pengingat.id,
          title: title,
          body: body,
          hour: pengingat.hours,
          minute: pengingat.minutes,
          dayOfMonth: 1, // Default tanggal 1
        );
        break;
      case 'Tahunan':
        _notificationService.scheduleYearlyNotification(
          id: pengingat.id,
          title: title,
          body: body,
          hour: pengingat.hours,
          minute: pengingat.minutes,
          month: 1,
          day: 1,
        );
        break;
    }
  }
}
