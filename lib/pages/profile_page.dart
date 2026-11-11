import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_button_secondary.dart';
import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/components/header_sub.dart';
import 'package:studypal/models/user_model.dart';
import 'package:studypal/pages/login_page.dart';
import 'package:studypal/services/user_service.dart';
import 'package:studypal/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  final int userIndex;

  const ProfilePage({super.key, required this.userIndex});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final emailFocus = FocusNode();
  final usernameFocus = FocusNode();

  late UserModel user;

  // field dikunci dulu, kebuka setelah tombol pensil ditekan
  bool isEditingEmail = false;
  bool isEditingUsername = false;

  @override
  void initState() {
    super.initState();
    user = UserService.getByIndex(widget.userIndex)!;
    emailController.text = user.email;
    usernameController.text = user.username;
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    emailFocus.dispose();
    usernameFocus.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      await UserService.updatePhoto(widget.userIndex, bytes);
      if (!mounted) return;
      setState(() => user = UserService.getByIndex(widget.userIndex)!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ganti foto: $e')),
      );
    }
  }

  void _enableEdit(FocusNode focus, VoidCallback unlock) {
    setState(unlock);
    // fokus setelah frame selesai, biar readOnly-nya udah kebuka
    WidgetsBinding.instance.addPostFrameCallback((_) => focus.requestFocus());
  }

  Future<void> _save() async {
    final error = await UserService.updateProfile(
      widget.userIndex,
      email: emailController.text,
      username: usernameController.text,
      password: passwordController.text,
      confirm: confirmController.text,
    );
    if (!mounted) return;

    if (error == null) {
      passwordController.clear();
      confirmController.clear();
      setState(() {
        user = UserService.getByIndex(widget.userIndex)!;
        isEditingEmail = false;
        isEditingUsername = false;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Profil berhasil disimpan')),
    );
  }

  Future<void> _logout() async {
    // set loginData jadi false di Shared Preferences
    await UserService.logout();
    if (!mounted) return;
    // hapus semua halaman di stack, jadi ga bisa back ke aplikasi
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _sectionLabel(String text) {
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

  // field + tombol pensil, tinggi pensil ngikutin tinggi field
  Widget _editableField({
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isEditing,
    required VoidCallback onEdit,
    TextInputType? keyboardType,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Expanded(
            child: AppTextField(
              hint: hint,
              controller: controller,
              focusNode: focusNode,
              readOnly: !isEditing,
              keyboardType: keyboardType,
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary, width: 3),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = user.photoBytes != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            spacing: 16,
            children: [
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
                        image: hasPhoto
                            ? DecorationImage(
                                image: MemoryImage(user.photoBytes!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      // foto kalau ada, kalau engga inisial
                      child: hasPhoto
                          ? null
                          : Text(
                              user.username[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 48,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickPhoto,
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
              _sectionLabel('Profile'),
              _editableField(
                hint: 'Email',
                controller: emailController,
                focusNode: emailFocus,
                isEditing: isEditingEmail,
                onEdit: () =>
                    _enableEdit(emailFocus, () => isEditingEmail = true),
                keyboardType: TextInputType.emailAddress,
              ),
              _editableField(
                hint: 'Username',
                controller: usernameController,
                focusNode: usernameFocus,
                isEditing: isEditingUsername,
                onEdit: () =>
                    _enableEdit(usernameFocus, () => isEditingUsername = true),
              ),
              _sectionLabel('Edit Password'),
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
              AppButton(label: 'Save', onTap: _save),
              AppButtonSecondary(label: 'Logout', onTap: _logout),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}