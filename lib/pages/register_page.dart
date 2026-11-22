import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/pages/login_page.dart';
import 'package:studypal/services/user_service.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;

    // 1. Cek kolom kosong
    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Warning',
        'All fields are required',
        snackPosition: SnackPosition.BOTTOM,
        colorText: AppColors.textPrimary,                     
        icon:  Icon(Icons.warning, color: AppColors.accent), 
        margin: const EdgeInsets.all(16),            
        borderRadius: 16,                           
        duration: const Duration(seconds: 2),   
      );
      return;
    }

    // 2. Cek format email sederhana
    if (!email.contains('@') || !email.contains('.')) {
      Get.snackbar(
        'Warning',
        'Invalid email format',
        snackPosition: SnackPosition.BOTTOM,
        colorText: AppColors.textPrimary,                     
        icon:  Icon(Icons.warning, color: AppColors.accent), 
        margin: const EdgeInsets.all(16),            
        borderRadius: 16,                           
        duration: const Duration(seconds: 2),   
      );
      return;
    }

    // 3. Cek panjang username
    if (username.length < 3) {
      Get.snackbar(
        'Warning',
        'Username must be at least 3 characters',
        snackPosition: SnackPosition.BOTTOM,
        colorText: AppColors.textPrimary,                     
        icon:  Icon(Icons.warning, color: AppColors.accent), 
        margin: const EdgeInsets.all(16),            
        borderRadius: 16,                           
        duration: const Duration(seconds: 2),   
      );
      return;
    }

    // 4. Cek panjang password (misalnya minimal 6 karakter)
    if (password.length < 6) {
      Get.snackbar(
        'Warning',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        colorText: AppColors.textPrimary,                     
        icon:  Icon(Icons.warning, color: AppColors.accent), 
        margin: const EdgeInsets.all(16),            
        borderRadius: 16,                           
        duration: const Duration(seconds: 2),   
      );
      return;
    }

    try {
      final error = await UserService.register(
        email: email,
        username: username,
        password: password,
      );
      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil daftar, silakan login')),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal register: $e')));
    }
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
                'Register with StudyPal',
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
               Text(
                '“Get Started by Creating Your Account”',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                hint: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AppTextField(hint: 'Username', controller: usernameController),
              const SizedBox(height: 16),
              AppTextField(
                hint: 'Password',
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Register', onTap: _register),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:  Text(
                  'Sudah punya akun? Login',
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