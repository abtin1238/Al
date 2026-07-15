import 'package:flutter/material.dart';

/// پالت رنگی اپلیکیشن مسیریابی — تم شب.
/// الهام‌گرفته از نقشه‌های ماهواره‌ای شبانه با مسیر نارنجی درخشان.
class AppColors {
  AppColors._();

  // پس‌زمینه‌ها
  static const Color mapBackground = Color(0xFF0A0E14);
  static const Color panelBackground = Color(0xFF11161F);
  static const Color panelBackgroundElevated = Color(0xFF161C27);
  static const Color bottomBarBackground = Color(0xFF0D1119);

  // مسیر نارنجی درخشان
  static const Color routeGlowCore = Color(0xFFFFB020);
  static const Color routeGlowOuter = Color(0xFFFF8A00);
  static const Color routeArrow = Color(0xFFFFD27A);

  // آبی نشانگر / قطب‌نما
  static const Color accentBlue = Color(0xFF2E9DF5);
  static const Color accentBlueGlow = Color(0xFF1C6FD9);

  // قرمز (تابلوی سرعت / محدودیت)
  static const Color signRed = Color(0xFFE0292E);

  // متن‌ها
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFF8B94A3);
  static const Color textHighlightOrange = Color(0xFFFF9E2C);

  // خطوط شهر (بلوک‌های ساختمان روی نقشه)
  static const Color cityGrid = Color(0xFF1A2130);
  static const Color cityBlockLight = Color(0xFF232B3D);
  static const Color parkGreen = Color(0xFF1D2E1F);

  // سرعت‌سنج
  static const Color gaugeTrackBlue = Color(0xFF2E9DF5);
  static const Color gaugeTrackRed = Color(0xFFE0292E);
  static const Color gaugeNeedle = Color(0xFFE0292E);
  static const Color gaugeFace = Color(0xFF0C1017);

  // دکمه‌های شناور
  static const Color fabBackground = Color(0xFF161C27);
  static const Color fabBorder = Color(0xFF2A3242);

  static const Color divider = Color(0xFF232B3A);
}
