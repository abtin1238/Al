# راهنمای ساخت و بهینه‌سازی «آبتین مسیریاب»

## پیش‌نیازها
- Flutter پایدار (≥ 3.24) و Android SDK / Java 17
- (اختیاری) Xcode برای iOS
- این مخزن پوشهٔ `android/` و `ios/` کامل را commit نمی‌کند؛ **یک‌بار** باید ساخته شوند.

## ساخت سریع (روی سیستم خودت)
```bash
# 1) از ریشهٔ پروژه
flutter create --platforms=android,ios --org ir.abtin --project-name abtin_navigator .

# 2) وابستگی‌ها
flutter pub get

# 3) آیکون
dart run flutter_launcher_icons

# 4) ادغام مجوزها (دستی)
# - android: از android/app/src/main/AndroidManifest.xml.template
# - ios: از ios/Runner/Info.plist.additions.xml

# 5) آنالیز و تست
flutter analyze
flutter test

# 6) APK سبک (هر ABI جدا)
flutter build apk --release --split-per-abi --tree-shake-icons
```
خروجی در `build/app/outputs/flutter-apk/`.

## ساخت خودکار در گیت‌هاب (بدون نیاز به سیستم)
فایل `.github/workflows/build-apk.yml` آماده است:

1. پروژه را روی GitHub push کنید (شاخه `main` یا `master`)
2. در تب **Actions** workflow را اجرا کنید (یا خودکار با push)
3. Artifact به نام `abtin-apks` را دانلود کنید

Workflow این کارها را انجام می‌دهد:
- `flutter create` برای ساخت `android/`/`ios/`
- `pub get` + launcher icons
- minify/shrink + ProGuard
- `flutter build apk --release --split-per-abi --obfuscate`

## نقشه‌های آفلاین
- بستهٔ نمونه: `assets/maps/tehran_sample_*.json` (گراف + POI)
- دانلود کاشی: صفحهٔ **تنظیمات → نقشه‌های آفلاین** (یک‌بار آنلاین، بعداً آفلاین)
- موتور مسیریابی برای کار کردن **نیاز به اینترنت ندارد**

## مدل خودرو GLB
- فایل: `assets/models/car.glb`
- رندر فعلی: مارکر ۳بعدی سفارشی + مسیر ارتقا به `flutter_cube`/`model_viewer`

## دیتابیس رمزنگاری‌شده
- مسیر runtime: `abtin_secure.db` (Documents)
- SQLCipher passphrase از `SecureKeyStore`
- Migration با `PRAGMA user_version`
- برای تست: `AppDatabase.openInMemory()`

## صدای فارسی آفلاین
- `flutter_tts` برای TTS
- برای STT آفلاین فارسی: مدل **Vosk** را جداگانه به `assets/vosk/` اضافه و از طریق FFI/پلاگین وصل کنید

## عیب‌یابی رایج
| مشکل | راه‌حل |
|------|--------|
| `flutter_map_tile_caching` API | نسخه را با `pub outdated` چک کنید؛ سرویس دانلود را با API نسخهٔ نصب‌شده تطبیق دهید |
| SQLCipher روی دسکتاپ | fallback حافظه در `AppBootstrap` |
| خطای package name در تست | `name: abtin_navigator` در pubspec |

## Performance Budget
- هدف: 60 FPS در ناوبری
- Cold start: init سبک + lazy load سرویس‌های سنگین
- Release با `--tree-shake-icons` و R8/ProGuard
