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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Opsi', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
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
                _buildOption(context, Icons.attach_money_outlined, 'Anggaran',
                    () {
                  Get.toNamed(Routes.ANGGARAN);
                }),
                _buildOption(context, Icons.segment_outlined, 'Kategori', () {
                  Get.toNamed(Routes.KATEGORI);
                }),
                _buildOption(context, Icons.logout, 'Log Out', () {
                  Get.toNamed(Routes.BUKUMU); // Navigasi ke Bukumu
                }),
              ],
            ),
            // fill remaining space so options stay at top like screenshot
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: action for FAB
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.edit, color: primary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left side (2 items)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                        icon: Icons.book_outlined,
                        label: 'Buku',
                        selected: false),
                    _NavItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Dompet',
                        selected: false),
                  ],
                ),
              ),

              // spacer for FAB
              const SizedBox(width: 56),

              // Right side (2 items)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                        icon: Icons.pie_chart_outline,
                        label: 'Grafik',
                        selected: false),
                    _NavItem(
                        icon: Icons.settings, label: 'Opsi', selected: true),
                  ],
                ),
              ),
            ],
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

  const _NavItem(
      {required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1E88E5) : Colors.grey[500];
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}
