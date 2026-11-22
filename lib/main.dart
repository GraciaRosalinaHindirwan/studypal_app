import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studypal/models/task.dart';
import 'package:studypal/pages/home_page.dart';
import 'package:studypal/pages/login_page.dart';
import 'package:studypal/services/notification_service.dart';
import 'package:studypal/models/user_model.dart';
Future<void> main() async {
  // memastikan flutter siap 
  WidgetsFlutterBinding.ensureInitialized();

  //inisialisasi
  await Hive.initFlutter();

  //registrasi adapter
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(UserModelAdapter());

  //membuka box 
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<UserModel>('users');

  await NotificationService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}