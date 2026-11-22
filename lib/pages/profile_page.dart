import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 1. Import GetX
import 'package:image_picker/image_picker.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_button_secondary.dart';
import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/components/header_sub.dart';
import 'package:studypal/controller/theme_controller.dart';
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

  // Field dikunci dulu, kebuka setelah tombol pensil ditekan
  bool isEditingEmail = false;
  bool isEditingUsername = false;

  // Variabel untuk memantau status Dark Mode
  bool isDark = Get.isDarkMode;

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
      setState(() => user = UserService.getByIndex(widget.userIndex)!);
      
      Get.snackbar('Sukses', 'Foto profil berhasil diubah!');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal ganti foto: $e');
    }
  }

  void _enableEdit(FocusNode focus, VoidCallback unlock) {
    setState(unlock);
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

    if (error == null) {
      passwordController.clear();
      confirmController.clear();
      setState(() {
        user = UserService.getByIndex(widget.userIndex)!;
        isEditingEmail = false;
        isEditingUsername = false;
      });
      Get.snackbar('Sukses', 'Profil berhasil disimpan!');
    } else {
      Get.snackbar('Peringatan', error);
    }
  }

  Future<void> _logout() async {
    await UserService.logout();
    // GetX: Keluar & hapus semua tumpukan halaman agar tidak bisa di-back
    Get.offAll(() => const LoginPage());
  }

   Widget _sectionLabel(String text) {
    // 1. Ambil controller tema
    final themeController = Get.find<ThemeController>();
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          // Jika gelap warnanya putih, jika terang warnanya hitam (atau warna primary)
          color: themeController.isDarkMode.value ? Colors.white : AppColors.primary,
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              decoration: BoxDecoration(
                // JIKA SEDANG DIEDIT: Latar belakang jadi warna Primary (Ungu/Biru)
                // JIKA TIDAK DIEDIT: Latar belakang transparan
                color: isEditing ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEditing ? AppColors.primary : AppColors.secondary,
                  width: 3,
                ),
              ),
              child: Icon(
                // JIKA SEDANG DIEDIT: Icon berubah jadi centang
                // JIKA TIDAK DIEDIT: Icon pensil
                isEditing ? Icons.check : Icons.edit_outlined,
                size: 20,
                color: isEditing ? Colors.white : AppColors.secondary,
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
    final ThemeController themeController = Get.put(ThemeController()); 

    return Obx((){
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              spacing: 16,
              children: [
                const HeaderSub(),
      
                // Foto Profil
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
                        child: hasPhoto
                            ? null
                            : Text(
                                user.username[0].toUpperCase(),
                                style:  TextStyle(
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
                            decoration:  BoxDecoration(
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
      
                // Bagian Profil
                _sectionLabel('Profile'),
                _editableField(
                  hint: 'Email',
                  controller: emailController,
                  focusNode: emailFocus,
                  isEditing: isEditingEmail,
                  onEdit: () {
                    if (isEditingEmail) {
                      setState(() => isEditingEmail = false); // Tutup edit kalau ditekan lagi
                    } else {
                      _enableEdit(emailFocus, () => isEditingEmail = true);
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                _editableField(
                  hint: 'Username',
                  controller: usernameController,
                  focusNode: usernameFocus,
                  isEditing: isEditingUsername,
                  onEdit: () {
                    if (isEditingUsername) {
                      setState(() => isEditingUsername = false);
                    } else {
                      _enableEdit(usernameFocus, () => isEditingUsername = true);
                    }
                  },
                ),
      
                // Bagian Edit Password
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
      
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    // Jika gelap pakai warna kartu gelap, jika terang pakai putih transparan
                    color: themeController.isDarkMode.value 
                        ? AppColors.secondary 
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: themeController.isDarkMode.value 
                          ? AppColors.border 
                          : AppColors.secondary, 
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            themeController.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
                            color: themeController.isDarkMode.value ? Colors.amber : AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            themeController.isDarkMode.value ? 'Mode Gelap (Dark)' : 'Mode Terang (Light)',
                            style: TextStyle(
                              // Teks otomatis putih saat gelap, hitam saat terang
                              color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: themeController.isDarkMode.value,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          themeController.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
      
                const SizedBox(height: 8),
      
                // Tombol Simpan & Logout
                AppButton(label: 'Save', onTap: _save),
                AppButtonSecondary(label: 'Logout', onTap: _logout),
                const SizedBox(height: 24),
              ],
            ),
          ),
        )
      );
    });
  }
}