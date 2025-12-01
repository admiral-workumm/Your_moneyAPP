import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:your_money/app/routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  final bool showBottomAndFab;
  const HomeScreen({super.key, this.showBottomAndFab = true});

  // Theme
  static const _blue = Color(0xFF1E88E5);
  static const _blueDark = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF90CAF9);
  static const _bg = Color(0xFFF2F2F2);
  static const _card = Colors.white;

  // Layout
  static const double headerH = 280;
  static const double saldoCardH = 180;
  static const double sidePad = 16;
  static const double sheetRadius = 24;

  // Bottom area (sesuai Figma)
  static const double _barH = 78; // tinggi plate putih
  static const double _fabSize = 62; // size FAB kotak-rounded

  @override
  Widget build(BuildContext context) {
    const double overlapY = saldoCardH * 0.45;
    const double sheetTop = headerH - sheetRadius;
    const double cardTop = sheetTop - overlapY;
    const double listTop = sheetTop + (saldoCardH - overlapY) + 16;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, _) {
            final bottomInset = MediaQuery.of(context).padding.bottom;
            final extraBottom = _barH + bottomInset + 32; // ruang list

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // HEADER
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: headerH,
                  child: _HeaderGradient(),
                ),
                // SHEET PUTIH
                Positioned.fill(
                  top: sheetTop,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(sheetRadius),
                        topRight: Radius.circular(sheetRadius),
                      ),
                    ),
                  ),
                ),
                // SALDO CARD
                const Positioned(
                  left: sidePad,
                  right: sidePad,
                  top: cardTop,
                  child: _SaldoCard(),
                ),
                // LIST (anti overflow)
                Positioned.fill(
                  top: listTop,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(sidePad, 0, sidePad, extraBottom),
                    children: const [
                      _TransactionGroup(
                        headerLeft: 'Min, 10/10',
                        headerRight: 'Pengeluaran : Rp200,000',
                        items: [
                          _TxnTile(
                            icon: Icons.videogame_asset,
                            title: 'GAME',
                            subtitle: 'Top up Valorant',
                            amount: '-Rp100,000',
                            bank: 'BCA',
                          ),
                          _TxnTile(
                            icon: Icons.videogame_asset,
                            title: 'GAME',
                            subtitle: 'Top up PUBG',
                            amount: '-Rp100,000',
                            bank: 'BCA',
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _TransactionGroup(
                        headerLeft: 'Min, 10/10',
                        headerRight: '',
                        items: [
                          _TxnTile(
                            icon: Icons.videogame_asset,
                            title: 'GAME',
                            subtitle: 'Top up Valorant',
                            amount: '-Rp100,000',
                            bank: 'BCA',
                          ),
                          _TxnTile(
                            icon: Icons.videogame_asset,
                            title: 'GAME',
                            subtitle: 'Top up PUBG',
                            amount: '-Rp100,000',
                            bank: 'BCA',
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),

                // ===== BOTTOM PLATE PUTIH (bukan BottomAppBar) =====
                if (showBottomAndFab)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomPlate(barH: _barH),
                  ),

                // ===== FAB KOTAK-ROUNDED DI TENGAH =====
                if (showBottomAndFab)
                  Positioned(
                    // naikin lagi 6px dari sebelumnya (+16 total dibanding setengah bar)
                    bottom: _barH - (_fabSize / 2) + 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: _fabSize,
                        height: _fabSize,
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
            );
          },
        ),
      ),
    );
  }
}

