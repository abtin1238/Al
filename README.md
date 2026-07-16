# آبتین — مسیریاب هوشمند آفلاین 🧭
### Aabtin — Offline Smart Navigator (Flutter)

اپلیکیشن مسیریاب کاملاً آفلاین با Flutter، معماری Clean Architecture و مدیریت وضعیت Riverpod.
رابط کاربری دقیقاً بر اساس تصاویر مرجع (تم تیره/فیروزه‌ای، RTL فارسی) و برندینگ «آبتین» ساخته شده است.

---

## ✅ آنچه در این نسخه پیاده‌سازی شده (کد واقعی و اجراشدنی)

| بخش | وضعیت | فایل |
|---|---|---|
| معماری Clean Architecture + Riverpod | ✅ کامل | `lib/core`, `lib/features` |
| تم روشن/تیره + RTL + فونت Vazirmatn (bundled) | ✅ کامل | `core/theme` |
| نوار ناوبری پایین (۵ تب) | ✅ کامل | `core/widgets/app_bottom_nav.dart` |
| صفحه‌ی صدا (TTS، انتخاب صدا، اسلایدرها) | ✅ کامل | `features/voice` |
| صفحه‌ی جستجوی آفلاین (میان‌بر، دسته، نتایج) | ✅ کامل | `features/search` |
| صفحه‌ی علاقه‌مندی‌ها (دسته‌ها، مکان‌ها) | ✅ کامل | `features/favorites` |
| صفحه‌ی تنظیمات + تنظیمات مسیریابی | ✅ کامل | `features/settings`, `features/routing` |
| نمای ناوبری با نقشه (`flutter_map`/OSM) | ✅ کامل | `features/navigation` |
| بنر مانور + سرعت‌سنج + محدودیت سرعت | ✅ کامل | `features/navigation/presentation/widgets` |
| **موتور مسیریابی آفلاین A*** (واقعی) | ✅ کامل | `features/routing/data/offline_routing_engine.dart` |
| **فیلتر کالمن + Dead Reckoning** (واقعی) | ✅ کامل | `features/routing/data/kalman_filter.dart` |
| سرویس TTS فارسی آفلاین | ✅ کامل | `core/services/tts_service.dart` |
| سرویس موقعیت‌یابی (Geolocator + Kalman) | ✅ کامل | `core/services/location_service.dart` |
| تست واحد (Routing + Kalman) | ✅ | `test/` |
| آیکون برنامه «آبتین» (Android/iOS) | ✅ | `assets/icons/app_icon.png` |

## 🔜 بخش‌هایی که برای «سطح Google Maps» نیاز به کار نیتیو/داده دارند

این‌ها با نقطه‌ی اتصال (Service/Interface) آماده شده‌اند اما پیاده‌سازی نیتیو یا داده‌ی واقعی می‌خواهند:

- **کاشی‌های نقشه‌ی آفلاین واقعی (MBTiles/Vector):** الان از OSM آنلاین استفاده می‌شود؛ باید به `flutter_map_tile_caching` یا MBTiles محلی وصل شود.
- **گراف جاده‌ی واقعی:** موتور A* آماده است اما باید گراف را از داده‌ی OSM استخراج و در SQLite ذخیره کنید (`loadGraph`).
- **مدل سه‌بعدی خودرو (GLB)** و نمای Perspective/Tilt.
- **AR Navigation** (دوربین زنده + فلش‌های مسیر).
- **Android Auto / Apple CarPlay** و Deep Link.
- **Drift + SQLCipher**: اسکیمای دیتابیس رمزنگاری‌شده.

---

## 🏗️ ساختار پروژه

```
lib/
├── main.dart                      # ورودی + RTL + Localization
├── core/
│   ├── theme/                     # رنگ‌ها و تم (روشن/تیره)
│   ├── constants/                 # رشته‌های فارسی
│   ├── providers/                 # Riverpod (تم، تب، صدا، مسیریابی)
│   ├── services/                  # TTS، موقعیت‌یابی
│   ├── utils/                     # نگاشت آیکون دسته‌ها
│   └── widgets/                   # ویجت‌های مشترک + Shell + BottomNav
└── features/
    ├── navigation/                # نمای نقشه + مدل‌های دامنه
    ├── search/                    # جستجوی آفلاین
    ├── favorites/                 # مکان‌های مورد علاقه
    ├── voice/                     # تنظیمات صدا
    ├── settings/                  # تنظیمات اصلی
    └── routing/                   # موتور A* + کالمن + تنظیمات مسیر
```

---

## 🚀 راهنمای Build

پیش‌نیاز: **Flutter ≥ 3.19** و Dart ≥ 3.3.

```bash
# 0) ساخت پوشه‌های پلتفرم (android/ios/...) بدون دست‌زدن به lib
#    این پکیج شامل کد و دارایی‌هاست؛ اسکلت پلتفرم را با این دستور بسازید:
flutter create --org ir.abtin --project-name abtin_navigator .

# 1) نصب وابستگی‌ها
flutter pub get

# 2) ساخت آیکون برنامه از لوگوی آبتین
dart run flutter_launcher_icons

# 3) بررسی کیفیت کد
flutter analyze

# 4) اجرای تست‌ها
flutter test

# 5) اجرا روی دستگاه
flutter run

# 6) خروجی نهایی
flutter build apk --release        # Android
flutter build appbundle --release  # Android (Play Store)
flutter build ios --release        # iOS
```

### مجوزهای لازم (باید دستی اضافه شوند)
- **Android** (`android/app/src/main/AndroidManifest.xml`): `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `FOREGROUND_SERVICE_LOCATION`.
- **iOS** (`ios/Runner/Info.plist`): `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`.

---

## 🎨 برندینگ
- نام: **آبتین** | شعار: **مسیریاب هوشمند**
- رنگ اصلی: فیروزه‌ای `#00E5D0` | لهجه‌ی برند: طلایی `#D4AF37`
- تم پیش‌فرض: تیره (`#0A0E1A`)

> این پروژه یک پایه‌ی معماری‌شده و اجراشدنی است. برای رسیدن به کیفیت تجاری کامل،
> بخش‌های نیتیو فهرست‌شده در بالا باید تکمیل شوند.
