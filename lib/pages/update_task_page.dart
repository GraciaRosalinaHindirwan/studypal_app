import 'package:flutter/material.dart';
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
  const UpdateTaskPage({super.key});

  @override
  State<UpdateTaskPage> createState() => _UpdateTaskPageState();
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
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
                    // TODO: arahkan ke location picker
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
                    // TODO: nanti isi logic update setelah model/database siap
                    onTap: () {},
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