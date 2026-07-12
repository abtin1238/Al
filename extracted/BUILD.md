# راهنمای ساخت و بهینه‌سازی «آبتین مسیریاب»

## پیش‌نیازها
- Flutter نسخه‌ی پایدار (≥ 3.24) و Android SDK / Java 17
- این مخزن پوشه‌ی `android/` و `ios/` ندارد؛ یک بار باید ساخته شوند.

## ساخت سریع (روی سیستم خودت)
```bash
flutter create --platforms=android,ios --org ir.abtin .
flutter pub get
dart run flutter_launcher_icons        # آیکون آبتین را روی همه‌ی اندازه‌ها ست می‌کند
flutter build apk --release --split-per-abi --tree-shake-icons
```
خروجی در `build/app/outputs/flutter-apk/` قرار می‌گیرد.

## ساخت خودکار در گیت‌هاب (بدون نیاز به سیستم)
فایل `.github/workflows/build-apk.yml` آماده است. کافی است پروژه را روی گیت‌هاب push کنی؛
در تب **Actions** سه APK سبک ساخته و آپلود می‌شود (artifact با نام `abtin-apks`).

## کاهش حجم APK (از ~۱۰۰مگ به ~۳۰–۴۰مگ)
1. **`--split-per-abi`** — به‌جای یک APK چاق، سه APK جدا (arm64، armeabi، x86_64). هر کدام سبک.
2. **R8 + Resource Shrinking** — در `android/app/build.gradle` داخل بلوک `release`:
   ```gradle
   minifyEnabled true
   shrinkResources true
   proguardFiles getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
   ```
   فایل `build_config/proguard-rules.pro` را به `android/app/` کپی کن.
3. **`--tree-shake-icons`** — حذف آیکون‌های بلااستفاده‌ی متریال.
4. **`--obfuscate --split-debug-info=build/symbols`** — کد کوچک‌تر و امن‌تر.
5. **assetها:** فونت را subset کن، مدل GLB را با `gltf-pipeline -d` فشرده کن (Draco).
6. برای انتشار در گوگل‌پلی از **App Bundle** استفاده کن: `flutter build appbundle --release`.

## بهینه‌سازی باتری (پیاده‌سازی‌شده در کد)
- `RepaintBoundary` روی سرعت‌سنج، خودرو و قطب‌نما تا فقط همان بخش دوباره رسم شود.
- توقف شبیه‌سازی و لغو اشتراک‌ها در `NavigationController.dispose()`.
- GPS با `LocationAccuracy.bestForNavigation` فقط هنگام ناوبری؛ در حالت بی‌کاری فاصله‌ی نمونه‌برداری بالا برود.
- شتاب‌سنج فقط برای پرکردن فاصله‌ی بین نمونه‌های GPS (Dead Reckoning) استفاده می‌شود.

## نقشه‌ی سه‌بعدی و آفلاین
- نسخه‌ی فعلی: `flutter_map` + پرسپکتیو (`_MapWithPerspective`) برای حسِ سه‌بعدی.
- **مسیر تولید (سه‌بعدی واقعی):** مهاجرت لایه‌ی نقشه به **MapLibre GL** با وکتور تایل:
  - استایل تیره/روشن + شیب دوربین (pitch) + ساختمان‌های سه‌بعدی (fill-extrusion).
  - آفلاین: بسته‌های `.mbtiles`/`.pmtiles` استانی که در اپ دانلود و در `path_provider` ذخیره می‌شوند.
- **موتور مسیریابی آفلاین:** GraphHopper/Valhalla به‌صورت کتابخانه‌ی نیتیو (`MethodChannel`) + گراف OSM محلی.

## دانلود درون‌برنامه‌ای (نقشه و خودرو)
- نقشه‌ها به‌صورت **استانی** (لیست استان‌ها → دانلود `.mbtiles` → ذخیره‌ی محلی → استفاده‌ی آفلاین).
- مدل خودرو: چند `car.glb` قابل دانلود؛ فایل در `assets/models/` یا حافظه‌ی محلی و نمایش با `flutter_3d_controller`.
- جدول‌های دانلود و علاقه‌مندی‌ها در **SQLite (Drift + SQLCipher)** ذخیره می‌شوند.

## صدای فارسی آفلاین
- `flutter_tts` برای TTS؛ برای STT آفلاین از **Vosk** (مدل فارسی سبک) استفاده می‌شود.
