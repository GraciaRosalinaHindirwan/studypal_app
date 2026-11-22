import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:studypal/components/digitalClock/digital_clock.dart';
import 'package:studypal/components/summary_task_card.dart';
import 'package:studypal/components/today_pick_card.dart';
import 'package:studypal/components/today_plan_progress.dart';
import 'package:studypal/controller/task_controller.dart';
import 'package:studypal/pages/add_task_page.dart';
import 'package:studypal/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key}); 

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.put(TaskController()); 
   
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx( (){
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 24), 
          
            child: Column(
              children: [
                DigitalClock(),

                const SizedBox(height: 24,), 
          
                TodayPlanProgress(
                  message: controller.progressMessage,
                  percentage: controller.percentage,
                ), 
          
                const SizedBox(height: 24,), 
          
                SummaryTaskCard(
                  firstCount: controller.completeToday, 
                  secondCount: controller.todoToday, 
                  onAddTask: (){
                    Get.to(() => const AddTaskPage());
                  }
                ), 
          
                const SizedBox(height: 24,), 
                
                TodayPickCard(
                  tasks: controller.todayTasks,
                  onToggleTask: (task) {
                    task.isCompleted =!task.isCompleted; 
                      controller.updateTask(task); 
                  }
                ), 
              ],
            ),
          ),
        ); 
      }) 
    ); 
  }
}