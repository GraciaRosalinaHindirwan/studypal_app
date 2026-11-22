import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studypal/controller/theme_controller.dart';

class AppColors {
  // === 1. WARNA SIANG (TERANG) ===
  static const Color _lightPrimary = Color(0xFF043F6D);
  static const Color _lightSecondary = Color(0xFF40679E);
  static const Color _lightAccent = Color(0xFFF8B6B2);
  static const Color _lightBackground = Color(0xFFFFF7F5);
  static const Color _lightBorder = Color(0xFFE8DCD8);

  // === 2. WARNA MALAM (DARK MODE) ===
  static const Color _darkPrimary = Color(0xFF64B5F6);    // Biru cerah
  static const Color _darkSecondary = Color(0xFF1E293B);  // Kartu navy gelap
  static const Color _darkAccent = Color(0xFFF8B6B2);     // Peach tetap manis
  static const Color _darkBackground = Color(0xFF0F172A); // Latar hitam kebiruan
  static const Color _darkBorder = Color(0xFF334155);     // Garis tepi halus
  static const Color _darkTextPrimary = Color(0xFFF8FAFC);// Teks putih
  static const Color _darkTextSecondary = Color(0xFF94A3B8); // Teks abu-abu

  // === 3. SENSOR PENGECEK STATUS TEMA ===
  static bool get isDark {
    if (Get.isRegistered<ThemeController>()) {
      return Get.find<ThemeController>().isDarkMode.value;
    }
    return Get.isDarkMode;
  }

  // === 4. GETTER DINAMIS (KARTU & HALAMAN AKAN MEMANGGIL INI) ===
  static Color get primary => isDark ? _darkPrimary : _lightPrimary;
  static Color get secondary => isDark ? _darkSecondary : _lightSecondary;
  static Color get accent => isDark ? _darkAccent : _lightAccent;
  static Color get background => isDark ? _darkBackground : _lightBackground;
  static Color get border => isDark ? _darkBorder : _lightBorder;
  static Color get textPrimary => isDark ? _darkTextPrimary : _lightPrimary;
  static Color get textSecondary => isDark ? _darkTextSecondary : _lightSecondary;

  static const Color white = Colors.white;
  static const Color grey = Color(0xFF999999);
}