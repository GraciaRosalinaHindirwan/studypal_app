import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studypal/components/header_main.dart';
import 'package:studypal/components/buttom_navigator_bar.dart';
import 'package:studypal/pages/home_page.dart';
import 'package:studypal/pages/profile_page.dart';
import 'package:studypal/pages/task_page.dart';
import 'package:studypal/providers/auth_provider.dart';
import 'package:studypal/theme/app_colors.dart';

class MainAppLayout extends StatefulWidget {
  const MainAppLayout({super.key});

  @override
  State<MainAppLayout> createState() => _MainAppLayoutState();
}

class _MainAppLayoutState extends State<MainAppLayout> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const TaskPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // watch: inisial ikut berubah kalau username diganti di profil
    final user = context.watch<AuthProvider>().currentUser;
    final initial = (user != null && user.username.isNotEmpty)
        ? user.username[0].toUpperCase()
        : '?';

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
                userInitial: initial,
                photoBytes: user?.photoBytes,
                onAvatarTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ButtomNavigatorBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}