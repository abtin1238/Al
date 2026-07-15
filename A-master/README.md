# مسیریاب (Navi App)

پیاده‌سازی رابط کاربری (UI) یک اپلیکیشن مسیریابی با تم شب، بر اساس طرح ارائه‌شده — شامل پنل دستور مسیر، تابلوی محدودیت سرعت، برچسب خیابان‌ها، مسیر نارنجی درخشان با نشانگر خودرو، سرعت‌سنج آنالوگ، دکمه‌های کناری نقشه و نوار پایین.

> ⚠️ این نسخه فقط **UI/رابط کاربری** است (بدون نقشه واقعی یا GPS). داده‌ها (مسافت، سرعت، نام خیابان‌ها) به‌صورت نمونه (mock) در `lib/screens/navigation_screen.dart` قرار دارند.

## ساختار پروژه

```
lib/
 ├─ main.dart                          # نقطه ورود اپ + تم کلی
 ├─ theme/
 │   ├─ app_colors.dart                # پالت رنگی (تم شب)
 │   └─ app_text_styles.dart           # استایل‌های تایپوگرافی (فونت Vazirmatn)
 ├─ screens/
 │   └─ navigation_screen.dart         # صفحه اصلی که همه ویجت‌ها را کنار هم می‌چیند
 └─ widgets/
     ├─ night_map_background.dart      # پس‌زمینه نقشه شبانه (شبکه خیابان + پارک)
     ├─ glowing_route_path.dart        # مسیر نارنجی درخشان با پیکان متحرک
     ├─ car_marker.dart                # نشانگر خودرو (نمای از بالا)
     ├─ navigation_instruction_panel.dart  # پنل بالای صفحه (پیچ + آمار)
     ├─ speed_limit_sign.dart          # تابلوی گرد محدودیت سرعت
     ├─ map_labels.dart                # برچسب خیابان + حباب پیچ
     ├─ speedometer_gauge.dart         # سرعت‌سنج آنالوگ
     ├─ map_side_controls.dart         # دکمه‌های شناور (قطب‌نما/موقعیت/جهت‌یاب)
     └─ bottom_action_bar.dart         # نوار پایین (مسیر/ذخیره/جستجو/صدا/تنظیمات)
```

> 📱 **درباره iOS**: پوشه‌ی `ios/` در این مخزن قرار داده نشده (چون تولید دستی آن پرخطاست). برای اجرا روی iOS، فقط کافیست دستور زیر را یک‌بار در ریشه‌ی پروژه اجرا کنید تا Flutter آن را بسازد:
> ```bash
> flutter create --platforms=ios .
> ```

## پیش‌نیازها

1. نصب [Flutter SDK](https://docs.flutter.dev/get-started/install) (نسخه پایدار، Dart 3.3+)
2. اجرای بررسی سلامت محیط:
   ```bash
   flutter doctor
   ```

## اجرا روی سیستم خودتان

```bash
# ۱. نصب پکیج‌ها
flutter pub get

# ۲. اجرا روی یک شبیه‌ساز/دستگاه متصل
flutter run

# یا اجرا مستقیم در مرورگر کروم (سریع‌ترین راه برای تست)
flutter run -d chrome
```

## ساخت نسخه اجرایی

```bash
# اندروید (APK)
flutter build apk --release

# وب (برای GitHub Pages یا هر هاست استاتیک)
flutter build web --release
```

فایل خروجی APK در مسیر `build/app/outputs/flutter-apk/app-release.apk` قرار می‌گیرد.

## آپلود در گیت‌هاب

```bash
git init
git add .
git commit -m "افزودن UI اولیه اپلیکیشن مسیریابی"
git branch -M main
git remote add origin <آدرس-ریپوی-شما>
git push -u origin main
```

> نکته: پوشه‌های `build/`, `.dart_tool/` و غیره در `.gitignore` قرار دارند و نیازی به کامیت کردن آن‌ها نیست.

## فونت فارسی (اختیاری، برای کیفیت بهتر)

در حال حاضر پروژه از فونت **Vazirmatn** از طریق پکیج `google_fonts` استفاده می‌کند که به‌صورت خودکار در زمان اجرا دانلود می‌شود (نیاز به اینترنت در اولین اجرا). اگر می‌خواهید فونت را به‌صورت افلاین/باندل‌شده استفاده کنید:

1. فایل‌های `.ttf` فونت Vazirmatn را در `assets/fonts/` قرار دهید.
2. بخش کامنت‌شده در `pubspec.yaml` (قسمت `fonts:`) را از حالت کامنت خارج کنید.
3. در `app_text_styles.dart`، `GoogleFonts.vazirmatn(...)` را با `TextStyle(fontFamily: 'Vazirmatn', ...)` جایگزین کنید.

## مراحل بعدی پیشنهادی

- اتصال به یک SDK نقشه واقعی (مثل [Mapbox](https://pub.dev/packages/mapbox_maps_flutter) یا [نشان/بلد](https://neshan.org) برای نقشه‌های ایران) به‌جای پس‌زمینه‌ی برداری فعلی.
- اتصال GPS واقعی برای سرعت زنده (پکیج `geolocator`).
- اتصال به یک سرویس مسیریابی (Directions API) برای محاسبه مسیر واقعی به‌جای مسیر ثابت نمونه.
- پخش صدای راهنما (Text-to-Speech) با پکیج `flutter_tts`.
