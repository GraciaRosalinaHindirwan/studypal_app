import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class ReminderSelector extends StatelessWidget {
  final Set<String> selectedOptions;
  final ValueChanged<String> onOptionChanged;
  final VoidCallback onCustomTap;
  final String? customReminder;

  final List<String> options;

  const ReminderSelector({
    super.key,
    required this.selectedOptions,
    required this.onOptionChanged,
    required this.onCustomTap,
    this.customReminder,
    this.options = const [
      'Saat Acara Dimulai',
      '5 menit sebelum',
      '10 menit sebelum',
      '15 menit sebelum',
      '30 menit sebelum',
    ],
  });

  @override
  Widget build(BuildContext context) {    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reminder Options
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.accent,
              width: 2.5,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: options.map((option) {
              return SizedBox(
                height: 47,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 15,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),

                    Checkbox(
                      value: selectedOptions.contains(option),
                      onChanged: (_) {
                        onOptionChanged(option);
                      },
                      activeColor: AppColors.primary,
                      checkColor: AppColors.background,
                      side: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Custom Reminder
        GestureDetector(
          onTap: onCustomTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 17,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.accent,
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Kustom',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      color: AppColors.secondary,
                    ),
                  ),
                ),

                if (customReminder != null) ...[
                  Text(
                    customReminder!,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 8),
                ],

                Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
