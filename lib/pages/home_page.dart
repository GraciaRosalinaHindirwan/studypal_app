import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:studypal/components/digitalClock/digital_clock.dart';
import 'package:studypal/components/summary_task_card.dart';
import 'package:studypal/components/today_pick_card.dart';
import 'package:studypal/components/today_plan_progress.dart';
import 'package:studypal/models/task.dart';
import 'package:studypal/services/task_service.dart';
import 'package:studypal/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  //Helper kecil untuk mengecek apakah suatu tanggal berada di "hari ini"
  bool _isToday(DateTime? date){
    if(date == null) return false; 
    final now = DateTime.now(); 
    return date.year == now.year &&
    date.month == now.month && 
    date.day == now.day; 
  }

  @override
  Widget build(BuildContext context) {
    //1. ambil box tasks 
    final taskBox = Hive.box<Task>('tasks'); 

    //2. isntance taskService 
    final taskService = TaskService(taskBox);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(), 
        builder: (context, box, child) {
          //ambil semua task lalu saring berdasarkan tanggal hari ini 
          final allTasks = taskService.getTasks();
          final todayTasks = allTasks.where((Task) => _isToday(Task.dueDate)).toList(); 

          final totalToday = todayTasks.length;  //berapa banyak tugas hari ini 
          // udh berapa yang selesai 
          final completeToday = todayTasks.where((Task) => Task.isCompleted == true).length; 

          final int percentage = totalToday == 0
            ? 0
            : ((completeToday / totalToday) * 100).round().clamp(0, 100); 

          final String progressMessage = totalToday == 0
            ? "No Tasks Schedule for today yet"
            : percentage == 100
                ? "Awesome! All today's tasks are done"
                : "Great, your today's plan is almost done";

          //ambil 5 task untuk today's pick 
          final sortedTodayTask = List<Task>.from(todayTasks)
          ..sort((a, b) {
            if(a.dueDate == null && b.dueDate == null) return 0; 
            if(a.dueDate == null) return 1; //task tanpa due date taruh bawah
            if(b.dueDate == null) return -1; 
            return a.dueDate!.compareTo(b.dueDate!); //yang lebih awal taro atas
          });

          final List<String> todayPickTitles = sortedTodayTask
            .take(5)
            .map((Task) => Task.title)
            .toList(); 

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 24), 
            
              child: Column(
                children: [
                  DigitalClock(),
            
                  const SizedBox(height: 24,), 
            
                  TodayPlanProgress(
                    message: progressMessage,
                    percentage: 75,
                  ), 
            
                  const SizedBox(height: 24,), 
            
                  SummaryTaskCard(
                    firstCount: completeToday, 
                    secondCount: totalToday, 
                    onAddTask: (){
                      debugPrint('Add Task clicked');
                    }
                  ), 
            
                  const SizedBox(height: 24,), 
                  
                  TodayPickCard(
                    tasks: todayPickTitles,
                  ), 
                ],
              ),
            ),
          );
        }
      ), 
    );
  }
}