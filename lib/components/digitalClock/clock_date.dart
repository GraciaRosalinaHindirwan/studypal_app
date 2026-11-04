import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class ClockDate extends StatelessWidget {
  final DateTime dateTime;

  const ClockDate({
    super.key,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final formattedDate =
        '${days[dateTime.weekday - 1]} | '
        '${months[dateTime.month - 1]} '
        '${dateTime.day}, ${dateTime.year}';

    return Text(
      formattedDate,
      textAlign: TextAlign.center,
      style: AppTextStyles.title.copyWith(
        fontSize: 16,
        color: AppColors.primary,
      ),
    );
  }
}
