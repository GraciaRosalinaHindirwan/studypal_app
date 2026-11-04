import 'package:flutter/material.dart';
import 'dart:async';

import 'package:studypal/components/digitalClock/clock_date.dart';
import 'package:studypal/components/digitalClock/flip_digit.dart';
import 'package:studypal/components/digitalClock/timezone_label.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late DateTime currentTime; 
  Timer? timer; 

  @override
  void initState() {
    super.initState(); //memulai timer 

    currentTime = DateTime.now();

  //memperbaruhi waktu setiap detik 
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        //memperbaruhi tampilan jam 
        setState(() {
          currentTime = DateTime.now();
        });
      },
    );
  }

  @override
  //menghentikan timer saat dihapus 
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  //menentukan label timezone
  String get timezone {
    final offset = currentTime.timeZoneOffset;

    if (offset == const Duration(hours: 7)) return 'WIB';
    if (offset == const Duration(hours: 8)) return 'WITA';
    if (offset == const Duration(hours: 9)) return 'WIT';

    return 'Local Time';
  }

  @override
  Widget build(BuildContext context) {
    final hour = currentTime.hour.toString().padLeft(2, '0');
    final minute = currentTime.minute.toString().padLeft(2, '0');
    final second = currentTime.second.toString().padLeft(2, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlipDigit(value: hour),
                    const SizedBox(width: 8),

                    Text(
                      ':',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 8),
                    FlipDigit(value: minute),
                    const SizedBox(width: 8),

                    Text(
                      ':',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 8),
                    FlipDigit(value: second),
                  ],
                ),

                const SizedBox(width: 12),

                TimezoneLabel(timezone: timezone),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        ClockDate(dateTime: currentTime),
      ],
    );
  }
}