import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studypal/theme/app_colors.dart';

class ThemeController extends GetxController {
  // Status apakah dark mode sedang aktif
  final RxBool isDarkMode = false.obs;

  // Fungsi saklar untuk bolak-balik tema
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    
    // Perintahkan GetX untuk ganti tema bawaan
    Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }

  // Helper warna yang otomatis berubah sesuai status tema:
  Color get currentBackground =>
      isDarkMode.value ? AppColors.darkBackground : AppColors.background;

  Color get currentPrimary =>
      isDarkMode.value ? AppColors.darkPrimary : AppColors.primary;

  Color get currentSecondary =>
      isDarkMode.value ? AppColors.darkSecondary : AppColors.secondary;

  Color get currentText =>
      isDarkMode.value ? AppColors.darkTextPrimary : AppColors.primary;

  Color get currentCardBorder =>
      isDarkMode.value ? AppColors.darkBorder : AppColors.secondary;
}