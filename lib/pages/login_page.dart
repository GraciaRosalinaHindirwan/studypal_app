import 'package:flutter/material.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/layouts/main_app_layout.dart';
import 'package:studypal/pages/register_page.dart';
import 'package:studypal/services/user_service.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // tiap halaman ini dibuka, cek dulu masih ada login sebelumnya atau engga
    _checkLogin();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLogin() async {
    final index = await UserService.getSession();
    if (index != null && mounted) {
      _goHome(index);
    }
  }

  // pushReplacement biar user ga bisa back ke halaman login
  void _goHome(int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainAppLayout(userIndex: index)),
    );
  }

  Future<void> _login() async {
    final index = UserService.login(
      usernameController.text,
      passwordController.text,
    );
    if (index == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah')),
      );
      return;
    }
    await UserService.saveSession(index);
    if (mounted) _goHome(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Image.asset(
                'assets/img/logoLaptop.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'LOGIN',
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Today is a fresh start. Ready to be productive?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(hint: 'Username', controller: usernameController),
              const SizedBox(height: 16),
              AppTextField(
                hint: 'Password',
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              AppButton(label: 'LOGIN', onTap: _login),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'Belum punya akun? Register',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}