import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_button_secondary.dart';
import 'package:studypal/models/task.dart';
import 'package:studypal/services/task_service.dart';

import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/components/task_card.dart';
import 'package:studypal/pages/add_task_page.dart';
import 'package:studypal/components/task_detail_dialog.dart';
import 'package:studypal/pages/update_task_page.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  bool? statusFilter;
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> deleteTask(Task task) async{
    try {
      //akses hive box 
      final taskBox = Hive.box<Task>('tasks'); 
      final taskService = TaskService(taskBox);

      //menghapus task id 
      await taskService.deleteTask(task.id); 

      if(!mounted) return; 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task berhasil dihapus!'),
        ),
      );
    } catch (e) {
      if(!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus task: $e'),
        ),
      );
    }
  }

  
  Future<void> confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Delete
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Delete Task?',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Description
                Text(
                  'Are you sure you want to delete this task?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.secondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 24),

                // Task Title
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButtonSecondary(
                        label: 'Cancel',
                        onTap: () {
                          Navigator.pop(dialogContext, false);
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: AppButton(
                        label: 'Delete',
                        onTap: () {
                          Navigator.pop(dialogContext, true);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await deleteTask(task);
    }
  }


  void showTaskDetail(Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return TaskDetailDialog(
          title: task.title,
          description: task.description,
          dueDate: formatTaskDate(task.dueDate),
          reminder: task.reminderMinutes.isEmpty
              ? 'No reminder'
              : task.reminderMinutes.toString(),
          location: task.locationName ?? 'No location',

          onClose: () => Navigator.pop(dialogContext),

          onMarkDone: () {
            Navigator.pop(dialogContext);
            markTaskAsDone(task);
          },

          onEdit: () {
            Navigator.pop(dialogContext);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UpdateTaskPage(task: task),
              ),
            );
          },

          onDelete: () {
            Navigator.pop(dialogContext);
            confirmDelete(task);
          },
        );
      },
    );
  }

  void showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        Widget option(String label, bool? value) {
          return ListTile(
            title: Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: statusFilter == value
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              setState(() => statusFilter = value);
              Navigator.pop(context);
            },
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option('Semua', null),
              option('To Do', false),
              option('Done', true),
            ],
          ),
        );
      },
    );
  }

  String formatTaskDate(DateTime? date) {
    if (date == null) {
      return 'No due date';
    }

    String twoDigits(int number) {
      return number.toString().padLeft(2, '0');
    }

    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  Future<void> markTaskAsDone(Task task) async {
    try {
      // 1. Buat objek Task dengan status selesai
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        isCompleted: true,
        dueDate: task.dueDate,
        locationName: task.locationName,
        locationAddress: task.locationAddress,
        latitude: task.latitude,
        longitude: task.longitude,
        reminderMinutes: task.reminderMinutes,
        notificationIds: task.notificationIds,
        createdAt: task.createdAt,
      );

      // 2. Akses Hive Box
      final taskBox = Hive.box<Task>('tasks');

      // 3. Buat TaskService
      final taskService = TaskService(taskBox);

      // 4. Simpan perubahan ke Hive
      await taskService.updateTask(updatedTask);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task berhasil diselesaikan!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status task: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskBox = Hive.box<Task>('tasks');
    final taskService = TaskService(taskBox);

    return ValueListenableBuilder(
      valueListenable: taskBox.listenable(),
      builder: (context, box, child) {
        final tasks = taskService.getTasks();

        final filteredTasks = tasks.where((task) {
          final matchStatus =
              statusFilter == null || task.isCompleted == statusFilter;

          final matchSearch =
              task.title.toLowerCase().contains(searchQuery.toLowerCase());

          return matchStatus && matchSearch;
        }).toList();

        return Material(
          color: AppColors.background, 
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
                children: [
                  const Text(
                    '“Stay on Track with Your Tasks”',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: AppTextField(
                          hint: 'Search Your Task',
                          controller: searchController,
                          onChanged: (value) => setState(() => searchQuery = value),
                        ),
                      ),
                      GestureDetector(
                        onTap: showFilterSheet,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.filter_list, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  for (final task in filteredTasks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: GestureDetector(
                      onTap: () {
                        showTaskDetail(task);
                      },
                      child: TaskCard(
                        title: task.title,
                        dateTime: formatTaskDate(task.dueDate),
                        isDone: task.isCompleted,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 24,
                bottom: 24,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddTaskPage()),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: const Icon(Icons.add, color: AppColors.primary, size: 28),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}