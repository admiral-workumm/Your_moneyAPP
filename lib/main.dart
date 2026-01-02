import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init local storage for persisting accounts
  await GetStorage.init();

  // Cek apakah onboarding sudah selesai
  final storage = GetStorage();
  final bool onboardingCompleted =
      storage.read('onboarding_completed') ?? false;

  print('[Main] Onboarding completed: $onboardingCompleted');

  // edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Biar status bar transparan & nav bar putih (match plate bawah)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MyApp({Key? key, required this.onboardingCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Jika sudah pernah setup, langsung ke home. Jika belum, ke onboarding
    final initialRoute = onboardingCompleted ? '/home' : AppPages.INITIAL;

    print('[MyApp] Initial route: $initialRoute');

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
