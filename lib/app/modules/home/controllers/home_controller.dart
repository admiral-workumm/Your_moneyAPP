import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final _box = GetStorage();
  final accounts = <Map<String, String>>[].obs;

  var userName = 'User'.obs;
  var bookName = 'My Book'.obs;

  var saldoTotal = 1000000.obs;
  var pemasukan = 500000.obs;
  var pengeluaran = 200000.obs;

  var selectedDate = DateTime.now().obs;

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
