import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/detail_kategori_controller.dart';

class DetailKategoriView extends GetView<DetailKategoriController> {
  const DetailKategoriView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final String label = args?['label'] as String? ?? 'Kategori';
    final IconData icon = args?['icon'] as IconData? ?? Icons.category;
    const Color blue = Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back<void>(),
        ),
        title: const Text('Detail Kategori',
            style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _SummaryCard(title: label, icon: icon, accent: blue),
              const SizedBox(height: 16),
              _FilterButtons(accent: blue),
              const SizedBox(height: 16),
              _TransactionsCard(accent: blue, icon: icon, title: label),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends GetView<DetailKategoriController> {
  final String title;
  final IconData icon;
  final Color accent;
  const _SummaryCard(
      {required this.title, required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          'Total ${controller.totalTransactions} transaksi',
                          style: TextStyle(color: Colors.grey[600]),
                        )),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: accent,
                child: Icon(icon, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          // Month Navigation
          Obx(() => Row(
                children: [
                  InkWell(
                    onTap: controller.previousMonth,
                    child: Icon(Icons.chevron_left,
                        size: 20, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 2),
                  Text(controller.formattedMonth,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 2),
                  InkWell(
                    onTap: controller.nextMonth,
                    child: Icon(Icons.chevron_right,
                        size: 20, color: Colors.grey[700]),
                  ),
                  const Spacer(),
                ],
              )),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.totalTransactions.toString(),
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('Kuantitas',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  // Display based on selected type
                  if (controller.selectedType.value == 'semua')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            'Rp${(controller.totalPemasukan + controller.totalPengeluaran).toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.')}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.credit_card,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text('Total Semua',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    )
                  else if (controller.selectedType.value == 'pemasukan')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            'Rp${controller.totalPemasukan.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.')}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_upward,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            Text('Total Pemasukan',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            'Rp${controller.totalPengeluaran.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.')}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_downward,
                                size: 16, color: Colors.red),
                            const SizedBox(width: 6),
                            Text('Total Pengeluaran',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                ],
              )),
        ],
      ),
    );
  }
}

class _FilterButtons extends GetView<DetailKategoriController> {
  final Color accent;
  const _FilterButtons({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _FilterButton(
                label: 'Semua',
                isSelected: controller.selectedType.value == 'semua',
                onTap: () => controller.setSelectedType('semua'),
                color: Colors.grey[700]!,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterButton(
                label: 'Pemasukan',
                isSelected: controller.selectedType.value == 'pemasukan',
                onTap: () => controller.setSelectedType('pemasukan'),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterButton(
                label: 'Pengeluaran',
                isSelected: controller.selectedType.value == 'pengeluaran',
                onTap: () => controller.setSelectedType('pengeluaran'),
                color: Colors.red,
              ),
            ),
          ],
        ));
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final double? amount;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterButton({
    required this.label,
    this.amount,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            if (amount != null) ...[
              const SizedBox(height: 4),
              Text(
                'Rp${amount!.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.')}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransactionsCard extends GetView<DetailKategoriController> {
  final Color accent;
  final IconData icon;
  final String title;
  const _TransactionsCard(
      {required this.accent, required this.icon, required this.title});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final formatter = DateFormat('EEE, dd/MM', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateStr;
    }
  }

  double _calculateDayTotal(List transaksi) {
    double total = 0;
    for (var txn in transaksi) {
      final amount =
          double.tryParse(txn.jumlah.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      total += amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.filteredTransactions.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              controller.selectedType.value == 'semua'
                  ? 'Belum ada transaksi untuk kategori ini'
                  : 'Belum ada transaksi ${controller.selectedType.value}',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
        );
      }

      return Column(
        children: controller.filteredTransactions.entries.map((entry) {
          final dateKey = entry.key;
          final transactions = entry.value;
          final dayTotal = _calculateDayTotal(transactions);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header bar - Clickable
                  InkWell(
                    onTap: () => controller.toggleDateExpansion(dateKey),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Obx(() => AnimatedRotation(
                                turns: controller.isDateExpanded(dateKey)
                                    ? 0
                                    : -0.25,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(Icons.arrow_drop_down,
                                    color: accent, size: 20),
                              )),
                          const SizedBox(width: 4),
                          Text(_formatDate(dateKey),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(
                              'Rp${dayTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.')}',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  // Items - Collapsible
                  Obx(() => AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: controller.isDateExpanded(dateKey)
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Column(
                            children: List.generate(
                              transactions.length,
                              (index) {
                                final txn = transactions[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        index < transactions.length - 1 ? 8 : 0,
                                  ),
                                  child: Column(
                                    children: [
                                      _TxRow(
                                        accent: accent,
                                        icon: icon,
                                        title: title,
                                        subtitle: txn.keterangan,
                                        amount: txn.tipe == 'pemasukan'
                                            ? '+Rp${txn.jumlah}'
                                            : '-Rp${txn.jumlah}',
                                        account: txn.jenisDompet,
                                        isIncome: txn.tipe == 'pemasukan',
                                      ),
                                      if (index < transactions.length - 1)
                                        const Divider(height: 1),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        secondChild: const SizedBox.shrink(),
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _TxRow extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String account;
  final bool isIncome;
  const _TxRow({
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.account,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: accent.withOpacity(0.15),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: accent,
                child: Icon(icon, size: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(account, style: TextStyle(color: Colors.grey[600])),
            ],
          )
        ],
      ),
    );
  }
}
