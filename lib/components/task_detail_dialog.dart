import 'package:flutter/material.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class TaskDetailDialog extends StatelessWidget {
  final String title;
  final String description;
  final String dueDate;
  final String reminder;
  final String location;
  final bool isCompleted;

  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const TaskDetailDialog({
    super.key,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.reminder,
    required this.location,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
    required this.isCompleted,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: _buildCircleButton(
                  icon: Icons.close,
                  onTap: onClose,
                ),
              ),

              const SizedBox(height: 20),

              // Main Detail Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          color: AppColors.secondary,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.background,
                                ),
                              ),
                    
                              const SizedBox(height: 8),
                    
                              Text(
                                description,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                    
                        // Task Information
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildInfoItem(
                                icon: Icons.edit_calendar,
                                label: 'Due Date',
                                value: dueDate,
                              ),
                    
                              const SizedBox(height: 14),
                    
                              _buildInfoItem(
                                icon: Icons.alarm,
                                label: 'Reminder',
                                value: reminder,
                              ),
                    
                              const SizedBox(height: 14),
                    
                              _buildInfoItem(
                                icon: Icons.location_on_outlined,
                                label: 'Location',
                                value: location,
                              ),
                    
                              const SizedBox(height: 16),
                    
                              // Mark as Done
                              AppButton(
                                label: isCompleted ? 'Undo Completed' : 'Mark as Done',
                                onTap: onToggleStatus,
                              ), 
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Edit and Delete Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleButton(
                    icon: Icons.edit_outlined,
                    onTap: onEdit,
                  ),

                  const SizedBox(width: 32),

                  _buildCircleButton(
                    icon: Icons.delete_outline,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 22,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 3,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 25,
        ),
      ),
    );
  }
}
