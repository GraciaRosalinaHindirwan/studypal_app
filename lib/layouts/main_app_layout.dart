import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final loaded = UserService.getByIndex(widget.userIndex);
    if (mounted) {
      setState(() => user = loaded);
    }
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(userIndex: widget.userIndex),
      ),
    );
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final initial = (user?.username.isNotEmpty ?? false)
        ? user!.username[0].toUpperCase()
        : '?';

    final List<Widget> pages = [
    HomePage(),
    TaskPage(),
  ];

    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.background, // Ini otomatis jadi hitam kebiruan!
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: HeaderMain(
                  userInitial: initial,
                  photoBytes: user?.photoBytes,
                  onAvatarTap: _openProfile,
                ),
              ),
              Expanded(
                child: IndexedStack(index: selectedIndex, children: pages),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: ButtomNavigatorBar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) => setState(() => selectedIndex = index),
          ),
        ),
      );
    });
  }
}