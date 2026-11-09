import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_button_secondary.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

Future<String?> showCustomReminderBottomSheet(
  BuildContext context,
) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const FractionallySizedBox(
        heightFactor: 0.5,
        child: CustomReminderSheet(),
      );
    },
  );
}

class CustomReminderSheet extends StatefulWidget {
  const CustomReminderSheet({super.key});

  @override
  State<CustomReminderSheet> createState() =>
      _CustomReminderSheetState();
}

class _CustomReminderSheetState
    extends State<CustomReminderSheet> {
  int selectedValue = 3;
  String selectedUnit = 'Jam';

  final List<String> units = [
    'Jam',
    'Menit',
    'Hari',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.accent,
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(36),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Waktu Pengingat',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppColors.background,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '$selectedValue $selectedUnit sebelum',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),

                // Reset Button
                Positioned(
                  right: 12,
                  top: 0,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context, '__RESET__');
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: AppColors.accent,
                      size: 24,
                    ),
                    tooltip: 'Reset pengingat',
                  ),
                ),
              ],
            ),
          ),

          // Picker
          SizedBox(
            height: 125,
            child: Row(
              children: [
                // Number Picker
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedValue - 1,
                    ),
                    itemExtent: 42,
                    selectionOverlay:
                        const CupertinoPickerDefaultSelectionOverlay(
                      background: Colors.transparent,
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedValue = index + 1;
                      });
                    },
                    children: List.generate(
                      24,
                      (index) {
                        final value = index + 1;

                        return Center(
                          child: Text(
                            value.toString(),
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 20,
                              color: value == selectedValue
                                  ? AppColors.primary
                                  : AppColors.secondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Unit Picker
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: units.indexOf(selectedUnit),
                    ),
                    itemExtent: 42,
                    selectionOverlay:
                        const CupertinoPickerDefaultSelectionOverlay(
                      background: Colors.transparent,
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedUnit = units[index];
                      });
                    },
                    children: units.map((unit) {
                      return Center(
                        child: Text(
                          unit,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: unit == selectedUnit
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: "OK", 
                    onTap: (){
                      Navigator.pop(
                        context,
                        '$selectedValue $selectedUnit sebelum',
                      );
                    }, 
                    background: AppColors.primary,
                    foreground: AppColors.accent,
                    border: AppColors.primary,
                  ), 
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: AppButtonSecondary(
                    label: "BATAL", 
                    onTap: (){
                      Navigator.pop(context);
                    }
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
