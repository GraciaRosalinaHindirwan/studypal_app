import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';

class HeaderSub extends StatelessWidget {
  final VoidCallback? onBack;

  const HeaderSub({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
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
            width: 110,
            height: 38,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}