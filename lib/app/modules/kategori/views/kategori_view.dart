import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/routes/app_routes.dart';

class KategoriView extends StatelessWidget {
  const KategoriView({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <_Category>[
      _Category('Makan', Icons.restaurant),
      _Category('Hiburan', Icons.sports_esports),
      _Category('Transportasi', Icons.directions_bus),
      _Category('Belanja', Icons.shopping_bag),
      _Category('Komunikasi', Icons.smartphone),
      _Category('Kesehatan', Icons.medical_services),
      _Category('Pendidikan', Icons.school),
      _Category('Home', Icons.home),
      _Category('Keluarga', Icons.groups),
      _Category('Lainnya', Icons.category),
    ];

    // Use consistent primary blue like other screens (Opsi / Dompet)
    const Color accent = Color(0xFF1E88E5);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: accent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back<void>(),
        ),
        title: const Text('Kategori', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.separated(
        itemCount: categories.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = categories[index];
          return ListTile(
            leading: Icon(item.icon, color: accent, size: 30),
            title: Text(
              item.label,
              style: const TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.drag_handle, color: accent),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              Get.toNamed(
                Routes.DETAIL_KATEGORI,
                arguments: {
                  'label': item.label,
                  'icon': item.icon,
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);
}
