import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studypal/controller/task_controller.dart';
import 'package:studypal/services/notification_service.dart';
import 'package:studypal/services/task_service.dart';

import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_button_secondary.dart';
import 'package:studypal/components/app_text_field.dart';
import 'package:studypal/components/due_date_dialog.dart';
import 'package:studypal/components/option_chip.dart';
import 'package:studypal/layouts/sub_page_layout.dart';

import 'package:studypal/models/task.dart';
import 'package:studypal/models/location.dart';

import 'package:studypal/pages/notification_page.dart';
import 'package:studypal/pages/pick_location_page.dart';

import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  Location? selectedLocation; 
  String? selectedReminder;

  // null berarti user belum milih due date
  DateTime? dueDate;
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDueDate() async {
    // buka dialog, terus tunggu sampai user klik OK atau Batal
    final result = await showDialog<DateTime>(
      context: context,
      builder: (_) => DueDateDialog(initial: dueDate),
    );
    // kalau Batal, result-nya null, jadi ga ada yang diubah
    if (result == null) return;
    setState(() => dueDate = result);
  }

  // format dipendekin (dd/MM HH:mm) biar tiga chip tetap muat satu baris
  String formatDueDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
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

  Future<void> addTask() async{
    //ambil nilai input
    final title = titleController.text.trim(); 
    final description = descriptionController.text.trim(); 
    final reminderMin = _parseReminderToMinutes(selectedReminder);
    
    //validasi title 
    if(title.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title tidak boleh kosong"))
      );
      return; 
    }

    try {

      //buat object task 
      final task = Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(), 
        title: title, 
        description: description, 
        dueDate: dueDate,
        reminderMinutes: reminderMin != null ? [reminderMin] : [],
        notificationIds: {},
        createdAt: DateTime.now(),

        // Data lokasi
        locationName: selectedLocation?.name,
        locationAddress: selectedLocation?.address,
        latitude: selectedLocation?.latitude,
        longitude: selectedLocation?.longitude,
      );

      // jadwalkan notifikasi & ambil map ID-nya
      final scheduledIds = await NotificationService.instance.scheduleTaskReminders(task); 

      // buat task final yang sudah membawa notificationIds
      final taskToSave = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        isCompleted: task.isCompleted,
        dueDate: task.dueDate,
        locationName: task.locationName,
        locationAddress: task.locationAddress,
        latitude: task.latitude,
        longitude: task.longitude,
        reminderMinutes: task.reminderMinutes,
        notificationIds: scheduledIds,
        createdAt: task.createdAt,
      );

      // 1. Panggil controller yang sudah ada
      final TaskController controller = Get.find<TaskController>();

      // 2. Simpan task lewat controller
      await controller.addTask(taskToSave);
      
      // 3. Tampilkan pesan & kembali ke halaman sebelumnya
      Get.back();
      Get.snackbar('Sukses', 'Task berhasil ditambahkan!');
      
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan task: $e'),
        ),
      );
      
    }
  }

  //helper
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
              'Add Your Task',
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
                  child: AppButton(label: 'Add Task', onTap: addTask),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}