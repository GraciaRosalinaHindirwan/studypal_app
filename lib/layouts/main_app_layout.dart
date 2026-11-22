import 'package:flutter/material.dart';
import 'package:studypal/components/header_main.dart';
import 'package:studypal/components/buttom_navigator_bar.dart';
import 'package:studypal/models/user_model.dart';
import 'package:studypal/pages/home_page.dart';
import 'package:studypal/pages/profile_page.dart';
import 'package:studypal/pages/task_page.dart';
import 'package:studypal/services/user_service.dart';
import 'package:studypal/theme/app_colors.dart';

class MainAppLayout extends StatefulWidget {
  // data dari login dikirim lewat constructor
  final int userIndex;

  const MainAppLayout({super.key, required this.userIndex});

  @override
  State<MainAppLayout> createState() => _MainAppLayoutState();
}

class _MainAppLayoutState extends State<MainAppLayout> {
  int selectedIndex = 0;
  late UserModel user;

  final List<Widget> pages = [
    const HomePage(),
    const TaskPage(),
  ];

  @override
  void initState() {
    super.initState();
    user = UserService.getByIndex(widget.userIndex)!;
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(userIndex: widget.userIndex),
      ),
    );
    // pas balik dari profil, ambil data terbaru biar header ikut berubah
    final updated = UserService.getByIndex(widget.userIndex);
    if (mounted && updated != null) setState(() => user = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: HeaderMain(
                userInitial: user.username[0].toUpperCase(),
                photoBytes: user.photoBytes,
                onAvatarTap: _openProfile,
              ),
            ),
            Expanded(
              child: IndexedStack(index: selectedIndex, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ButtomNavigatorBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}