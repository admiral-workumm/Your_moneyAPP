import 'package:flutter/material.dart';

class PengingatView extends StatefulWidget {
  const PengingatView({Key? key}) : super(key: key);

  @override
  State<PengingatView> createState() => _PengingatViewState();
}

class _PengingatViewState extends State<PengingatView> {
  int hours = 0;
  int minutes = 0;
  bool notifikasiLokal = false;
  String selectedPeriode = 'periode';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pengingat disimpan: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}'),
                  backgroundColor: const Color(0xFF1E88E5),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
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
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Time Picker Container
            GestureDetector(
              onTap: () => _showScrollableTimePicker(),
              child: Container(
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
                    _buildTimeBox(hours.toString().padLeft(2, '0')),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    // Minutes
                    _buildTimeBox(minutes.toString().padLeft(2, '0')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Notifikasi Lokal Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Notifikasi Lokal',
                  style: TextStyle(fontSize: 16),
                ),
                value: notifikasiLokal,
                onChanged: (value) {
                  setState(() {
                    notifikasiLokal = value;
                  });
                },
                activeColor: const Color(0xFF1E88E5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                subtitle: Text(
                  selectedPeriode,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF1E88E5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  _showPeriodeDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(String value) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5),
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
    );
  }

  void _showScrollableTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 350,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Text(
                    'Pilih Waktu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        color: Color(0xFF1E88E5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Time Picker Scrollable
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hours Picker
                  Expanded(
                    child: _buildScrollPicker(
                      itemCount: 24,
                      initialIndex: hours,
                      onChanged: (index) {
                        hours = index;
                      },
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Minutes Picker
                  Expanded(
                    child: _buildScrollPicker(
                      itemCount: 60,
                      initialIndex: minutes,
                      onChanged: (index) {
                        minutes = index;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollPicker({
    required int itemCount,
    required int initialIndex,
    required Function(int) onChanged,
  }) {
    final controller = FixedExtentScrollController(initialItem: initialIndex);
    
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 50,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          return Center(
            child: Text(
              index.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: index == initialIndex 
                    ? const Color(0xFF1E88E5)
                    : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPeriodeDialog() {
    final periodeOptions = ['Harian', 'Mingguan', 'Bulanan', 'Tahunan'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Periode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: periodeOptions.map((periode) {
            return ListTile(
              title: Text(periode),
              onTap: () {
                setState(() {
                  selectedPeriode = periode;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}