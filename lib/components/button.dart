import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;
  final Color border;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.background = AppColors.primary,
    this.foreground = AppColors.accent,
    this.border = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}