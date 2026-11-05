import 'package:flutter/material.dart';
import 'package:studypal/components/digitalClock/digital_clock.dart';
import 'package:studypal/components/today_plan_progress.dart';
import 'package:studypal/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 24), 

        child: Column(
          children: [
            DigitalClock(),

            const SizedBox(height: 24,), 

            TodayPlanProgress(
              message: "Great, your today's plan is almost done",
              percentage: 75,
            ), 
            
          ],
        ),
      ), 
    );
  }
}