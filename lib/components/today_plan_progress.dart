import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class TodayPlanProgress extends StatelessWidget {
  final String message;
  final int percentage;

  const TodayPlanProgress({
    super.key,
    required this.message,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Progress message
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.title.copyWith(
                color: AppColors.background,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Percentage indicator
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent,
                width: 3,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$percentage%',
              style: AppTextStyles.title.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
