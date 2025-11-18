import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CatatKeuanganController extends GetxController {
  final jumlahC = TextEditingController();
  final ketC = TextEditingController();
  final tanggalC = TextEditingController();
  final jenisDompet = RxnString();
  final kategori = RxnString(); // id/label kategori terpilih

  final dompetOptions = const ['Tunai', 'E-Wallet', 'Bank'];

  @override
  void onClose() {
    jumlahC.dispose();
    ketC.dispose();
    tanggalC.dispose();
    super.onClose();
  }

  void pickDate(BuildContext ctx) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: ctx,
      initialDate: now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      tanggalC.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void onSimpan() {
    // TODO: validasi & simpan
    Get.back();
  }
}

class CatatKeuanganView extends GetView<CatatKeuanganController> {
  const CatatKeuanganView({super.key});

  // Warna & gaya agar match Figma
  static const _blue = Color(0xFF1E88E5);
  static const _blueDark = Color(0xFF1565C0);
  static const _bg = Color(0xFFF7F7F7);
  static const _fieldFill = Color(0xFFF5F5F5);
  static const _border = Color(0xFFE0E0E0);
  static const _muted = Color(0xFF6C6C6C);

  InputDecoration get _decoration => const InputDecoration(
        isDense: true,
        filled: true,
        fillColor: _fieldFill,
        hintText: '',
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _border),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _blue),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      );

  TextStyle get _label => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: _bg,
          body: Column(
            children: [
              // HEADER GRADIENT + APPBAR + TAB
              _Header(),
              // KONTEN
              Expanded(
                child: TabBarView(
                  children: [
                    _FormPengeluaran(
                        controller: controller,
                        decoration: _decoration,
                        labelStyle: _label),
                    _FormPemasukan(
                        controller: controller,
                        decoration: _decoration,
                        labelStyle: _label),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar custom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Catat Keuangan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Get.find<CatatKeuanganController>().onSimpan(),
                    icon: const Icon(Icons.check, color: Colors.white),
                  ),
                ],
              ),
            ),
            // TabBar + bottom divider tipis abu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor:
                    Colors.white, // di header biru akan tampak putih
                indicatorWeight: 2,
                labelPadding: EdgeInsets.zero,
                labelColor: Colors.white,
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                unselectedLabelColor: Color(0xFFE0E0E0),
                unselectedLabelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: 'Pengeluaran'),
                  Tab(text: 'Pemasukan'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormPengeluaran extends StatelessWidget {
  const _FormPengeluaran({
    required this.controller,
    required this.decoration,
    required this.labelStyle,
  });

  final CatatKeuanganController controller;
  final InputDecoration decoration;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jumlah (Rp)', style: labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: controller.jumlahC,
            keyboardType: TextInputType.number,
            decoration: decoration.copyWith(hintText: 'Masukan jumlah'),
          ),
          const SizedBox(height: 16),
          Text('Keterangan', style: labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: controller.ketC,
            decoration: decoration.copyWith(hintText: 'Masukan keterangan'),
          ),
          const SizedBox(height: 16),
          Text('Jenis Dompet', style: labelStyle),
          const SizedBox(height: 8),
          Obx(() {
            return DropdownButtonFormField<String>(
              value: controller.jenisDompet.value,
              items: controller.dompetOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => controller.jenisDompet.value = v,
              decoration: decoration.copyWith(
                  hintText: 'Pilih jenis dompet',
                  suffixIcon: const Icon(Icons.arrow_drop_down)),
            );
          }),
          const SizedBox(height: 16),
          Text('Tanggal', style: labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: controller.tanggalC,
            readOnly: true,
            onTap: () => controller.pickDate(context),
            decoration: decoration.copyWith(
              hintText: 'Pilih tanggal',
              suffixIcon: const Icon(Icons.calendar_month_outlined),
            ),
          ),
          const SizedBox(height: 20),
          Text('Kategori', style: labelStyle),
          const SizedBox(height: 12),
          _KategoriGrid(controller: controller),
        ],
      ),
    );
  }
}

class _FormPemasukan extends StatelessWidget {
  const _FormPemasukan({
    required this.controller,
    required this.decoration,
    required this.labelStyle,
  });

  final CatatKeuanganController controller;
  final InputDecoration decoration;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    // Struktur sama, biar konsisten dengan Figma
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jumlah (Rp)', style: labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: controller.jumlahC,
            keyboardType: TextInputType.number,
            decoration: decoration.copyWith(hintText: 'Masukan jumlah'),
          ),
          const SizedBox(height: 16),
          Text('Keterangan', style: labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: controller.ketC,
            decoration: decoration.copyWith(hintText: 'Masukan keterangan'),
          ),
          const SizedBox(height: 16),
          Text('Jenis Dompet', style: labelStyle),
          const SizedBox(height: 8),
          Obx(() {
            return DropdownButtonFormField<String>(
              value: controller.jenisDompet.value,
              items: controller.dompetOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => controller.jenisDompet.value = v,
              decoration: decoration.copyWith(
                  hintText: 'Pilih jenis dompet',
                  suffixIcon: const Icon(Icons.arrow_drop_down)),
            );
          }),
          const SizedBox(height: 16),
          Text('Tanggal', style: labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: controller.tanggalC,
            readOnly: true,
            onTap: () => controller.pickDate(context),
            decoration: decoration.copyWith(
              hintText: 'Pilih tanggal',
              suffixIcon: const Icon(Icons.calendar_month_outlined),
            ),
          ),
          const SizedBox(height: 20),
          Text('Kategori', style: labelStyle),
          const SizedBox(height: 12),
          _KategoriGrid(controller: controller),
        ],
      ),
    );
  }
}

class _KategoriGrid extends StatelessWidget {
  const _KategoriGrid({required this.controller});
  final CatatKeuanganController controller;

  static const _blue = Color(0xFF1E88E5);
  static const _muted = Color(0xFF6C6C6C);

  @override
  Widget build(BuildContext context) {
    // Susunan ikon mengikuti screenshot: 3 kolom x 3 (bisa diubah sesuai kebutuhan)
    final items = <_Cat>{
      _Cat('Makan', Icons.restaurant),
      _Cat('Game', Icons.sports_esports),
      _Cat('Hadiah', Icons.card_giftcard),
      _Cat('Minuman', Icons.local_cafe),
      _Cat('Transport', Icons.directions_bus),
      _Cat('Gadget', Icons.smartphone),
      _Cat('Pribadi', Icons.person_outline),
      _Cat('Pendidikan', Icons.school),
      _Cat('Lainnya', Icons.category_outlined),
    }.toList();

    return Obx(() {
      return Wrap(
        spacing: 22,
        runSpacing: 18,
        children: items.map((e) {
          final selected = controller.kategori.value == e.key;
          return InkWell(
            onTap: () => controller.kategori.value = e.key,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                e.icon,
                size: 36,
                color: selected ? _blue : _blue,
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _Cat {
  final String key;
  final IconData icon;
  _Cat(this.key, this.icon);
}
