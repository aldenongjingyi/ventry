import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──
  static const Color canvas = Color(0xFF0A0C0F);
  static const Color surface1 = Color(0xFF111318);
  static const Color surface2 = Color(0xFF181C22);
  static const Color surface3 = Color(0xFF1F2430);

  // ── Borders ──
  static const Color border1 = Color(0xFF252B35);
  static const Color border2 = Color(0xFF2F3744);
  static const Color border3 = Color(0xFF3A4455);

  // ── Text hierarchy ──
  static const Color t1 = Color(0xFFF8FAFC);
  static const Color t2 = Color(0xFFCBD5E1);
  static const Color t3 = Color(0xFF94A3B8);
  static const Color t4 = Color(0xFF64748B);
  static const Color t5 = Color(0xFF475569);

  // ── Primary — Electric Blue ──
  static const Color accBg = Color(0xFF0D1F3C);
  static const Color accBorder = Color(0xFF1A3560);
  static const Color acc = Color(0xFF2B7FFF);
  static const Color accText = Color(0xFF6AAEFF);

  // ── Emerald — active, in project, success ──
  static const Color emBg = Color(0xFF051F13);
  static const Color emBorder = Color(0xFF0A3D25);
  static const Color em = Color(0xFF10B981);
  static const Color emText = Color(0xFF34D399);

  // ── Amber — warning, repair, caution ──
  static const Color amBg = Color(0xFF1F1505);
  static const Color amBorder = Color(0xFF3D2A08);
  static const Color am = Color(0xFFF59E0B);
  static const Color amText = Color(0xFFFBC33A);

  // ── Rose — missing, error, critical ──
  static const Color reBg = Color(0xFF1F0808);
  static const Color reBorder = Color(0xFF3D1010);
  static const Color re = Color(0xFFEF4444);
  static const Color reText = Color(0xFFF87171);

  // ── Slate — storage, neutral, retired ──
  static const Color slBg = Color(0xFF111318);
  static const Color slBorder = Color(0xFF252B35);
  static const Color sl = Color(0xFF475569);
  static const Color slText = Color(0xFF94A3B8);

  // ── Retired (darker variant of slate) ──
  static const Color retiredBg = Color(0xFF0E1014);
  static const Color retiredBorder = Color(0xFF1C2028);
  static const Color retiredText = Color(0xFF64748B);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color conditionExcellent = em;
  static const Color conditionGood = emText;
  static const Color conditionFair = am;
  static const Color conditionPoor = amText;
  static const Color conditionDamaged = reText;
  static const Color inStorage = slText;
  static const Color checkedOut = emText;
  static const Color maintenance = amText;
  static const Color retired = retiredText;
  static const Color iconDefault = t3;

  // ── Item status colours ──
  static const Color statusStorage = slText;
  static const Color statusInProject = emText;
  static const Color statusMissing = reText;
  static const Color statusUnderRepair = amText;
  static const Color statusRetired = retiredText;

  /// Returns the badge colours (background, border, text) for an item status.
  static ({Color bg, Color border, Color text}) statusBadge(String status) {
    return switch (status) {
      'storage' => (bg: slBg, border: slBorder, text: slText),
      'in_project' => (bg: emBg, border: emBorder, text: emText),
      'missing' => (bg: reBg, border: reBorder, text: reText),
      'under_repair' => (bg: amBg, border: amBorder, text: amText),
      'retired' => (bg: retiredBg, border: retiredBorder, text: retiredText),
      _ => (bg: slBg, border: slBorder, text: slText),
    };
  }

  /// Flat status colour (for dots, icons).
  static Color getStatusColor(String status) {
    return switch (status) {
      'storage' => sl,
      'in_project' => em,
      'missing' => re,
      'under_repair' => am,
      'retired' => retiredText,
      'active' => em,
      'completed' => acc,
      'archived' => t4,
      _ => t3,
    };
  }
}
