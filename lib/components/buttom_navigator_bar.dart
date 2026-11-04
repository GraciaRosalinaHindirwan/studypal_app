import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';

class ButtomNavigatorBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ButtomNavigatorBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.edit_note_outlined,
            label: 'MyTask',
            index: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.secondary
                  : AppColors.grey,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
