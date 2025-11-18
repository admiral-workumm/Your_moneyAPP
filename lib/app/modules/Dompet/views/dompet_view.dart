import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/routes/app_routes.dart';

class DompetView extends StatefulWidget {
  final bool showBottomAndFab;
  const DompetView({super.key, this.showBottomAndFab = true});

  @override
  State<DompetView> createState() => _DompetViewState();
}

class _DompetViewState extends State<DompetView> {
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
            expandedHeight: 240, // fleksibel, cukup tinggi untuk teks
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
                          // bar atas: ikon kanan
                          Row(
                            children: [
                              const Expanded(child: SizedBox()),
                              IconButton(
                                onPressed: () {}, // TODO optional
                                icon: const Icon(Icons.menu_rounded,
                                    color: Colors.white),
                                splashRadius: 22,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
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
                          const Text(
                            'Rp0',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .2,
                            ),
                          ),
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
                    _WalletCard(
                      sectionTitle: 'Tunai',
                      title: 'Tunai',
                      trailing: 'Rp0',
                      leadingIcon: Icons.account_balance_wallet_rounded,
                      onAction: () {}, // TODO: opsi
                    ),
                    const SizedBox(height: 12),
                    _WalletCard(
                      sectionTitle: 'Kartu Debit',
                      title: 'BCA',
                      trailing: 'Rp0',
                      leadingIcon: Icons.credit_card_rounded,
                      onAction: () {},
                    ),
                    SizedBox(height: _barH + (_fabSize / 2) + safe + 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ===== FAB PENSIL =====
      floatingActionButtonLocation: widget.showBottomAndFab
          ? FloatingActionButtonLocation.centerDocked
          : null,
      floatingActionButton: widget.showBottomAndFab
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
      bottomNavigationBar: widget.showBottomAndFab
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
    this.actionIcon = Icons.more_vert,
    this.onAction,
  });

  final String sectionTitle;
  final String title;
  final String trailing;
  final IconData leadingIcon;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    const iconBlue = Color(0xFF1E88E5);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9E9E9), width: 1),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // strip header abu-abu
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        ),

        // ikon pojok kanan atas (aksi)
        Positioned(
          top: 6,
          right: 4,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              splashRadius: 18,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: onAction,
              icon: Icon(actionIcon, size: 20, color: Colors.black45),
              tooltip: 'Opsi',
            ),
          ),
        ),
      ],
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
