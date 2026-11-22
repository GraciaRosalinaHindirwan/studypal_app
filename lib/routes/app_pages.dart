import 'package:get/get.dart';
import 'package:studypal/layouts/main_app_layout.dart';
import 'package:studypal/pages/add_task_page.dart';
import 'package:studypal/pages/login_page.dart';
import 'package:studypal/pages/profile_page.dart';
import 'package:studypal/pages/register_page.dart';
import 'package:studypal/routes/app_routes.dart';

class AppPages {
  // Halaman pertama kali yang dibuka saat aplikasi nyala:
  static const initial = AppRoutes.login;

  // Daftar seluruh halaman di aplikasi StudyPal:
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.size, // Bonus: animasi transisi halus!
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      transition: Transition.size,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainAppLayout(userIndex: 0),
      transition: Transition.size,
    ),
    GetPage(
      name: AppRoutes.addTask,
      page: () => const AddTaskPage(),
      transition: Transition.downToUp, // Efek muncul dari bawah
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(userIndex: 0),
      transition: Transition.rightToLeft,
    ),
  ];
}