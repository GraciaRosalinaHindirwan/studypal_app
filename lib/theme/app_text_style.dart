import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontFamily = 'Poppins';

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}

//penggunaan TextStyle
//Text(
//   'StudyPal',
//   style: AppTextStyles.title.copyWith(
//     color: Color(0xFF426BA8),
//   ),
// )