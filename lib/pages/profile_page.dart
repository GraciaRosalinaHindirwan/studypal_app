import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_button_secondary.dart';
import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/components/header_sub.dart';
import 'package:studypal/providers/auth_provider.dart';
import 'package:studypal/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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

  // field dikunci dulu, baru bisa diketik setelah tombol pensil ditekan
  bool isEditingEmail = false;
  bool isEditingUsername = false;

  @override
  void initState() {
    super.initState();
    // isi field dengan data user yang lagi login
    final user = context.read<AuthProvider>().currentUser!;
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

  Future<void> pickPhoto() async {
  try {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512, // dikecilkan biar data di Hive tetap ringan
    );
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    await context.read<AuthProvider>().updatePhoto(bytes);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal ganti foto: $e')),
    );
  }
}

  void enableEmailEdit() {
    setState(() => isEditingEmail = true);
    // fokus dipanggil setelah frame selesai, biar readOnly-nya udah kebuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailFocus.requestFocus();
    });
  }

  void enableUsernameEdit() {
    setState(() => isEditingUsername = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      usernameFocus.requestFocus();
    });
  }

  Future<void> save() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;
    String? error;

    // email & username cuma diupdate kalau memang berubah
    if (emailController.text.trim() != user.email) {
      error = await auth.updateEmail(emailController.text);
    }
    if (error == null && usernameController.text.trim() != user.username) {
      error = await auth.updateUsername(usernameController.text);
    }
    // password cuma diupdate kalau diisi
    if (error == null && passwordController.text.isNotEmpty) {
      error = await auth.updatePassword(
        passwordController.text,
        confirmController.text,
      );
    }
    if (!mounted) return;
    if (error == null) {
      passwordController.clear();
      confirmController.clear();
      setState(() {
        isEditingEmail = false;
        isEditingUsername = false;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Profil berhasil disimpan')),
    );
  }

  Future<void> logout() async {
    // tutup semua halaman yang kebuka dulu, baru logout.
    // setelah itu main.dart otomatis nampilin LoginPage
    Navigator.of(context).popUntil((route) => route.isFirst);
    await context.read<AuthProvider>().logout();
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

  // field + tombol pensil, tinggi pensil ngikutin tinggi field
  Widget editableField({
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
    // watch: foto & inisial ikut berubah pas data user berubah
    final user = context.watch<AuthProvider>().currentUser!;
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
                      // inisial cuma muncul kalau belum ada foto
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
              editableField(
                hint: 'Email',
                controller: emailController,
                focusNode: emailFocus,
                isEditing: isEditingEmail,
                onEdit: enableEmailEdit,
                keyboardType: TextInputType.emailAddress,
              ),
              editableField(
                hint: 'Username',
                controller: usernameController,
                focusNode: usernameFocus,
                isEditing: isEditingUsername,
                onEdit: enableUsernameEdit,
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
              AppButton(label: 'Save', onTap: save),
              AppButtonSecondary(label: 'Logout', onTap: logout),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}