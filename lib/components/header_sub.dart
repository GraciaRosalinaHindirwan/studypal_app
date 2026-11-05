import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';

class HeaderSub extends StatelessWidget {
  const HeaderSub({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          Image.asset(
            'assets/img/LogoHeader.png',
            width: 165,
            height: 50,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}