class _BottomPlate extends StatelessWidget {
  final double barH;
  const _BottomPlate({required this.barH});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      // SafeArea akan menambahkan padding bawah (inset) otomatis.
      child: SizedBox(
        height: barH, // ⬅️ TIDAK ditambah inset lagi
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE9E9E9), width: 1),
            ),
          ),
          // ⬅️ padding bawah normal saja (tanpa inset)
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _AssetNavItem(
                  asset: 'assets/icons/Book.png',
                  label: 'Buku',
                  active: true,
                ),
              ),
              Expanded(
                child: _AssetNavItem(
                  asset: 'assets/icons/Wallet.png',
                  label: 'Dompet',
                  onTap: () => Get.toNamed(Routes.SHELL, arguments: {'tab': 1}),
                ),
              ),

              // Gap tengah elastis ≈ ukuran FAB + margin
              SizedBox(width: HomeScreen._fabSize + 28),

              Expanded(
                child: _AssetNavItem(
                  asset: 'assets/icons/Pie Chart.png',
                  label: 'Grafik',
                  onTap: () => Get.toNamed(Routes.SHELL, arguments: {'tab': 2}),
                ),
              ),
              Expanded(
                child: _AssetNavItem(
                  asset: 'assets/icons/Settings.png',
                  label: 'Opsi',
                  onTap: () => Get.toNamed(Routes.SHELL, arguments: {'tab': 3}),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== HEADER ==================
class _HeaderGradient extends StatelessWidget {
  const _HeaderGradient();

  @override
  Widget build(BuildContext context) {
    final double safeTop = MediaQuery.of(context).padding.top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [HomeScreen._blue, HomeScreen._blueDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.fromLTRB(20, safeTop + 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HeaderTopRow(),
              SizedBox(height: 14),
              Text('Hi,Drest',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Text('Keuangan Drest',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.1)),
            ],
          ),
        ),
        const Positioned(
            right: -60,
            top: -70,
            child:
                _CircleBubble(size: 260, opacityStart: .12, opacityEnd: .28)),
        const Positioned(
            right: 24,
            top: 8,
            child:
                _CircleBubble(size: 120, opacityStart: .10, opacityEnd: .20)),
        const Positioned(
            left: -40,
            top: -60,
            child:
                _CircleBubble(size: 160, opacityStart: .06, opacityEnd: .14)),
      ],
    );
  }
}

class _HeaderTopRow extends StatelessWidget {
  const _HeaderTopRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
            child: Text('Your money',
                style: TextStyle(
                    color: Colors.white70, fontSize: 12, letterSpacing: .2))),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderIcon({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}

class _CircleBubble extends StatelessWidget {
  final double size, opacityStart, opacityEnd;
  const _CircleBubble({
    required this.size,
    required this.opacityStart,
    required this.opacityEnd,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(opacityStart),
              HomeScreen._blueLight.withOpacity(opacityEnd),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

// ================== SALDO CARD ==================
class _SaldoCard extends StatelessWidget {
  const _SaldoCard();

  String _rupiah(num v) {
    final s = v.toStringAsFixed(0);
    return s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    return Container(
      height: HomeScreen.saldoCardH,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 255, 255, 255)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Total Saldo & Date Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Saldo Section (KIRI)
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Saldo',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp${_rupiah(c.saldoTotal.value)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Date Picker (KANAN ATAS)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => c.previousMonth(),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Obx(
                        () => Text(
                          _formatMonth(c.selectedDate.value),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => c.nextMonth(),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Pemasukan & Pengeluaran Row
            Row(
              children: [
                // Pemasukan
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp${_rupiah(c.pemasukan.value)}',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.arrow_upward,
                                size: 12, color: Colors.black54),
                            SizedBox(width: 4),
                            Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Pengeluaran
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp${_rupiah(c.pengeluaran.value)}',
                          style: const TextStyle(
                            color: Color(0xFFF44336),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.arrow_downward,
                                size: 12, color: Colors.black54),
                            SizedBox(width: 4),
                            Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ================== LIST GROUP ==================
class _TransactionGroup extends StatelessWidget {
  final String headerLeft;
  final String headerRight;
  final List<_TxnTile> items;
  const _TransactionGroup({
    required this.headerLeft,
    required this.headerRight,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    const stripBg = Color(0xFFF0F0F0);
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: HomeScreen._card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: stripBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.expand_more, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(headerLeft,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12)),
                const Spacer(),
                if (headerRight.isNotEmpty)
                  Text(headerRight,
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          for (int i = 0; i < items.length; i++) ...[
            if (i != 0) const Divider(height: 0),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, amount, bank;
  const _TxnTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.bank,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: HomeScreen._blue.withOpacity(.10),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: HomeScreen._blue, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(amount,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(bank, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// ================== NAV ITEM ==================
class _AssetNavItem extends StatelessWidget {
  final String asset;
  final String label;
  final bool active;
  final VoidCallback? onTap; // ⬅️ baru

  const _AssetNavItem({
    required this.asset,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = active ? HomeScreen._blue : const Color(0xFF9E9E9E);
    final Color bg =
        active ? HomeScreen._blue.withOpacity(.10) : Colors.transparent;

    return InkWell(
      // ⬅️ supaya bisa tap
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
            child: Image.asset(asset, width: 20, height: 20, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? HomeScreen._blue : const Color(0xFF8A8A8A),
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
