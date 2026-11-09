import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';

class OptionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const OptionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.secondary, width: 1.5),
        ),
        child: Row(
          spacing: 4,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(icon, size: 20, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}