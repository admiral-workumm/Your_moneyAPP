import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/routes/app_routes.dart';
import 'package:your_money/app/data/categories.dart';

class KategoriView extends StatelessWidget {
  const KategoriView({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = kDefaultCategories;

    // Use consistent primary blue like other screens (Opsi / Dompet)
    const Color accent = Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: Colors.white,
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
                  'kategori': item.label,
                },
              );
            },
          );
        },
      ),
    );
  }
}
