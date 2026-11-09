import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_button_secondary.dart';
import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/components/header_sub.dart';
import 'package:studypal/pages/login_page.dart';
import 'package:studypal/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  final String userInitial;

  const ProfilePage({super.key, this.userInitial = 'R'});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final usernameFocus = FocusNode();

  // null berarti belum ada foto, jadi yang tampil inisial
  File? photo;

  // username dikunci dulu, baru bisa diketik setelah tombol edit ditekan
  bool isEditingUsername = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    usernameFocus.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    // buka galeri, hasilnya null kalau user batal milih
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => photo = File(picked.path));
  }

  void enableUsernameEdit() {
    setState(() => isEditingUsername = true);
    // fokus dipanggil setelah frame selesai, biar readOnly-nya udah kebuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      usernameFocus.requestFocus();
    });
  }

  void logout() {
    // hapus semua halaman sebelumnya biar tombol back ga balik ke app
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            spacing: 16,
            children: [
              // header sub (tombol back + logo), tanpa layout
              const HeaderSub(),
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: photo == null
                            ? null
                            : DecorationImage(
                                image: FileImage(photo!),
                                fit: BoxFit.cover,
                              ),
                      ),
                      // inisial cuma muncul kalau belum ada foto
                      child: photo == null
                          ? Text(
                              widget.userInitial,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 48,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: pickPhoto,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_camera_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              sectionLabel('Profile'),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: AppTextField(
                      hint: 'Username',
                      controller: usernameController,
                      focusNode: usernameFocus,
                      readOnly: !isEditingUsername,
                    ),
                  ),
                  GestureDetector(
                    onTap: enableUsernameEdit,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.secondary, width: 3),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              sectionLabel('Edit Password'),
              AppTextField(
                hint: 'Password',
                controller: passwordController,
                obscureText: true,
              ),
              AppTextField(
                hint: 'Confirm new password',
                controller: confirmController,
                obscureText: true,
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Save',
                // TODO: isi logic simpan nanti setelah backend siap
                onTap: () {},
              ),
              AppButtonSecondary(
                label: 'Logout',
                onTap: logout,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}