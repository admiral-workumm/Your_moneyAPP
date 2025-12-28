import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

class WalletItem {
  final String id;
  final String name;
  final String type; // tunai | e-wallet | bank
  final String iconKey; // cash | wallet | card
  final int saldo;
  final bool? active; // nullable for backward compatibility

  const WalletItem({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.saldo,
    this.active,
  });

  WalletItem copyWith({
    String? id,
    String? name,
    String? type,
    String? iconKey,
    int? saldo,
    bool? active,
  }) {
    return WalletItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      saldo: saldo ?? this.saldo,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'iconKey': iconKey,
        'saldo': saldo,
        'active': active ?? true,
      };

  factory WalletItem.fromJson(Map<String, dynamic> json) {
    return WalletItem(
      id: (json['id'] is String && (json['id'] as String).isNotEmpty)
          ? json['id'] as String
          : const Uuid().v4(),
      name: json['name'] ?? '',
      type: json['type'] ?? 'tunai',
      iconKey: json['iconKey'] ?? 'cash',
      saldo: json['saldo'] is int
          ? json['saldo'] as int
          : int.tryParse('${json['saldo']}') ?? 0,
      active: json['active'] is bool ? json['active'] as bool : true,
    );
  }
}

class DompetController extends GetxController {
  final _storage = GetStorage();

  var wallets = <WalletItem>[].obs;

  // Observable untuk masing-masing jenis dompet
  var saldoTunai = 0.obs;
  var saldoEWallet = 0.obs;
  var saldoBank = 0.obs;
  var totalSaldo = 0.obs;

  // Balance visibility toggle
  var isBalanceVisible = true.obs;

  String? _userId;

  static const _visibilityKey = 'balance_visible';

  @override
  void onInit() {
    super.onInit();
    _userId = _resolveInitialUserId();
    _loadWallets();
    _loadBalanceVisibility();
  }

  @override
  void onReady() {
    super.onReady();
    refreshSaldo();
  }

  String _sanitizeId(String? value) {
    final fallback = (value ?? '').trim();
    if (fallback.isEmpty) return 'default';
    final cleaned = fallback.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return cleaned.isEmpty ? 'default' : cleaned;
  }

  String _resolveInitialUserId() {
    try {
      final current = _storage.read('currentAccount');
      if (current is Map) {
        final book = current['bookName']?.toString();
        final user = current['userName']?.toString();
        final id = (book != null && book.trim().isNotEmpty)
            ? book
            : (user ?? 'default');
        return _sanitizeId(id);
      }
    } catch (_) {}
    return 'default';
  }

  String get _storageKey => 'wallets_${_sanitizeId(_userId)}';

  /// Ganti konteks user (misal setelah login/logout)
  void setUser(String? userId) {
    final safe = _sanitizeId(userId);
    if (_userId == safe) return;
    _userId = safe;
    _loadWallets();
  }

  /// Bersihkan state dompet di memori (tanpa menghapus storage user lain)
  void clearState() {
    wallets.clear();
    _recomputeTotalsFromWallets();
  }

  void _loadBalanceVisibility() {
    final stored = _storage.read<bool>(_visibilityKey);
    isBalanceVisible.value = stored ?? true;
  }

  void toggleBalanceVisibility() {
    isBalanceVisible.toggle();
    _storage.write(_visibilityKey, isBalanceVisible.value);
  }

  void _loadWallets() {
    List<dynamic>? raw = _storage.read<List<dynamic>>(_storageKey);

    // Legacy fallback: migrate old global key once
    if (raw == null) {
      raw = _storage.read<List<dynamic>>('wallets');
      if (raw != null) {
        try {
          _storage.remove('wallets');
        } catch (_) {}
      }
    }

    if (raw != null) {
      wallets.value = raw
          .map((e) => WalletItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      _persistWallets(); // ensure stored under new key
    } else {
      // Start with empty wallets for new accounts (no auto-seed)
      wallets.value = [];
    }
    _recomputeTotalsFromWallets();
  }

  void addWallet({
    required String name,
    required String type,
    required String iconKey,
    required int saldo,
  }) {
    final item = WalletItem(
      id: const Uuid().v4(),
      name: name,
      type: type,
      iconKey: iconKey,
      saldo: saldo,
      active: true,
    );
    wallets.add(item);
    _persistWallets();
    _recomputeTotalsFromWallets();
  }

  void updateWallet(
    int index, {
    String? name,
    String? type,
    String? iconKey,
    int? saldo,
    bool? active,
  }) {
    if (index < 0 || index >= wallets.length) return;
    wallets[index] = wallets[index].copyWith(
      name: name,
      type: type,
      iconKey: iconKey,
      saldo: saldo,
      active: active,
    );
    _persistWallets();
    _recomputeTotalsFromWallets();
  }

  void setWalletActive(int index, bool isActive) {
    if (index < 0 || index >= wallets.length) return;

    // Prevent deactivating the last active wallet
    final currentlyActiveCount =
        wallets.where((w) => (w.active ?? true)).length;
    final targetIsActive = wallets[index].active ?? true;
    if (!isActive && targetIsActive && currentlyActiveCount <= 1) {
      // Show feedback and do nothing
      try {
        Get.snackbar(
          'Tidak bisa dinonaktifkan',
          'Minimal 1 dompet harus aktif.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF5350),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 2),
        );
      } catch (_) {}
      return;
    }

    wallets[index] = wallets[index].copyWith(active: isActive);
    _persistWallets();
    _recomputeTotalsFromWallets();
  }

  void _persistWallets() {
    _storage.write(_storageKey, wallets.map((e) => e.toJson()).toList());
  }

  /// Find wallet index by id
  int indexOfWallet(String walletId) {
    return wallets.indexWhere((w) => w.id == walletId);
  }

  /// Adjust saldo by wallet id. Positive delta increases saldo, negative decreases.
  void adjustWalletSaldoById(String walletId, int delta) {
    final idx = indexOfWallet(walletId);
    if (idx < 0) return;
    final current = wallets[idx];
    final newSaldo = (current.saldo + delta).clamp(-2147483648, 2147483647);
    wallets[idx] = current.copyWith(saldo: newSaldo);
    _persistWallets();
    _recomputeTotalsFromWallets();
  }

  void _recomputeTotalsFromWallets() {
    int tunai = 0, ewallet = 0, bank = 0;
    for (final w in wallets) {
      if (!(w.active ?? true)) continue;
      switch (w.type.toLowerCase()) {
        case 'tunai':
          tunai += w.saldo;
          break;
        case 'e-wallet':
          ewallet += w.saldo;
          break;
        case 'rekening bank':
        case 'bank':
          bank += w.saldo;
          break;
      }
    }
    saldoTunai.value = tunai;
    saldoEWallet.value = ewallet;
    saldoBank.value = bank;
    totalSaldo.value = tunai + ewallet + bank;
  }

  /// Refresh saldo (untuk dipanggil dari luar)
  void refreshSaldo() {
    _loadWallets();
  }

  /// Format rupiah untuk tampilan
  String formatRupiah(int value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    final formatted = absValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return isNegative ? '-Rp$formatted' : 'Rp$formatted';
  }
}
