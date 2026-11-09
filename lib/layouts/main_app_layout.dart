import 'package:flutter/material.dart';
import 'package:studypal/components/header_main.dart';
import 'package:studypal/components/buttom_navigator_bar.dart';
import 'package:studypal/theme/app_colors.dart';

import 'package:studypal/pages/home_page.dart';
import 'package:studypal/pages/task_page.dart';
import 'package:studypal/pages/profile_page.dart';

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
                userInitial: 'R', // test duls
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