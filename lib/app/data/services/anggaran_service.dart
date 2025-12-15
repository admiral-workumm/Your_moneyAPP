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

  Future<void> clearAll() async {
    try {
      await _box.remove(_key);
    } catch (_) {}
  }
}
