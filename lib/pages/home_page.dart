import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:studypal/components/digitalClock/digital_clock.dart';
import 'package:studypal/components/summary_task_card.dart';
import 'package:studypal/components/today_pick_card.dart';
import 'package:studypal/components/today_plan_progress.dart';
import 'package:studypal/controller/task_controller.dart';
import 'package:studypal/controller/theme_controller.dart';
import 'package:studypal/routes/app_routes.dart';
import 'package:studypal/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key}); 

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.put(TaskController()); 
    // Panggil ThemeController di sini juga:
    final ThemeController themeController = Get.find<ThemeController>(); 

    return Obx(() {
      // Pantau status tema secara eksplisit:
      final isDark = themeController.isDarkMode.value;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const DigitalClock(),
                const SizedBox(height: 24), 
                TodayPlanProgress(
                  message: controller.progressMessage,
                  percentage: controller.percentage,
                ), 
                const SizedBox(height: 24), 
                SummaryTaskCard(
                  firstCount: controller.completeToday, 
                  secondCount: controller.todoToday, 
                  onAddTask: () => Get.toNamed(AppRoutes.addTask),
                ), 
                const SizedBox(height: 24), 
                TodayPickCard(
                  tasks: controller.todayTasks,
                  onToggleTask: (task) {
                    task.isCompleted = !task.isCompleted;
                    controller.updateTask(task); 
                  },
                ), 
              ],
            ),
          ),
        ),
      );
    }); 
  }
}