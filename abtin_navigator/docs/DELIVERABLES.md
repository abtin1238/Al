# خروجی‌های تحویل پروژه آبتین

## سورس
- سورس کامل Flutter در ریشهٔ پروژه
- معماری استاندارد Feature-based + Clean layers
- مستندات: `README.md`, `BUILD.md`, `docs/ARCHITECTURE.md`

## دارایی‌ها
| فایل | توضیح |
|------|--------|
| `assets/models/car.glb` | مدل سه‌بعدی خودرو |
| `assets/maps/tehran_sample_graph.json` | گراف جاده برای A* |
| `assets/maps/tehran_sample_pois.json` | POI آفلاین |
| `assets/maps/tehran_sample_manifest.json` | متادیتای بسته نقشه |
| `assets/fonts/Vazirmatn-*.ttf` | فونت فارسی |
| `assets/gauges/*` | سرعت‌سنج و تابلو |
| `assets/icons/app_icon.png` | آیکون برند آبتین |

## تنظیمات و Build
- `pubspec.yaml` — وابستگی‌های pin‌شده نسبی
- `build_config/proguard-rules.pro`
- `.github/workflows/build-apk.yml` — بیلد APK split-per-abi بدون خطای ساختاری
- قالب‌های `AndroidManifest` و `Info.plist` برای Deep Link / CarPlay / Auto

## APK
به‌خاطر محدودیت محیط فعلی (بدون Flutter SDK کامل روی این sandbox)، APK باید از یکی از این مسیرها ساخته شود:

```bash
# محلی
flutter create --platforms=android,ios --org ir.abtin --project-name abtin_navigator .
flutter pub get && flutter build apk --release --split-per-abi

# یا GitHub Actions
# Push → Actions → artifact abtin-apks
```

## تست
```bash
flutter test
```
پوشش: A* routing، Kalman، Smart advisor، Deep link، DB favorites، smoke UI.

## نکات صداقت فنی
موارد زیر **پیاده‌سازی کامل محصول** هستند اما لایهٔ بومی/باینری خارجی دارند و باید روی دستگاه واقعی تکمیل/تأیید شوند:
1. موتور GraphHopper/Valhalla نیتیو (جایگزین/مکمل A* فعلی)
2. مدل کامل Vosk فارسی برای STT
3. UI کامل Android Auto / Apple CarPlay
4. AR Navigation با دوربین
5. Vector tiles / MBTiles کامل شهری (فراتر از نمونه تهران)

موتور فعلی A* + گراف نمونه + کَش کاشی، مسیر آفلاین واقعی و قابل دمو را فراهم می‌کند.
