import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/routes/app_routes.dart';

class OpsiView extends StatelessWidget {
  const OpsiView({super.key});
  // match colors used in DompetView
  static const _blue = Color(0xFF1E88E5);
  // Removed unused _bg constant (was Color(0xFFF2F2F2)) to satisfy lints.

  Widget _buildOption(
      BuildContext context, IconData icon, String label, VoidCallback? onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 110,
            height: 110,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: 52, color: _blue),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = _blue;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        automaticallyImplyLeading: false,
        title: const Text('Opsi', style: TextStyle(color: Colors.white)),
      ),
      extendBody: true,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 28,
                  crossAxisSpacing: 28,
                  childAspectRatio: 0.95,
                  children: [
                    _buildOption(context, Icons.add_alert_outlined, 'Pengingat',
                        () {
                      Get.toNamed(Routes.PENGINGAT);
                    }),
                    _buildOption(
                        context, Icons.attach_money_outlined, 'Anggaran', () {
                      Get.toNamed(Routes.ANGGARAN);
                    }),
                    _buildOption(context, Icons.segment_outlined, 'Kategori',
                        () {
                      Get.toNamed(Routes.KATEGORI);
                    }),
                    _buildOption(context, Icons.logout, 'Log Out', () {
                      Get.toNamed(Routes.BUKUMU);
                    }),
                  ],
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
          // FAB Pensil
          Positioned(
            bottom: 78 - 31 + 16,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 62,
                height: 62,
                child: Material(
                  color: Colors.white,
                  elevation: 12,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(Routes.CATAT_KEUANGAN);
                    },
                    child: Center(
                      child: Image.asset(
                        'assets/icons/Pencil.png',
                        width: 26,
                        height: 26,
                        color: _blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: Color(0xFFE9E9E9), width: 1)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                    icon: Icons.book_outlined,
                    label: 'Buku',
                    selected: false,
                    onTap: () =>
                        Get.toNamed(Routes.SHELL, arguments: {'tab': 0})),
                _NavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Dompet',
                    selected: false,
                    onTap: () =>
                        Get.toNamed(Routes.SHELL, arguments: {'tab': 1})),
                const SizedBox(width: 62 + 28),
                _NavItem(
                    icon: Icons.pie_chart_outline,
                    label: 'Grafik',
                    selected: false,
                    onTap: () =>
                        Get.toNamed(Routes.SHELL, arguments: {'tab': 2})),
                _NavItem(
                    icon: Icons.settings,
                    label: 'Opsi',
                    selected: true,
                    onTap: () =>
                        Get.toNamed(Routes.SHELL, arguments: {'tab': 3})),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1E88E5) : const Color(0xFF8C8C8C);
    final bg = selected ? const Color(0x1A1E88E5) : Colors.transparent;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
