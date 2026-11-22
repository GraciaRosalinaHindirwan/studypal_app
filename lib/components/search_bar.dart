import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearchTap;
  final double height;
  final double buttonSize;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSearchTap,
    this.height = 72,
    this.buttonSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.background,
              ),
              decoration: InputDecoration(
                hintText: 'Search Your Task',
                hintStyle: AppTextStyles.caption.copyWith(
                  color: AppColors.accent,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
        onTap: onSearchTap,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.search,
            color: AppColors.background,
            size: 24,
          ),
        ),
      ),
      ],
    );
  }
}