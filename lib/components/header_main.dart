import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class HeaderMain extends StatelessWidget {
  final String userInitial; 

  const HeaderMain({
    super.key,
    required this.userInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Image.asset('assets/img/LogoHeader.png', 
            width: 165,
            height: 50,
            ), 
          ],
        ), 

        Container(
          width: 48,
          height: 48,
          decoration:BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle, 
            border: Border.all(
              color: AppColors.primary, 
              width: 2, 
            ), 
          ), 

          alignment: Alignment.center,
          child: Text(
            userInitial, 
            style: AppTextStyles.title.copyWith(
              color: AppColors.primary, 
            ), 
          ),
        ),
      ],
    );
  }
}