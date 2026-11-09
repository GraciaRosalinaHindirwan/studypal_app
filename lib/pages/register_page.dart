import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/providers/auth_provider.dart';
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

  Future<void> submit() async {
    final error = await context.read<AuthProvider>().register(
          email: emailController.text,
          username: usernameController.text,
          password: passwordController.text,
        );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    // sukses: balik ke halaman login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil daftar, silakan login')),
    );
    Navigator.pop(context);
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
              const Text(
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
              AppButton(label: 'Register', onTap: submit),
              const SizedBox(height: 16),
              // tambahan di luar desain
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
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