import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: const Center(
        child: Text('MY TASK PAGE'),
      ),
    );
  }
}