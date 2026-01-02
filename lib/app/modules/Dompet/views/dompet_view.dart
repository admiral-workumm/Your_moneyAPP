import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/modules/Dompet/controllers/dompet_controller.dart';
import 'package:your_money/app/modules/Dompet/views/add_dompet_view.dart';
import 'package:your_money/app/routes/app_routes.dart';

class DompetView extends GetView<DompetController> {
  final bool showBottomAndFab;
  const DompetView({super.key, this.showBottomAndFab = true});

  // THEME
  static const _blue = Color(0xFF1E88E5);
  static const _blueDark = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF90CAF9);
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ===== FIXED HEADER BOX =====
            Padding(
              padding: const EdgeInsets.fromLTRB(_side, 12, _side, 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_blue, _blueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Dompet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Uangmu saat ini',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Obx(() {
                          final visible = controller.isBalanceVisible.value;
                          return GestureDetector(
                            onTap: () => controller.toggleBalanceVisibility(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                visible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final visible = controller.isBalanceVisible.value;
                      return Text(
                        visible
                            ? controller
                                .formatRupiah(controller.totalSaldo.value)
                            : '••••••••',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Obx(() {
                      final count = controller.wallets
                          .where((w) => (w.active ?? true))
                          .length;
                      return Text(
                        '$count dompet aktif',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ===== FIXED TAMBAH DOMPET BUTTON =====
            Padding(
              padding: const EdgeInsets.fromLTRB(_side, 8, _side, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                  ),
                  onPressed: () => Get.toNamed(Routes.ADD_DOMPET),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Tambah dompet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            // ===== SCROLLABLE CARDS =====
            Expanded(
              child: Obx(() {
                final items = controller.wallets;
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada dompet, silakan tambah dompet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(_side, 8, _side, 0),
                  children: [
                    ..._buildGroupedCards(items),
                    SizedBox(height: _barH + (_fabSize / 2) + safe + 24),
                  ],
                );
              }),
            ),
          ],
        ),
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

extension on DompetView {
  List<Widget> _buildGroupedCards(List<WalletItem> items) {
    final byType = <String, List<MapEntry<int, WalletItem>>>{};
    for (final e in items.asMap().entries) {
      final w = e.value;
      byType.putIfAbsent(w.type.toLowerCase(), () => []).add(e);
    }

    final orderedKeys = <String>['tunai', 'e-wallet', 'rekening bank', 'bank'];
    final keys = [
      ...orderedKeys.where(byType.containsKey),
      ...byType.keys.where((k) => !orderedKeys.contains(k)),
    ];

    return [
      for (final key in keys)
        if (byType[key]!.isNotEmpty) ...[
          _WalletGroupCard(
            type: key,
            entries: byType[key]!,
            controller: controller,
          ),
          const SizedBox(height: 12),
        ]
    ];
  }
}

class _WalletGroupCard extends StatelessWidget {
  const _WalletGroupCard({
    required this.type,
    required this.entries,
    required this.controller,
  });

  final String type;
  final List<MapEntry<int, WalletItem>> entries;
  final DompetController controller;

  String _typeLabel(String key) {
    switch (key.toLowerCase()) {
      case 'e-wallet':
      case 'ewallet':
        return 'Dompet Digital';
      case 'rekening bank':
      case 'bank':
        return 'Rekening Bank';
      case 'tunai':
      default:
        return 'Dompet Fisik';
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = entries
        .where((e) => (e.value.active ?? true))
        .fold<int>(0, (p, e) => p + e.value.saldo);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _typeLabel(type),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  controller.formatRupiah(total).replaceAll('Rp', '').trim(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEAEAEA)),
          ...[
            for (int i = 0; i < entries.length; i++) ...[
              _WalletRow(
                index: entries[i].key,
                item: entries[i].value,
                controller: controller,
              ),
              if (i != entries.length - 1)
                const Divider(height: 1, color: Color(0xFFF2F2F2)),
            ]
          ],
        ],
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({
    required this.index,
    required this.item,
    required this.controller,
  });

  final int index;
  final WalletItem item;
  final DompetController controller;

  IconData _iconFor(String key) {
    switch (key) {
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'cash':
      default:
        return Icons.payments_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconBlue = const Color(0xFF1E88E5);
    final isActive = item.active ?? true;
    final textColor =
        isActive ? const Color(0xFF1A1A1A) : const Color(0xFF9E9E9E);

    return Dismissible(
      key: ValueKey('wallet_${index}_${item.name}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) {
            final canDisable =
                (controller.wallets.where((w) => (w.active ?? true)).length) >
                        1 ||
                    !isActive;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_rounded),
                    title: const Text('Edit Dompet'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      // Navigate directly to Form Dompet in EDIT mode
                      await Get.to(() => AddDompetView(
                            isEdit: true,
                            editIndex: index,
                            initialItem: item,
                          ));
                    },
                  ),
                  ListTile(
                    enabled: canDisable,
                    leading: Icon(
                      isActive
                          ? Icons.power_settings_new_rounded
                          : Icons.check_circle_rounded,
                    ),
                    title: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
                    subtitle: canDisable
                        ? null
                        : const Text('Minimal 1 dompet harus aktif'),
                    onTap: () {
                      if (!canDisable) return;
                      Navigator.pop(ctx);
                      controller.setWalletActive(index, !isActive);
                    },
                  ),
                ],
              ),
            );
          },
        );
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: const Color(0x1A000000),
        child: const Icon(Icons.swipe_left_rounded, color: Colors.black45),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Opacity(
              opacity: isActive ? 1 : 0.5,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconFor(item.iconKey), color: iconBlue, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (!isActive)
                    const Text(
                      'Nonaktif',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller
                      .formatRupiah(item.saldo)
                      .replaceAll('Rp', '')
                      .trim(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showEditDialog(BuildContext context, int index, WalletItem item,
    DompetController controller) async {
  final nameCtrl = TextEditingController(text: item.name);
  final saldoCtrl = TextEditingController(text: item.saldo.toString());

  final formKey = GlobalKey<FormState>();
  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Edit Dompet'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: saldoCtrl,
                  decoration: const InputDecoration(labelText: 'Saldo'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                    if (int.tryParse(v.replaceAll('.', '')) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              controller.updateWallet(
                index,
                name: nameCtrl.text.trim(),
                saldo: int.tryParse(saldoCtrl.text.replaceAll('.', '')) ?? 0,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

// ====================== WIDGET CARD DOMPET ======================
class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.name,
    required this.type,
    required this.saldo,
    required this.iconKey,
    required this.formatRupiah,
  });

  final String name;
  final String type;
  final int saldo;
  final String iconKey;
  final String Function(int) formatRupiah;

  @override
  Widget build(BuildContext context) {
    const iconBlue = Color(0xFF1E88E5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconFor(iconKey), color: iconBlue, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _typeLabel(type),
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiah(saldo).replaceAll('Rp', '').trim(),
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'IDR',
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'cash':
      default:
        return Icons.payments_rounded;
    }
  }

  String _typeLabel(String key) {
    switch (key.toLowerCase()) {
      case 'e-wallet':
      case 'ewallet':
        return 'Dompet Digital';
      case 'rekening bank':
      case 'bank':
        return 'Rekening Bank';
      case 'tunai':
      default:
        return 'Dompet Fisik';
    }
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
