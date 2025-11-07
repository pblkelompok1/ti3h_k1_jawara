import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlack = Color(0xFF1B262C);
  static const Color darkBlue = Color(0xFF0F4C75);
  static const Color mediumBlue = Color(0xFF3282B8);
  static const Color lightBlue = Color(0xFFBBE1FA);

  // Static method untuk get primary color berdasarkan mode
  static Color getPrimaryColor(bool isDarkMode) => isDarkMode ? lightBlue : darkBlue;
}