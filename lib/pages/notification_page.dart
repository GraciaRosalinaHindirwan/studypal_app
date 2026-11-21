import 'package:flutter/material.dart';
import 'package:studypal/components/customReminder/custom_reminder_sheet.dart';
import 'package:studypal/components/customReminder/reminder_selector.dart';
import 'package:studypal/layouts/sub_page_layout.dart';

class NotificationPage extends StatefulWidget {
  final DateTime? dueDate;
  final String? initialReminder;

  const NotificationPage({
    super.key,
    this.dueDate,
    this.initialReminder,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String? selectedReminder;
  String? customReminder;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialReminder?.trim();
    if (initial != null && initial.isNotEmpty) {
      final lower = initial.toLowerCase();
      if (lower == 'saat acara dimulai' ||
          lower == '5 menit sebelum' ||
          lower == '10 menit sebelum' ||
          lower == '15 menit sebelum' ||
          lower == '30 menit sebelum') {
        selectedReminder = initial;
      } else {
        customReminder = initial;
      }
    }
  }

  String? get _activeReminder => customReminder ?? selectedReminder;

  Duration? _parseReminderDuration(String option) {
    final text = option.trim().toLowerCase();

    final words = text.split(' ');
    if (words.isEmpty) {
      return null;
    }

    final value = int.tryParse(words[0]);
    if (value == null || value < 0) {
      return null;
    }

    final unit = words[1];

    if (unit.startsWith('menit') || unit.startsWith('minute')) {
      return Duration(minutes: value);
    }
    if (unit.startsWith('jam') || unit.startsWith('hour')) {
      return Duration(hours: value);
    }
    if (unit.startsWith('hari') || unit.startsWith('day')) {
      return Duration(days: value);
    }

    return null;
  }

  DateTime? _calculateReminderDateTime(String option) {
    final due = widget.dueDate;
    if (due == null) return null;

    final duration = _parseReminderDuration(option);
    if (duration == null) return null;

    return due.subtract(duration);
  }

  String _formatTimeOnly(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<String> _buildScheduledPreviews() {
    if (widget.dueDate == null) return [];

    final options = <String>[
      if (selectedReminder != null) selectedReminder!,
      if (customReminder != null) customReminder!,
    ];

    final results = <String>[];
    for (final option in options) {
      final notifTime = _calculateReminderDateTime(option);
      if (notifTime != null) {
        results.add('$option → ${_formatTimeOnly(notifTime)}');
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _activeReminder);
      },
      child: SubPageLayout(
        onBack: () => Navigator.pop(context, _activeReminder),
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReminderSelector(
                selectedOptions: selectedReminder != null ? {selectedReminder!} : {},
                customReminder: customReminder,
                onOptionChanged: (option) {
                  setState(() {
                    if (selectedReminder == option) {
                      selectedReminder = null;
                    } else {
                      selectedReminder = option;
                    }
                  });
                },
                onCustomTap: () async {
                  final result = await showCustomReminderBottomSheet(context);

                  if (!mounted) return;

                  setState(() {
                    if (result == '__RESET__') {
                      customReminder = null;
                    } else if (result != null) {
                      customReminder = result;
                    }
                  });
                },
              ),
              if (widget.dueDate == null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Set Due Date terlebih dahulu agar jam notifikasi bisa dihitung otomatis.',
                ),
              ] else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}