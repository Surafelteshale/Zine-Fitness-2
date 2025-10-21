import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFb4b60b); // your gold color
  static const Color background = Colors.white;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black87;
  static const Color hintText = Colors.grey;
  static const Color iconGrey = Color(0xFF757575); // similar to Colors.grey[600]
  static const Color fieldFill = Color(0xFFEFEFEF); // similar to Colors.grey[100]
  static const Color shadow = Colors.black12;
  static const Color accent = Color(0xFF3B4C60);
}

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
    fontSize: 26,
  );

  static const TextStyle fieldLabel = TextStyle(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static const TextStyle buttonText = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle hintTextStyle = TextStyle(
    color: AppColors.hintText,
    fontSize: 16,
  );

  static const TextStyle placeholderText = TextStyle(
    fontSize: 18,
    color: AppColors.hintText,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle resultText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
