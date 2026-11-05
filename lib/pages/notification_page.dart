import 'package:flutter/material.dart';
import 'package:studypal/components/customReminder/custom_reminder_sheet.dart';
import 'package:studypal/components/customReminder/reminder_selector.dart';
import 'package:studypal/layouts/sub_page_layout.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Set<String> selectedReminders = {};
  String? customReminder; 
  
  @override
  Widget build(BuildContext context) {
    return SubPageLayout(
      child: Padding(
        padding: const EdgeInsetsGeometry.only(top: 0), 
        child: ReminderSelector(
          selectedOptions: selectedReminders, 
          customReminder: customReminder,
          onOptionChanged: (option) {
            setState(() {
              if (selectedReminders.contains(option)) {
                selectedReminders.remove(option);
              } else {
                selectedReminders.add(option);
              }
            });
          },
          onCustomTap: () async {
            final result = await showCustomReminderBottomSheet(context);

            if (result != null) {
              setState(() {
                customReminder = result;
              });
            }
          },
        ),
      ), 
    );
  }
}