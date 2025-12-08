import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/transaksi.dart';

class TransaksiService {
  static const String _transaksiKey = 'transaksi_list';
  final _box = GetStorage();

  /// Tambah transaksi baru
  Future<void> addTransaksi(Transaksi transaksi) async {
    try {
      final List<dynamic> stored = _box.read(_transaksiKey) ?? [];
      final transaksiWithId = transaksi.copyWith(
        id: transaksi.id.isEmpty ? const Uuid().v4() : transaksi.id,
      );
      print(
          '[TransaksiService] Saving transaksi: ${transaksiWithId.kategori} - ${transaksiWithId.tanggal}');

      stored.add(transaksiWithId.toMap());
      await _box.write(_transaksiKey, stored);

      print(
          '[TransaksiService] Transaksi saved successfully. Total: ${stored.length}');
    } catch (e) {
      print('Error adding transaksi: $e');
    }
  }

  /// Ambil semua transaksi
  List<Transaksi> getAllTransaksi() {
    try {
      final List<dynamic> stored = _box.read(_transaksiKey) ?? [];
      print('[TransaksiService] Raw stored data: ${stored.length} items');

      final result = <Transaksi>[];
      for (var item in stored) {
        try {
          if (item is Map) {
            // Convert Map<dynamic, dynamic> ke Map<String, dynamic>
            final mapData = Map<String, dynamic>.from(item);
            result.add(Transaksi.fromMap(mapData));
            print(
                '[TransaksiService] Loaded: ${mapData['kategori']} - ${mapData['tanggal']}');
          }
        } catch (e) {
          print('[TransaksiService] Error parsing item: $e');
        }
      }

      print('[TransaksiService] Total transaksi loaded: ${result.length}');
      return result;
    } catch (e) {
      print('Error getting transaksi: $e');
      return [];
    }
  }

  /// Ambil transaksi berdasarkan bulan
  List<Transaksi> getTransaksiByMonth(DateTime date) {
    try {
      final allTransaksi = getAllTransaksi();
      print('[TransaksiService] Total transaksi: ${allTransaksi.length}');

      final filtered = allTransaksi.where((t) {
        try {
          final transaksiDate = DateTime.parse(t.tanggal);
          final isMatch = transaksiDate.year == date.year &&
              transaksiDate.month == date.month;
          if (isMatch) {
            print('[TransaksiService] Match: ${t.tanggal} -> ${t.kategori}');
          }
          return isMatch;
        } catch (e) {
          print('[TransaksiService] Error parsing date ${t.tanggal}: $e');
          return false;
        }
      }).toList();

      print(
          '[TransaksiService] Filtered transaksi for ${date.year}-${date.month}: ${filtered.length}');
      return filtered;
    } catch (e) {
      print('[TransaksiService] Error getting transaksi by month: $e');
      return [];
    }
  }

  /// Ambil transaksi berdasarkan tanggal (YYYY-MM-DD)
  List<Transaksi> getTransaksiByDate(String dateString) {
    try {
      final allTransaksi = getAllTransaksi();
      return allTransaksi.where((t) => t.tanggal == dateString).toList();
    } catch (e) {
      print('Error getting transaksi by date: $e');
      return [];
    }
  }

  /// Hitung total pemasukan bulan ini
  int getTotalPemasukanMonth(DateTime date) {
    try {
      final transaksi = getTransaksiByMonth(date)
          .where((t) => t.tipe == 'pemasukan')
          .toList();
      int total = 0;
      for (var t in transaksi) {
        total += int.tryParse(t.jumlah.replaceAll('.', '')) ?? 0;
      }
      return total;
    } catch (e) {
      print('Error calculating pemasukan: $e');
      return 0;
    }
  }

  /// Hitung total pengeluaran bulan ini
  int getTotalPengeluaranMonth(DateTime date) {
    try {
      final transaksi = getTransaksiByMonth(date)
          .where((t) => t.tipe == 'pengeluaran')
          .toList();
      int total = 0;
      for (var t in transaksi) {
        total += int.tryParse(t.jumlah.replaceAll('.', '')) ?? 0;
      }
      return total;
    } catch (e) {
      print('Error calculating pengeluaran: $e');
      return 0;
    }
  }

  /// Update transaksi
  Future<void> updateTransaksi(Transaksi transaksi) async {
    try {
      final List<dynamic> stored = _box.read(_transaksiKey) ?? [];
      final index = stored.indexWhere((e) => e['id'] == transaksi.id);
      if (index >= 0) {
        stored[index] = transaksi.toMap();
        await _box.write(_transaksiKey, stored);
      }
    } catch (e) {
      print('Error updating transaksi: $e');
    }
  }

  /// Hapus transaksi
  Future<void> deleteTransaksi(String id) async {
    try {
      final List<dynamic> stored = _box.read(_transaksiKey) ?? [];
      stored.removeWhere((e) => e['id'] == id);
      await _box.write(_transaksiKey, stored);
    } catch (e) {
      print('Error deleting transaksi: $e');
    }
  }

  /// Hapus semua transaksi
  Future<void> clearAllTransaksi() async {
    try {
      await _box.remove(_transaksiKey);
    } catch (e) {
      print('Error clearing transaksi: $e');
    }
  }
}
