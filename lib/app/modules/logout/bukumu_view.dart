import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BukumuView extends StatelessWidget {
  const BukumuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Buku dengan Pensil
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Buku
                    Icon(
                      Icons.menu_book_rounded,
                      size: 80,
                      color: Colors.grey[800],
                    ),
                    // Pensil di pojok kanan atas
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Transform.rotate(
                        angle: 0.5,
                        child: Icon(
                          Icons.edit,
                          size: 35,
                          color: Colors.blue[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Text Bukumu
              const Text(
                'Bukumu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 48),
              // Keuangan drest button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to Keuangan drest
                    print('Keuangan drest tapped');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.attach_money,
                            color: Colors.blue[600],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Keuangan drest',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Tambah Akun button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to Tambah Akun
                    print('Tambah Akun tapped');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.blue[600],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Tambah Akun',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
