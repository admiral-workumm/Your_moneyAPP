import 'package:get_storage/get_storage.dart';
import '../models/anggaran.dart';

class AnggaranService {
  static const String _key = 'anggaran_list';
  final _box = GetStorage();

  Future<void> addAnggaran(Anggaran a) async {
    try {
      final List<dynamic> stored = _box.read(_key) ?? [];
      stored.add(a.toMap());
      await _box.write(_key, stored);
    } catch (e) {
      rethrow; // bubble up for UI to handle
    }
  }

  Future<void> deleteAnggaran(String id) async {
    try {
      final List<dynamic> stored = _box.read(_key) ?? [];
      stored.removeWhere((e) {
        if (e is Map) {
          final map = Map<String, dynamic>.from(e);
          return map['id'] == id;
        }
        return false;
      });
      await _box.write(_key, stored);
    } catch (e) {
      rethrow;
    }
  }

  List<Anggaran> getAll() {
    try {
      final List<dynamic> stored = _box.read(_key) ?? [];
      return stored
          .whereType<Map>()
          .map((m) => Anggaran.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      // if storage malformed, return empty safe default
      return [];
    }
  }

  Future<void> updateAnggaran(Anggaran updated) async {
    try {
      final List<dynamic> stored = _box.read(_key) ?? [];
      final list = stored
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
      final idx = list.indexWhere((m) => m['id'] == updated.id);
      if (idx != -1) {
        list[idx] = updated.toMap();
      } else {
        list.add(updated.toMap());
      }
      await _box.write(_key, list);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      await _box.remove(_key);
    } catch (_) {}
  }
}
