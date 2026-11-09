import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class HeaderMain extends StatelessWidget {
  final String userInitial;
  final Uint8List? photoBytes;
  final VoidCallback? onAvatarTap;

  const HeaderMain({
    super.key,
    required this.userInitial,
    this.photoBytes,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoBytes != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/img/LogoHeader.png', width: 165, height: 50),
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              image: hasPhoto
                  ? DecorationImage(
                      image: MemoryImage(photoBytes!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasPhoto
                ? null
                : Text(
                    userInitial,
                    style: AppTextStyles.title
                        .copyWith(color: AppColors.primary),
                  ),
          ),
        ),
      ],
    );
  }
}