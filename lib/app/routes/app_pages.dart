import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_money/app/modules/Dompet/views/dompet_view.dart';
import 'package:your_money/app/modules/catatkeuangan/bindings/catatkeuangan_binding.dart';
import 'package:your_money/app/modules/catatkeuangan/views/catat_keuangan_view.dart';
import 'package:your_money/app/modules/home/bindings/home_binding.dart';
import 'package:your_money/app/modules/home/views/home_view.dart';
import 'package:your_money/app/modules/kategori/bindings/detail_kategori_binding.dart';
import 'package:your_money/app/modules/logout/bukumu_view.dart';
import 'package:your_money/app/modules/shell/views/shell_view.dart';
import 'package:your_money/app/modules/shell/bindings/shell_binding.dart';
import 'package:your_money/app/modules/kategori/views/kategori_view.dart';
import 'package:your_money/app/modules/kategori/views/detail_kategori.dart';
import 'package:your_money/app/modules/anggaran/views/anggaran_view.dart';
import 'package:your_money/app/modules/pengigat/views/pengingat_list_view.dart';
import 'package:your_money/app/modules/pengigat/views/pengingat_form_view.dart';
import 'package:your_money/app/modules/pengigat/bindings/pengingat_binding.dart';
import 'package:your_money/app/routes/app_routes.dart';

// Onboarding
import 'package:your_money/app/modules/onboarding/views/onboard_mulai_view.dart';
import 'package:your_money/app/modules/onboarding/views/onboard_atur_buku.dart';
import 'package:your_money/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:your_money/app/modules/onboarding/bindings/atur_buku_binding.dart';

// Home

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ONBOARD_MULAI;

  static final List<GetPage> routes = <GetPage>[
    GetPage(
      name: Routes.ONBOARD_MULAI,
      page: () => const OnboardMulaiView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.ONBOARD_ATUR_BUKU,
      page: () => const OnboardAturBukuView(),
      binding: AturBukuBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.SHELL,
      page: () => const ShellView(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: Routes.CATAT_KEUANGAN,
      page: () => const CatatKeuanganView(),
      binding: CatatKeuanganBinding(),
    ),
    GetPage(
      name: Routes.DOMPET,
      page: () => const DompetView(),
      // binding: DompetBinding(),
    ),
    GetPage(
      name: Routes.KATEGORI,
      page: () => const KategoriView(),
    ),
    GetPage(
      name: Routes.DETAIL_KATEGORI,
      page: () => const DetailKategoriView(),
      binding: DetailKategoriBinding(),
    ),
    GetPage(
      name: Routes.ANGGARAN,
      page: () => const AnggaranView(),
    ),
    GetPage(
      name: Routes.BUKUMU,
      page: () => const BukumuView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.PENGINGAT,
      page: () => const PengingatListView(),
      binding: PengingatBinding(),
    ),
    GetPage(
      name: Routes.PENGINGAT_FORM,
      page: () => const PengingatFormView(),
      binding: PengingatBinding(),
    ),
  ];

  static final GetPage unknownRoute = GetPage(
    name: Routes.NOT_FOUND,
    page: () => const Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan')),
    ),
  );
}
