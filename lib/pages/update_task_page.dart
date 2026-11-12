import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studypal/models/task.dart';
import 'package:studypal/pages/pick_location_page.dart';
import 'package:studypal/services/task_service.dart';

import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_button_secondary.dart';
import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/components/due_date_dialog.dart';
import 'package:studypal/components/option_chip.dart';
import 'package:studypal/layouts/sub_page_layout.dart';
import 'package:studypal/pages/notification_page.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class UpdateTaskPage extends StatefulWidget {
  final Task task;
  const UpdateTaskPage({super.key, required this.task});

  @override
  State<UpdateTaskPage> createState() => _UpdateTaskPageState();
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
  @override
  void initState() {
    super.initState();

    titleController.text = widget.task.title;
    descriptionController.text = widget.task.description;
    dueDate = widget.task.dueDate;
  }

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // null berarti belum milih due date
  DateTime? dueDate;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDueDate() async {
    // buka dialog, tunggu sampai user klik OK atau Batal
    final result = await showDialog<DateTime>(
      context: context,
      builder: (_) => DueDateDialog(initial: dueDate),
    );
    // kalau Batal, result null, jadi ga ada yang diubah
    if (result == null) return;
    setState(() => dueDate = result);
  }

  // format dipendekin biar tiga chip muat satu baris
  String formatDueDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> updateTask() async {
    // 1. Ambil nilai terbaru dari form
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    // 2. Validasi title
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title tidak boleh kosong'),
        ),
      );
      return;
    }

    // 3. Buat objek Task dengan data terbaru
    final updatedTask = Task(
      id: widget.task.id,
      title: title,
      description: description,
      isCompleted: widget.task.isCompleted,
      dueDate: dueDate,
      locationName: widget.task.locationName,
      locationAddress: widget.task.locationAddress,
      latitude: widget.task.latitude,
      longitude: widget.task.longitude,
      reminderMinutes: widget.task.reminderMinutes,
      notificationIds: widget.task.notificationIds,
      createdAt: widget.task.createdAt,
    );

    try {
      // 4. Akses Hive Box
      final taskBox = Hive.box<Task>('tasks');

      // 5. Buat TaskService
      final taskService = TaskService(taskBox);

      // 6. Simpan perubahan ke Hive
      await taskService.updateTask(updatedTask);

      if (!mounted) return;

      // 7. Beri informasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task berhasil diperbarui!'),
        ),
      );

      // 8. Kembali ke halaman sebelumnya
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui task: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageLayout(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.accent, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(
              'Update Your Task',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
            AppTextField(hint: 'Title', controller: titleController),
            AppTextField(
              hint: 'Description',
              controller: descriptionController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OptionChip(
                  label: dueDate == null ? 'Due Date' : formatDueDate(dueDate!),
                  icon: Icons.calendar_today_outlined,
                  onTap: pickDueDate,
                ),
                OptionChip(
                  label: 'Reminder',
                  icon: Icons.notifications_none,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    );
                  },
                ),
                OptionChip(
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                   onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PickLocationPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: AppButtonSecondary(
                    label: 'Cancel Task',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: AppButton(
                    label: 'Update Task',
                    onTap: updateTask,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}