import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../onboarding/controllers/atur_buku_controller.dart';

class OnboardAturBukuView extends GetView<AturBukuController> {
  const OnboardAturBukuView({super.key});

  InputDecoration get _decoration => InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        hintText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF90CAF9)),
        ),
      );

  @override
  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1E88E5);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final hasKeyboard = bottomInset > 0;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                left: 32,
                right: 32,
                top: hasKeyboard ? 12 : 36,
                bottom: (hasKeyboard ? 12 : 20) + bottomInset,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: hasKeyboard
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ilustrasi
                    Center(
                      child: Image.asset(
                        'assets/images/book_pencil.png',
                        width: 116,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Judul
                    const Text(
                      'Atur Bukumu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Form fields
                    TextField(
                      controller: controller.namaPenggunaC,
                      decoration:
                          _decoration.copyWith(hintText: 'Nama Pengguna'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.namaBukuC,
                      decoration: _decoration.copyWith(hintText: 'Nama Buku'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.kartuDebitC,
                      decoration:
                          _decoration.copyWith(hintText: 'Nama Kartu Debit'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    Obx(
                      () => DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: controller.selectedCurrency.value,
                        items: controller.currencies
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedCurrency.value = val;
                          }
                        },
                        icon: const Icon(Icons.arrow_drop_down),
                        decoration: _decoration.copyWith(hintText: 'Mata Uang'),
                      ),
                    ),

                    SizedBox(height: hasKeyboard ? 16 : 28),

                    // Tombol bulat
                    Center(
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            shape: const CircleBorder(),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.arrow_forward,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
