import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studypal/controller/task_controller.dart';
import 'package:studypal/models/task.dart';
import 'package:studypal/models/location.dart';
import 'package:studypal/pages/pick_location_page.dart';
import 'package:studypal/services/notification_service.dart';
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

  const UpdateTaskPage({
    super.key, 
    required this.task, 
  });

  @override
  State<UpdateTaskPage> createState() => _UpdateTaskPageState();
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
  Location? selectedLocation;
  String? selectedReminder;

  @override
  void initState() {
    super.initState();

    titleController.text = widget.task.title;
    descriptionController.text = widget.task.description;
    dueDate = widget.task.dueDate;
    if (widget.task.reminderMinutes.isNotEmpty) {
      selectedReminder = _minutesToReminderLabel(widget.task.reminderMinutes.first);
    }

    if (widget.task.latitude != null &&
        widget.task.longitude != null) {
      selectedLocation = Location(
        name: widget.task.locationName ?? 'Lokasi pilihan di peta',
        address: widget.task.locationAddress ?? '',
        latitude: widget.task.latitude!,
        longitude: widget.task.longitude!,
      );
    }
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
    final reminderMin = _parseReminderToMinutes(selectedReminder);

    // 2. Validasi title
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title tidak boleh kosong'),
        ),
      );
      return;
    }

    try {
      // 3. Batalkan notifikasi lama milik task sebelum diupdate
      await NotificationService.instance.cancelTaskReminders(widget.task);

      // 4. Buat draf Task dengan data terbaru
      final draftTask = Task(
        id: widget.task.id,
        title: title,
        description: description,
        isCompleted: widget.task.isCompleted,
        dueDate: dueDate,
        locationName: selectedLocation?.name,
        locationAddress: selectedLocation?.address,
        latitude: selectedLocation?.latitude,
        longitude: selectedLocation?.longitude,
        reminderMinutes: reminderMin != null ? [reminderMin] : [],
        notificationIds: const {},
        createdAt: widget.task.createdAt,
      );

      // 5. Jadwalkan ulang notifikasi sesuai dueDate & reminderMinutes baru
      final scheduledIds =
          await NotificationService.instance.scheduleTaskReminders(draftTask);
      
      // 6. Susun Task final yang membawa notificationIds terbaru
      final updatedTask = Task(
        id: draftTask.id,
        title: draftTask.title,
        description: draftTask.description,
        isCompleted: draftTask.isCompleted,
        dueDate: draftTask.dueDate,
        locationName: draftTask.locationName,
        locationAddress: draftTask.locationAddress,
        latitude: draftTask.latitude,
        longitude: draftTask.longitude,
        reminderMinutes: draftTask.reminderMinutes,
        notificationIds: scheduledIds,
        createdAt: draftTask.createdAt,
      );
      
      // Panggil controller
      final TaskController controller = Get.find<TaskController>();

      // Update lewat controller
      await controller.updateTask(updatedTask);
      
      // Kembali dan beri notifikasi
      Get.back();
      Get.snackbar('Sukses', 'Task berhasil diperbarui!');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui task: $e'),
        ),
      );
    }
  }

  Future<void> pickLocation() async {
    final result = await Navigator.push<Location>(
      context,
      MaterialPageRoute(
        builder: (_) => PickLocationPage(
          initialLocation: selectedLocation,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      selectedLocation = result;
    });
  }

  //helper
 String? _minutesToReminderLabel(int minutes) {
    if (minutes < 0) return null;
    if (minutes == 0) return 'Saat Acara Dimulai';
    if (minutes % (60 * 24) == 0) {
      final days = minutes ~/ (60 * 24);
      return '$days Hari sebelum';
    }
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return '$hours Jam sebelum';
    }
    return '$minutes menit sebelum';
  }

  int? _parseReminderToMinutes(String? reminder) {
    if (reminder == null || reminder.trim().isEmpty) return null;

    final text = reminder.trim().toLowerCase();
    if (text == 'saat acara dimulai') return 0;

    final words = text.split(' ');
    if (words.isEmpty) return null;

    final value = int.tryParse(words[0]);
    if (value == null || value < 0) return null;
    if (value == 0) return 0;
    if (words.length < 2) return null;

    final unit = words[1];
    if (unit.startsWith('menit') || unit.startsWith('minute')) {
      return value;
    }
    if (unit.startsWith('jam') || unit.startsWith('hour')) {
      return value * 60;
    }
    if (unit.startsWith('hari') || unit.startsWith('day')) {
      return value * 60 * 24;
    }

    return null;
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
              spacing: 10,
              children: [
                Expanded(
                  child: OptionChip(
                    label: dueDate == null ? 'Due Date' : formatDueDate(dueDate!),
                    icon: Icons.calendar_today_outlined,
                    onTap: pickDueDate,
                  ),
                ),
                Expanded(
                  child: OptionChip(
                    label: selectedReminder ?? 'Reminder',
                    icon: Icons.notifications_none,
                    onTap: () async {
                      final result = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationPage(
                            dueDate: dueDate,
                            initialReminder: selectedReminder,
                          ),
                        ),
                      );

                      if (!mounted || result == null) return;

                      setState(() {
                        selectedReminder = result;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: OptionChip(
                    label: selectedLocation?.name ?? 'Location',
                    icon: Icons.location_on_outlined,
                    onTap: pickLocation,
                  ),
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