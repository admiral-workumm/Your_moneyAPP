import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/transaksi.dart';

class TransaksiService {
  final _box = GetStorage();

  String _sanitizeId(String? value) {
    final fallback = (value ?? '').trim();
    if (fallback.isEmpty) return 'default';
    final cleaned = fallback.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return cleaned.isEmpty ? 'default' : cleaned;
  }

  String get _transaksiKey {
    try {
      final current = _box.read('currentAccount');
      if (current is Map) {
        final book = current['bookName']?.toString();
        final user = current['userName']?.toString();
        final id = (book != null && book.trim().isNotEmpty)
            ? book
            : (user ?? 'default');
        return 'transaksi_${_sanitizeId(id)}';
      }
    } catch (_) {}
    return 'transaksi_default';
  }

  /// Tambah transaksi baru
  Future<void> addTransaksi(Transaksi transaksi) async {
    try {
      // Prefer per-account key. If empty, try migrating legacy global key.
      List<dynamic> stored = _box.read(_transaksiKey) ?? [];
      // Do not automatically migrate global legacy data into every new account.
      // Only consider legacy key when we don't have a per-account context
      if (stored.isEmpty && _transaksiKey == 'transaksi_default') {
        final legacy = _box.read('transaksi_list');
        if (legacy is List && legacy.isNotEmpty) {
          stored = List<dynamic>.from(legacy);
          await _box.write(_transaksiKey, stored);
        }
      }

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
      List<dynamic> stored = _box.read(_transaksiKey) ?? [];
      print(
          '[TransaksiService] Raw stored data (key ${_transaksiKey}): ${stored.length} items');

      // Avoid showing legacy global transactions for newly created books.
      // Only fallback to legacy when we have no account context.
      if (stored.isEmpty && _transaksiKey == 'transaksi_default') {
        final legacy = _box.read('transaksi_list');
        if (legacy is List && legacy.isNotEmpty) {
          stored = List<dynamic>.from(legacy);
          print(
              '[TransaksiService] Migrated ${legacy.length} items from legacy key');
        }
      }

      final result = <Transaksi>[];
      for (var item in stored) {
        try {
          if (item is Map) {
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
      // Also remove legacy key if present
      try {
        await _box.remove('transaksi_list');
      } catch (_) {}
    } catch (e) {
      print('Error clearing transaksi: $e');
    }
  }
}
