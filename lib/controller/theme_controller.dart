import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // Status apakah dark mode sedang aktif
  final RxBool isDarkMode = false.obs;

  // Fungsi saklar untuk bolak-balik tema
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    
    // Perintahkan GetX untuk ganti tema bawaan
    Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }
}