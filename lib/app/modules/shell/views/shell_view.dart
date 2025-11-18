import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_view.dart';
import '../../Dompet/views/dompet_view.dart';
import '../../grafik/views/grafik_view.dart';
import '../../opsi/views/opsi_view.dart';
import '../controllers/shell_controller.dart';

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  static const double _barH = 78;
  static const double _fabSize = 62;

  @override
  Widget build(BuildContext context) {
    // handle incoming argument once (if caller asked Shell to open a specific tab)
    Future.microtask(() => controller.setInitialFromArgs(Get.arguments));

    return Obx(() {
      final idx = controller.tabIndex.value;
      return Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            // IndexedStack keeps state of each tab
            IndexedStack(
              index: idx,
              children: const [
                HomeScreen(showBottomAndFab: false),
                DompetView(showBottomAndFab: false),
                GrafikView(),
                OpsiView(),
              ],
            ),

            // shared bottom plate
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: _barH,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          top: BorderSide(color: Color(0xFFE9E9E9), width: 1)),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: _AssetNavItem(
                                asset: 'assets/icons/Book.png',
                                label: 'Buku',
                                active: idx == 0,
                                onTap: () => controller.changeTab(0))),
                        Expanded(
                            child: _AssetNavItem(
                                asset: 'assets/icons/Wallet.png',
                                label: 'Dompet',
                                active: idx == 1,
                                onTap: () => controller.changeTab(1))),
                        SizedBox(width: _fabSize + 28),
                        Expanded(
                            child: _AssetNavItem(
                                asset: 'assets/icons/Pie Chart.png',
                                label: 'Grafik',
                                active: idx == 2,
                                onTap: () => controller.changeTab(2))),
                        Expanded(
                            child: _AssetNavItem(
                                asset: 'assets/icons/Settings.png',
                                label: 'Opsi',
                                active: idx == 3,
                                onTap: () => controller.changeTab(3))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // center FAB
            Positioned(
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
                      onTap: () => Get.toNamed('/catat-keuangan'),
                      child: Center(
                        child: Image.asset('assets/icons/Pencil.png',
                            width: 26,
                            height: 26,
                            color: const Color(0xFF1E88E5)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AssetNavItem extends StatelessWidget {
  final String asset;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const _AssetNavItem(
      {required this.asset,
      required this.label,
      this.active = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        active ? const Color(0xFF1E88E5) : const Color(0xFF9E9E9E);
    final Color bg =
        active ? const Color(0xFF1E88E5).withOpacity(.10) : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Image.asset(asset, width: 20, height: 20, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: active
                      ? const Color(0xFF1E88E5)
                      : const Color(0xFF8A8A8A),
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  height: 1.1)),
        ],
      ),
    );
  }
}
