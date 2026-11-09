import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studypal/layouts/main_app_layout.dart';
import 'package:studypal/pages/login_page.dart';
import 'package:studypal/providers/auth_provider.dart';
import 'package:studypal/services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await UserService.init();

  final auth = AuthProvider()..restoreSession();

  runApp(
    ChangeNotifierProvider.value(value: auth, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // login/logout otomatis ganti halaman karena Consumer dengerin AuthProvider
      home: Consumer<AuthProvider>(
        builder: (_, auth, __) =>
            auth.isLoggedIn ? const MainAppLayout() : const LoginPage(),
      ),
    );
  }
}