import 'package:get/get.dart';
import 'package:your_money/app/data/models/transaksi.dart';
import 'package:your_money/app/data/services/transaksi_service.dart';

class DompetController extends GetxController {
  final _transaksiService = TransaksiService();

  // Observable untuk masing-masing jenis dompet
  var saldoTunai = 0.obs;
  var saldoEWallet = 0.obs;
  var saldoBank = 0.obs;
  var totalSaldo = 0.obs;

  // List transaksi untuk debugging
  var transaksiList = <Transaksi>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSaldo();
  }

  @override
  void onReady() {
    super.onReady();
    refreshSaldo();
  }

  /// Load saldo dari semua transaksi
  void loadSaldo() {
    print('[DompetController] Loading saldo...');

    final allTransaksi = _transaksiService.getAllTransaksi();
    transaksiList.value = allTransaksi;

    print('[DompetController] Total transaksi: ${allTransaksi.length}');

    // Reset semua saldo
    saldoTunai.value = 0;
    saldoEWallet.value = 0;
    saldoBank.value = 0;

    // Hitung saldo per jenis dompet
    for (var txn in allTransaksi) {
      final jumlah = int.tryParse(txn.jumlah.replaceAll('.', '')) ?? 0;
      final isIncome = txn.tipe == 'pemasukan';
      final amount = isIncome ? jumlah : -jumlah;

      switch (txn.jenisDompet.toLowerCase()) {
        case 'tunai':
          saldoTunai.value += amount;
          break;
        case 'e-wallet':
          saldoEWallet.value += amount;
          break;
        case 'bank':
          saldoBank.value += amount;
          break;
      }
    }

    // Hitung total saldo
    totalSaldo.value = saldoTunai.value + saldoEWallet.value + saldoBank.value;

    print('[DompetController] Saldo Tunai: ${saldoTunai.value}');
    print('[DompetController] Saldo E-Wallet: ${saldoEWallet.value}');
    print('[DompetController] Saldo Bank: ${saldoBank.value}');
    print('[DompetController] Total Saldo: ${totalSaldo.value}');
  }

  /// Refresh saldo (untuk dipanggil dari luar)
  void refreshSaldo() {
    print('[DompetController] Refreshing saldo...');
    loadSaldo();
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
