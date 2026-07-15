import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// استایل‌های متنی اپ. از فونت Vazirmatn (از طریق google_fonts) استفاده می‌شود
/// چون برای اعداد فارسی/لاتین و حروف عربی خوانایی بالایی دارد.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.vazirmatn(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // بنر بالای صفحه: "350 متر"
  static TextStyle distanceHero = _base(size: 34, weight: FontWeight.w800);

  // بنر بالای صفحه: "به سمت شیخ بهایی شمالی"
  static TextStyle instructionText =
      _base(size: 19, weight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle instructionHighlight = _base(
    size: 19,
    weight: FontWeight.w700,
    color: AppColors.textHighlightOrange,
  );

  // آمار پایین بنر (زمان رسیدن / مسافت / زمان باقی‌مانده)
  static TextStyle statValue =
      _base(size: 17, weight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle statLabel =
      _base(size: 12, weight: FontWeight.w400, color: AppColors.textSecondary);

  // برچسب خیابان روی نقشه
  static TextStyle streetLabel =
      _base(size: 13, weight: FontWeight.w600, color: AppColors.textPrimary);

  // برچسب پیچ (شیخ بهایی شمالی داخل حباب آبی)
  static TextStyle turnLabel =
      _base(size: 13, weight: FontWeight.w600, color: AppColors.textPrimary);

  // تابلوی محدودیت سرعت
  static TextStyle speedLimitValue =
      _base(size: 30, weight: FontWeight.w800, color: Colors.white);

  // سرعت‌سنج
  static TextStyle speedValue =
      _base(size: 44, weight: FontWeight.w800, color: AppColors.textPrimary);

  static TextStyle speedUnit =
      _base(size: 13, weight: FontWeight.w500, color: AppColors.textSecondary);

  static TextStyle gearLabel =
      _base(size: 13, weight: FontWeight.w700, color: AppColors.accentBlue);

  // نوار پایین
  static TextStyle bottomBarLabel =
      _base(size: 12, weight: FontWeight.w500, color: AppColors.textSecondary);
}
