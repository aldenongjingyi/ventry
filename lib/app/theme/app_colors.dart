import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Gold ──
  static const Color primary = Color(0xFFC9A84C);
  static const Color primaryLight = Color(0xFFDFC06E);
  static const Color primaryDark = Color(0xFFAA8A2E);
  static const Color primaryMuted = Color(0x33C9A84C); // 20% opacity

  // ── Status Colors ──
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // ── Item Status Colors ──
  static const Color statusStorage = Color(0xFF4ADE80);
  static const Color statusInProject = Color(0xFFC9A84C);
  static const Color statusMissing = Color(0xFFF87171);
  static const Color statusUnderRepair = Color(0xFFFBBF24);
  static const Color statusRetired = Color(0xFF666666);

  // ── Dark Surfaces ──
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceLight = Color(0xFF1E1E1E);
  static const Color surfaceElevated = Color(0xFF242424);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF1F1F1F);

  // ── Text ──
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textTertiary = Color(0xFF666666);
  static const Color textOnPrimary = Color(0xFF0A0A0A);

  // ── Glassmorphism ──
  static const Color glass = Color(0x0FFFFFFF);         // white 6%
  static const Color glassMedium = Color(0x1AFFFFFF);    // white 10%
  static const Color glassBorder = Color(0x1AFFFFFF);    // white 10%
  static const Color glassHighlight = Color(0x0DFFFFFF); // white 5%
  static const Color glassStrong = Color(0x33FFFFFF);    // white 20%

  // ── Gold Glass (for premium elements) ──
  static const Color goldGlass = Color(0x1AC9A84C);     // gold 10%
  static const Color goldGlassBorder = Color(0x33C9A84C); // gold 20%

  // ── Gradients ──
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9A84C), Color(0xFFAA8A2E)],
  );

  static const LinearGradient goldShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9A84C), Color(0xFFDFC06E), Color(0xFFC9A84C)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF141414), Color(0xFF0A0A0A)],
  );

  // ── Shadows ──
  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x33C9A84C),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> subtleGlow = [
    BoxShadow(
      color: Color(0x1AC9A84C),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  // ── Legacy aliases (backward compat) ──
  static const Color inStorage = statusStorage;
  static const Color checkedOut = statusInProject;
  static const Color maintenance = statusUnderRepair;
  static const Color retired = statusRetired;
  static const Color iconDefault = textSecondary;

  static const Color conditionExcellent = Color(0xFF4ADE80);
  static const Color conditionGood = Color(0xFF86EFAC);
  static const Color conditionFair = Color(0xFFFBBF24);
  static const Color conditionPoor = Color(0xFFFB923C);
  static const Color conditionDamaged = Color(0xFFF87171);

  // Helper to get status color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'storage':
        return statusStorage;
      case 'in_project':
        return statusInProject;
      case 'missing':
        return statusMissing;
      case 'under_repair':
        return statusUnderRepair;
      case 'retired':
        return statusRetired;
      case 'active':
        return success;
      case 'completed':
        return info;
      case 'archived':
        return textTertiary;
      default:
        return textSecondary;
    }
  }
}
