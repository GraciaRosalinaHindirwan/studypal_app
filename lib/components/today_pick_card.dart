import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class TodayPickCard extends StatefulWidget {
  final List<String> tasks;

  const TodayPickCard({
    super.key,
    required this.tasks,
  });

  @override
  State<TodayPickCard> createState() => _TodayPickCardState();
}

class _TodayPickCardState extends State<TodayPickCard> {
  late List<bool> isChecked;

  @override
  void initState() {
    super.initState();

    isChecked = List<bool>.filled(
      widget.tasks.length,
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            "TODAY'S PICK",
            style: AppTextStyles.title.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          // Task List
          Column(
            children: List.generate(
              widget.tasks.length,
              (index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: isChecked[index],
                        onChanged: (value) {
                          setState(() {
                            isChecked[index] = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                        checkColor: AppColors.background,
                        side: BorderSide(
                          color: AppColors.primary,
                          width: 2.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          widget.tasks[index],
                          style: AppTextStyles.body.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            decoration: isChecked[index]
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
