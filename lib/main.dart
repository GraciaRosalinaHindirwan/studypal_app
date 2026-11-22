import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studypal/models/task.dart';
import 'package:studypal/pages/login_page.dart';
import 'package:studypal/services/notification_service.dart';

Future<void> main() async {
  // memastikan flutter siap 
  WidgetsFlutterBinding.ensureInitialized();

  //inisialisasi
  await Hive.initFlutter();

  //registrasi adapter
  Hive.registerAdapter(TaskAdapter());

  //membuka box 
  await Hive.openBox<Task>('tasks');

  await NotificationService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}