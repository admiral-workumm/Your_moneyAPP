import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PengingatView extends StatefulWidget {
  const PengingatView({Key? key}) : super(key: key);

  @override
  State<PengingatView> createState() => _PengingatViewState();
}

class _PengingatViewState extends State<PengingatView> {
  int hours = 0;
  int minutes = 0;
  bool notifikasiLokal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Pengingat',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              // Handle save action
              print('Pengingat disimpan: $hours:$minutes');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengingat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            // Time Picker Container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hours
                  _buildTimeBox(hours.toString().padLeft(2, '0'), true),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Minutes
                  _buildTimeBox(minutes.toString().padLeft(2, '0'), false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Notifikasi Lokal Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: const Text(
                  'Notifikasi Lokal',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Switch(
                  value: notifikasiLokal,
                  onChanged: (value) {
                    setState(() {
                      notifikasiLokal = value;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              ),
            ),
            const SizedBox(height: 10),
            // Pilih Periode
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: const Text(
                  'Pilih Periode',
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: const Text(
                  'periode',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.blue,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                onTap: () {
                  // Handle periode selection
                  _showPeriodeDialog();
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[50],
    );
  }

  Widget _buildTimeBox(String value, bool isHour) {
    return GestureDetector(
      onTap: () => _showTimePicker(isHour),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showTimePicker(bool isHour) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHour ? 'Pilih Jam' : 'Pilih Menit'),
        content: SizedBox(
          height: 200,
          width: 100,
          child: ListView.builder(
            itemCount: isHour ? 24 : 60,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  index.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  setState(() {
                    if (isHour) {
                      hours = index;
                    } else {
                      minutes = index;
                    }
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPeriodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Periode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Harian'),
              onTap: () {
                Navigator.pop(context);
                // Handle selection
              },
            ),
            ListTile(
              title: const Text('Mingguan'),
              onTap: () {
                Navigator.pop(context);
                // Handle selection
              },
            ),
            ListTile(
              title: const Text('Bulanan'),
              onTap: () {
                Navigator.pop(context);
                // Handle selection
              },
            ),
          ],
        ),
      ),
    );
  }
}
