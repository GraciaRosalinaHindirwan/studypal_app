import 'package:flutter/material.dart';
import 'package:studypal/components/header_sub.dart';
import 'package:studypal/theme/app_colors.dart';

class SubPageLayout extends StatelessWidget {
  final Widget child;
  final String bottomImage;

  const SubPageLayout({
    super.key,
    required this.child,
    this.bottomImage = 'assets/img/logoLaptop.png',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const HeaderSub(),
              child,
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    bottomImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}