import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/modules/Dompet/controllers/dompet_controller.dart';
import 'package:your_money/app/routes/app_routes.dart';

class DompetView extends GetView<DompetController> {
  final bool showBottomAndFab;
  const DompetView({super.key, this.showBottomAndFab = true});

  // THEME
  static const _blue = Color(0xFF1E88E5);
  static const _blueDark = Color(0xFF1565C0);
  static const _bg = Color(0xFFF2F2F2);

  // LAYOUT
  static const double _side = 16;
  static const double _barH = 72;
  static const double _fabSize = 62;

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bg,

      // ===== BODY: SliverAppBar (anti overflow) + Sheet =====
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            expandedHeight: 240,
            backgroundColor: _blue,
            elevation: 0,
            flexibleSpace: LayoutBuilder(
              builder: (context, c) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_blue, _blueDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(_side, 12, _side, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            'Dompet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Uangmu Saat ini',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            return Text(
                              controller
                                  .formatRupiah(controller.totalSaldo.value),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .2,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ===== SHEET PUTIH ABU DENGAN RADIUS ATAS =====
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(_side, 16, _side, 16),
                child: Column(
                  children: [
                    Obx(() => _WalletCard(
                          sectionTitle: 'Tunai',
                          title: 'Tunai',
                          trailing: controller
                              .formatRupiah(controller.saldoTunai.value),
                          leadingIcon: Icons.account_balance_wallet_rounded,
                        )),
                    const SizedBox(height: 12),
                    Obx(() => _WalletCard(
                          sectionTitle: 'E-Wallet',
                          title: 'E-Wallet',
                          trailing: controller
                              .formatRupiah(controller.saldoEWallet.value),
                          leadingIcon: Icons.phone_android_rounded,
                        )),
                    const SizedBox(height: 12),
                    Obx(() => _WalletCard(
                          sectionTitle: 'Bank',
                          title: 'Bank',
                          trailing: controller
                              .formatRupiah(controller.saldoBank.value),
                          leadingIcon: Icons.credit_card_rounded,
                        )),
                    SizedBox(height: _barH + (_fabSize / 2) + safe + 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ===== FAB PENSIL =====
      floatingActionButtonLocation:
          showBottomAndFab ? FloatingActionButtonLocation.centerDocked : null,
      floatingActionButton: showBottomAndFab
          ? SizedBox(
              width: _fabSize,
              height: _fabSize,
              child: Material(
                color: _blue,
                elevation: 6,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    // TODO: aksi tambah/entry
                  },
                  child: const Center(
                    child:
                        Icon(Icons.edit_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
            )
          : null,

      // ===== BOTTOM BAR =====
      bottomNavigationBar: showBottomAndFab
          ? SizedBox(
              height: _barH + safe,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
                ),
                padding: EdgeInsets.only(bottom: safe),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomItem(
                        icon: Icons.menu_book_rounded,
                        label: 'Buku',
                        active: false,
                        onTap: () =>
                            Get.toNamed(Routes.SHELL, arguments: {'tab': 0})),
                    _BottomItem(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Dompet',
                        active: true,
                        onTap: () =>
                            Get.toNamed(Routes.SHELL, arguments: {'tab': 1})),
                    SizedBox(width: _fabSize),
                    _BottomItem(
                        icon: Icons.show_chart_rounded,
                        label: 'Grafik',
                        active: false,
                        onTap: () =>
                            Get.toNamed(Routes.SHELL, arguments: {'tab': 2})),
                    _BottomItem(
                        icon: Icons.settings_rounded,
                        label: 'Opsi',
                        active: false,
                        onTap: () =>
                            Get.toNamed(Routes.SHELL, arguments: {'tab': 3})),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

// ====================== WIDGET CARD DOMPET ======================
class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.sectionTitle,
    required this.title,
    required this.trailing,
    required this.leadingIcon,
  });

  final String sectionTitle;
  final String title;
  final String trailing;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    const iconBlue = Color(0xFF1E88E5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9E9E9), width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // strip header abu-abu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEDEDED),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                color: Color(0xFF6E6E6E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // isi kartu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE6F0FF)),
                  ),
                  child: Icon(leadingIcon, color: iconBlue, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  trailing,
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== WIDGET BOTTOM ITEM ======================
class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF1E88E5) : const Color(0xFF8C8C8C);
    final bg = active ? const Color(0x1A1E88E5) : Colors.transparent;

    return SizedBox(
      width: 70,
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
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
