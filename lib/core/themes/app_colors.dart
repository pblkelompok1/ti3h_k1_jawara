import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primaryLight = Color(0xFF40513B);
  static const primaryDark = Color(0xFF9DC08B);

  // Secondary Colors
  static const secondaryLight = Color(0xFF9DC08B);
  static const secondaryDark = Color(0xFF9DC08B);

  // Background Colors
  static const backgroundLight = Color(0xFFFFFFFF);
  static const backgroundDark = Color(0xFF121212);

  // Surface Colors
  static const surfaceLight = Color(0xFFF5F5F5);
  static const surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const textPrimaryLight = Color(0xFF0C0F0B);
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryLight = Color(0xFF8B8B8B);
  static const textSecondaryDark = Color(0xFF9E9F93);

  // Accent Colors
  static const redAccentLight = Color(0xFFD66B6B);
  static const redAccentDark = Color(0xFFE04848);

  // Border Colors
  static const softBorderLight = Color(0xFFF3F3F3);
  static const softBorderDark = Color(0xFF6F7166);
  static const primaryBorderLight = Color(0xFF8B8B8B);
  static const primaryBorderDark = Color(0xFF6F7166);

  // Input Box Background
  static const bgPrimaryInputBoxLight = Color(0xFFFFFFFF);
  static const bgPrimaryInputBoxDark = Color(0xFF212220);

  // Helper method untuk mendapatkan warna berdasarkan mode
  static Color adaptive(
    BuildContext context, {
    required Color light,
    required Color dark,
  }) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  // Helper getters untuk kemudahan akses
  static Color primary(BuildContext context) =>
      adaptive(context, light: primaryLight, dark: primaryDark);

  static Color secondary(BuildContext context) =>
      adaptive(context, light: secondaryLight, dark: secondaryDark);

  static Color textPrimary(BuildContext context) =>
      adaptive(context, light: textPrimaryLight, dark: textPrimaryDark);

  static Color textSecondary(BuildContext context) =>
      adaptive(context, light: textSecondaryLight, dark: textSecondaryDark);

  static Color redAccent(BuildContext context) =>
      adaptive(context, light: redAccentLight, dark: redAccentDark);

  static Color softBorder(BuildContext context) =>
      adaptive(context, light: softBorderLight, dark: softBorderDark);

  static Color primaryBorder(BuildContext context) =>
      adaptive(context, light: primaryBorderLight, dark: primaryBorderDark);

  /// Literate custom
  static Color bgPrimaryInputBox(BuildContext context) => adaptive(
    context,
    light: bgPrimaryInputBoxLight,
    dark: bgPrimaryInputBoxDark,
  );

  static Color textPrimaryReverse(BuildContext context) =>
      adaptive(context, light: textPrimaryDark, dark: textPrimaryLight);

  static Color bgDashboardAppHeader(BuildContext context) =>
      adaptive(context, light: primaryLight, dark: backgroundDark);

  static Color bgDashboardCard(BuildContext context) =>
      adaptive(context, light: textPrimaryDark, dark: Color(0xFF161C14));
}
