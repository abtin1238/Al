# آبتین — مسیریاب هوشمند آفلاین 🧭
### Aabtin — Offline Smart Navigator (Flutter)

اپلیکیشن مسیریاب **کاملاً آفلاین** با Flutter، معماری Clean Architecture و مدیریت وضعیت Riverpod.  
رابط کاربری دقیقاً بر اساس تصاویر مرجع (تم تیره/فیروزه‌ای، RTL فارسی) و برندینگ «آبتین».

---

## ✅ وضعیت پیاده‌سازی

| بخش | وضعیت | مسیر |
|---|---|---|
| Clean Architecture + Riverpod | ✅ | `lib/core`, `lib/features` |
| تم روشن/تیره + RTL + Vazirmatn | ✅ | `core/theme` |
| نوار ناوبری پایین شیشه‌ای (۵ تب) | ✅ | `core/widgets/app_bottom_nav.dart` |
| موتور A* آفلاین + چندحالته | ✅ | `features/routing/data/offline_routing_engine.dart` |
| مسیریابی offline-first (بدون OSRM اجباری) | ✅ | `core/services/routing_service.dart` |
| Kalman + Dead Reckoning | ✅ | `kalman_filter.dart`, `location_service.dart` |
| SQLite رمزنگاری‌شده (SQLCipher) + Migration | ✅ | `core/database/app_database.dart` |
| علاقه‌مندی‌ها روی DB | ✅ | `features/favorites` |
| جستجوی POI آفلاین | ✅ | `features/search/data/offline_search_service.dart` |
| هشدار دوربین/مدرسه/تونل | ✅ | `hazard_monitor.dart` + seed DB |
| Lane Guidance UI | ✅ | `lane_guidance.dart` |
| مشاور مسیر هوشمند آفلاین | ✅ | `core/ai/smart_route_advisor.dart` |
| Deep Link parser | ✅ | `core/deeplink` |
| Android Auto / CarPlay bridge | 🔶 قرارداد + manifest | `core/platform/car_projection.dart` |
| بسته نقشه نمونه + گراف JSON | ✅ | `assets/maps/` |
| مدل خودرو GLB | ✅ | `assets/models/car.glb` |
| GitHub Actions APK | ✅ | `.github/workflows/build-apk.yml` |
| Unit / Widget tests | ✅ | `test/` |

---

## اجرای سریع
```bash
flutter create --platforms=android,ios --org ir.abtin --project-name abtin_navigator .
flutter pub get
flutter test
flutter run
```
جزئیات کامل: [BUILD.md](./BUILD.md) · معماری: [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)

---

## ساختار
```
lib/
  core/        bootstrap, database, services, theme, deeplink, ai
  features/    navigation, routing, search, favorites, voice, settings
assets/
  maps/        tehran sample graph + POIs
  models/      car.glb
  fonts/       Vazirmatn
  gauges/      speedometer assets
```

---

## اصل طلایی
> تمام پردازش‌های اصلی مسیریابی، جستجو، علاقه‌مندی و هشدار **آفلاین** هستند.  
> شبکه فقط برای **دانلود اولیهٔ کاشی نقشه** اختیاری است.

---

## برند
- فیروزه‌ای اولیه: `#00E5D0`
- لهجهٔ برند: طلایی `#D4AF37`
- تم پیش‌فرض: تیره `#0A0E1A`

هدف نهایی: پلتفرم مسیریابی آفلاین سه‌بعدی نسل جدید با کیفیت محصول تجاری جهانی.
