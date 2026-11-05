import 'package:flutter/material.dart';
import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/components/task_card.dart';
import 'package:studypal/pages/add_task_page.dart';
import 'package:studypal/components/task_detail_dialog.dart';
import 'package:studypal/pages/update_task_page.dart';
import 'package:studypal/theme/app_colors.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  bool? statusFilter;
  final searchController = TextEditingController();
  String searchQuery = '';

  final tasks = [
    (title: 'Finish UI design for dashboard', dateTime: '27/04/2026 08:00 WIB', isDone: true),
    (title: 'Conduct user testing for dashboard', dateTime: '30/04/2026 10:00 WIB', isDone: false),
    (title: 'Launch Dashboard to Beta Users', dateTime: '15/05/2026 12:00 WIB', isDone: true),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showTaskDetail(String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return TaskDetailDialog(
          title: title,
          description:
              'Menyelesaikan rancangan UI/UX StudyPal Mobile version.',
          dueDate: '5 November 2026',
          reminder: '08:00 WIB',
          location: 'UPN',
          onClose: () => Navigator.pop(dialogContext),
          onMarkDone: () {
            debugPrint('Task marked as done');
            Navigator.pop(dialogContext);
          },
          onEdit: () => debugPrint('Edit task clicked'),
          onDelete: () => debugPrint('Delete task clicked'),
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

  @override
  Widget build(BuildContext context) {
    final filteredTasks = tasks.where((t) {
      final matchStatus = statusFilter == null || t.isDone == statusFilter;
      final matchSearch =
          t.title.toLowerCase().contains(searchQuery.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();

    return Stack(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UpdateTaskPage()),
                  );
                },
                child: TaskCard(
                  title: task.title,
                  dateTime: task.dateTime,
                  isDone: task.isDone,
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
    );
  }
}