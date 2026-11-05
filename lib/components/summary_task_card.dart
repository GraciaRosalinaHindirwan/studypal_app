import 'package:flutter/material.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/pages/home_page.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class SummaryTaskCard extends StatelessWidget {
  final String title;
  final String firstLabel;
  final int firstCount;
  final String secondLabel;
  final int secondCount;
  final VoidCallback onAddTask;

  const SummaryTaskCard({
    super.key,
    this.title = 'Summary Task',
    this.firstLabel = 'Done',
    required this.firstCount,
    this.secondLabel = 'Done',
    required this.secondCount,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            title,
            style: AppTextStyles.title.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.background,
            ),
          ),

          const SizedBox(height: 16),

          // Summary counters
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  label: firstLabel,
                  count: firstCount,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _buildSummaryItem(
                  label: secondLabel,
                  count: secondCount,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Add Task Button
          AppButton(
            label: "Add Task", 
            onTap: onAddTask, 
          ), 
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required int count,
  }) {
    return Container(
      height: 108,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.accent,
          width: 2.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.title.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.background,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            count.toString(),
            style: AppTextStyles.title.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }
}
