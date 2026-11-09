import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String dateTime;
  final bool isDone;

  const TaskCard({
    super.key,
    required this.title,
    required this.dateTime,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            dateTime,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFA2CB8B) : AppColors.accent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Text(
              isDone ? 'DONE' : 'TO DO',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}