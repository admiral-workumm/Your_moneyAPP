import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/modules/onboarding/controllers/onboarding_controller.dart';

class OnboardMulaiView extends GetView<OnboardingController> {
  const OnboardMulaiView({super.key});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1E88E5);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          // Padding sedikit longgar supaya teks lebar seperti di Figma
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Ilustrasi
              Center(
                child: Image.asset(
                  'assets/images/money_bag.png',
                  width: 160,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 48),

              // GANTI BAGIAN TEKS-MU DENGAN INI
              Align(
                alignment: Alignment.center, // blok tetap di tengah
                child: RichText(
                  textAlign: TextAlign.left, // baris-barisnya rata kiri
                  textWidthBasis: TextWidthBasis
                      .longestLine, // lebar kotak = baris terpanjang
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(text: "Let's\n"),
                      TextSpan(text: "manage\n"),
                      TextSpan(
                        text:
                            "Your money\u00A0", // NBSP supaya "with us" tetap satu baris
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      TextSpan(
                        text: "with us",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Tombol "Mulai" kecil di tengah (bukan full width)
              Center(
                child: SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: Get.find<OnboardingController>().onMulaiPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Mulai'),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
