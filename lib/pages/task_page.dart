import 'package:flutter/material.dart';
import 'package:studypal/components/task_detail_dialog.dart';
import 'package:studypal/pages/notification_page.dart';
import 'package:studypal/theme/app_colors.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  void showTaskDetail(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return TaskDetailDialog(
          title: 'Finish UI design for dashboard',
          description:
              'Menyelesaikan rancangan UI/UX StudyPal Mobile version.',
          dueDate: '5 November 2026',
          reminder: '08:00 WIB',
          location: 'UPN',

          onClose: () {
            Navigator.pop(dialogContext);
          },

          onMarkDone: () {
            debugPrint('Task marked as done');
            Navigator.pop(dialogContext);
          },

          onEdit: () {
            debugPrint('Edit task clicked');
          },

          onDelete: () {
            debugPrint('Delete task clicked');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Button Task Detail
            ElevatedButton(
              onPressed: () {
                showTaskDetail(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Show Task Detail'),
            ),

            const SizedBox(height: 20),

            // Button Notification Page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Show Notification Page'),
            ),
          ],
        ),
      ),
    );
  }
}
