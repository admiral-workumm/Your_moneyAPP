import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryCard(title: label, icon: icon, accent: blue),
            const SizedBox(height: 16),
            _TransactionsCard(accent: blue, icon: icon, title: label),
          ],
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
                    Text('Keuangan drest',
                        style: TextStyle(color: Colors.grey[600])),
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
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('2',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Kuantitas', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('-Rp50,000',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.credit_card,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text('Total', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final dateKey = '2025-10-10';

    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Obx(() => Row(
                    children: [
                      AnimatedRotation(
                        turns: controller.isDateExpanded(dateKey) ? 0 : -0.25,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.arrow_drop_down,
                            color: accent, size: 20),
                      ),
                      const SizedBox(width: 4),
                      const Text('Min, 10/10',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('Pengeluaran : Rp100,000',
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500)),
                    ],
                  )),
            ),
          ),
          // Items - Collapsible
          Obx(() => AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: controller.isDateExpanded(dateKey)
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      _TxRow(
                          accent: accent,
                          icon: icon,
                          title: title,
                          subtitle: 'Mie Goreng',
                          amount: '-Rp20,000',
                          account: 'BCA'),
                      const Divider(height: 1),
                      _TxRow(
                          accent: accent,
                          icon: icon,
                          title: title,
                          subtitle: 'Burger',
                          amount: '-Rp30,000',
                          account: 'BCA'),
                    ],
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              )),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String account;
  const _TxRow({
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.account,
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
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(account, style: TextStyle(color: Colors.grey[600])),
            ],
          )
        ],
      ),
    );
  }
}
