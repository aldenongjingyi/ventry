import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Inter';

  // ── Display number — 32px/w700 — stat card hero numbers ──
  static const TextStyle displayNumber = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.t1,
  );

  // ── Screen title — 26px/w700 — tab headers ──
  static const TextStyle screenTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.t1,
  );

  // ── Card title — 20px/w600 — project/item names in detail screens ──
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.t1,
  );

  // ── Item name — 17px/w600 — item names in list rows ──
  static const TextStyle itemName = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.t2,
  );

  // ── Body — 16px/w400 — descriptions, notes ──
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.t2,
  );

  // ── Secondary body — 15px/w400 — secondary descriptions ──
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.t3,
  );

  // ── Caption — 13px/w400 — timestamps, item numbers ──
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.t3,
  );

  // ── Micro label — 12px/w500 — tags, badges, filter chips ──
  static const TextStyle micro = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.t3,
  );

  // ── Section label — 11px/w500 — section headers (uppercase, 0.7 spacing) ──
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.7,
    color: AppColors.t4,
  );

  // ── Button — 15px/w500 ──
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
  );

}
