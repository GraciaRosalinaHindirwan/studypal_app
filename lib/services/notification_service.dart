import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:studypal/models/task.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      final timeZoneName = localTimezone.toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings: initSettings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _isInitialized = true;
  }

  //helper
  String _formatReminderLabel(int minutes) {
    if (minutes == 0) return 'saat acara dimulai';
    if (minutes % (60 * 24) == 0) {
      final days = minutes ~/ (60 * 24);
      return '$days hari sebelum';
    }
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return '$hours jam sebelum';
    }
    return '$minutes menit sebelum';
  }

  Future<Map<int, int>> scheduleTaskReminders(Task task) async { {
    await init();

    final Map<int, int> scheduledIds = {};
    final due = task.dueDate;
    if (due == null || task.reminderMinutes.isEmpty) {
      return scheduledIds;
    }

    final now = DateTime.now();

    for (final minutes in task.reminderMinutes) {
      final triggerDate = due.subtract(Duration(minutes: minutes));
      if (!triggerDate.isAfter(now)) continue;

      final notificationId = Object.hash(task.id, minutes) & 0x7fffffff;
      final tzDate = tz.TZDateTime.from(triggerDate, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'studypal_reminders',
        'StudyPal Reminders',
        channelDescription: 'Pengingat jadwal dan tenggat tugas StudyPal',
        importance: Importance.high,
        priority: Priority.high,
      );

      const darwinDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        id: notificationId,
        title: 'StudyPal: ${task.title}',
        body: 'Pengingat (${_formatReminderLabel(minutes)}) untuk tugas "${task.title}"',
        scheduledDate: tzDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      scheduledIds[minutes] = notificationId;
    }

      return scheduledIds;
    }}

  Future<void> cancelTaskReminders(Task task) async {
    await init();

    for (final id in task.notificationIds.values) {
      await _plugin.cancel(id: id);
    }
  }
}