import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:your_money/app/data/models/transaksi.dart';
import 'package:your_money/app/data/services/transaksi_service.dart';

class HomeController extends GetxController {
  final _box = GetStorage();
  final accounts = <Map<String, String>>[].obs;
  final _transaksiService = TransaksiService();

  var userName = 'User'.obs;
  var bookName = 'My Book'.obs;

  var saldoTotal = 0.obs;
  var pemasukan = 0.obs;
  var pengeluaran = 0.obs;

  var selectedDate = DateTime.now().obs;

  // List untuk menampilkan transaksi bulan ini
  var transaksiList = <Transaksi>[].obs;

  static const _accountsKey = 'accounts';
  static const _currentKey = 'currentAccount';

  @override
  void onInit() {
    super.onInit();
    _loadAccounts();

    // If onboarding passes data, persist and set current
    final arguments = Get.arguments;
    if (arguments != null &&
        (arguments['userName'] != null || arguments['bookName'] != null)) {
      final acc = <String, String>{
        'userName': (arguments['userName'] ?? 'User').toString(),
        'bookName': (arguments['bookName'] ?? 'My Book').toString(),
      };
      addOrUpdateAccount(acc);
      return;
    }

    // Otherwise try to load last used account
    _loadCurrentAccount();

    // Load transaksi
    _loadTransaksi();

    // Listen perubahan tanggal
    ever(selectedDate, (_) {
      _loadTransaksi();
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh transaksi saat page ready/resume
    refreshTransaksi();
  }

  /// Load transaksi bulan yang dipilih
  void _loadTransaksi() {
    final bulan = selectedDate.value;
    print(
        '[HomeController] Loading transaksi for ${bulan.year}-${bulan.month}');

    transaksiList.assignAll(_transaksiService.getTransaksiByMonth(bulan));

    print('[HomeController] Loaded ${transaksiList.length} transaksi');

    // Hitung ulang saldo
    pemasukan.value = _transaksiService.getTotalPemasukanMonth(bulan);
    pengeluaran.value = _transaksiService.getTotalPengeluaranMonth(bulan);
    saldoTotal.value = pemasukan.value - pengeluaran.value;

    print(
        '[HomeController] Pemasukan: ${pemasukan.value}, Pengeluaran: ${pengeluaran.value}');
  }

  /// Refresh transaksi (dipanggil saat page resume)
  void refreshTransaksi() {
    _loadTransaksi();
  }

  void _loadAccounts() {
    final stored = _box.read(_accountsKey);
    if (stored is List) {
      accounts.assignAll(stored
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString()))));
    }
  }

  void _persistAccounts() {
    _box.write(_accountsKey, accounts);
  }

  void _loadCurrentAccount() {
    final current = _box.read(_currentKey);
    if (current is Map) {
      userName.value = current['userName']?.toString() ?? 'User';
      bookName.value = current['bookName']?.toString() ?? 'My Book';
      return;
    }

    if (accounts.isNotEmpty) {
      setCurrentAccount(accounts.first);
    }
  }

  void setCurrentAccount(Map<String, String> account) {
    userName.value = account['userName'] ?? 'User';
    bookName.value = account['bookName'] ?? 'My Book';
    _box.write(_currentKey, account);
  }

  void addOrUpdateAccount(Map<String, String> account) {
    // replace if same bookName; otherwise append
    final idx = accounts.indexWhere((e) =>
        e['bookName']?.toLowerCase() == account['bookName']?.toLowerCase());
    if (idx >= 0) {
      accounts[idx] = account;
    } else {
      accounts.add(account);
    }
    _persistAccounts();
    setCurrentAccount(account);
  }

  void deleteAccount(Map<String, String> account) {
    accounts.removeWhere((e) =>
        e['bookName']?.toLowerCase() == account['bookName']?.toLowerCase());
    _persistAccounts();

    final current = _box.read(_currentKey);
    final wasCurrent = current is Map &&
        current['bookName']?.toString().toLowerCase() ==
            account['bookName']?.toLowerCase();

    if (accounts.isNotEmpty) {
      if (wasCurrent) {
        setCurrentAccount(accounts.first);
      }
    } else {
      userName.value = 'User';
      bookName.value = 'My Book';
      _box.remove(_currentKey);
    }
  }

  void previousMonth() {
    selectedDate.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month - 1,
    );
  }

  void nextMonth() {
    selectedDate.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month + 1,
    );
  }
}
