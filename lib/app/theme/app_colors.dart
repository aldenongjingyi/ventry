import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — Gold
  static const Color primary = Color(0xFFD4A846);
  static const Color primaryLight = Color(0xFFE8C36A);
  static const Color primaryDark = Color(0xFFB8892E);

  // Status
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // Equipment status
  static const Color inStorage = Color(0xFF4ADE80);
  static const Color checkedOut = Color(0xFFD4A846);
  static const Color maintenance = Color(0xFFFBBF24);
  static const Color retired = Color(0xFF666666);

  // Dark surfaces
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF242424);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF1F1F1F);

  // Text on dark
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textTertiary = Color(0xFF666666);
  static const Color iconDefault = Color(0xFFA0A0A0);

  // Glassmorphism
  static const Color glass = Color(0x0FFFFFFF); // white 6%
  static const Color glassBorder = Color(0x1AFFFFFF); // white 10%
  static const Color glassHighlight = Color(0x0DFFFFFF); // white 5%

  // Condition colors
  static const Color conditionExcellent = Color(0xFF4ADE80);
  static const Color conditionGood = Color(0xFF86EFAC);
  static const Color conditionFair = Color(0xFFFBBF24);
  static const Color conditionPoor = Color(0xFFFB923C);
  static const Color conditionDamaged = Color(0xFFF87171);

  // Gold gradient
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A846), Color(0xFFB8892E)],
  );

  // Glass gradient for cards
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x0DFFFFFF), Color(0x05FFFFFF)],
  );
}
