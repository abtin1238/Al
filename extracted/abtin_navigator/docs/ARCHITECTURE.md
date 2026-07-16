# معماری آبتین (Aabtin Navigator)

## هدف
اپلیکیشن مسیریاب **کاملاً آفلاین** برای Android/iOS با Flutter، کیفیت محصول تجاری.

## لایه‌ها (Clean Architecture + Feature-based)

```
lib/
  core/               # زیرساخت مشترک
    database/         # SQLite + SQLCipher (رمزنگاری فایل)
    services/         # Routing, Geocoding, Location, TTS, Offline tiles
    providers/        # Riverpod DI
    theme/            # تم تیره/روشن، RTL، Vazirmatn
    ai/               # مشاور مسیر آفلاین
    deeplink/         # Intent / Universal Link parser
    platform/         # Android Auto / CarPlay bridge
  features/
    navigation/       # ناوبری زنده، نقشه، مانور، خودرو
    routing/          # موتور A*، Kalman، تنظیمات مسیر
    search/           # جستجوی POI آفلاین
    favorites/        # علاقه‌مندی‌ها (Repository + SQLite)
    voice/            # TTS + state machine راهنما
    settings/         # تم، نقشه‌های آفلاین
```

### Domain
موجودیت‌های خالص: `Place`, `RouteInfo`, `NavigationState`, `ManeuverStep`.

### Data
- `OfflineRoutingEngine` — A* روی گراف محلی
- `AppDatabase` — SQLCipher + migration (`user_version`)
- `FavoritesRepository`, `OfflineSearchService`, `HazardMonitor`
- Tile cache: `flutter_map_tile_caching`

### Presentation
صفحه‌ها و ویجت‌ها با Riverpod؛ ناوبری پایین شیشه‌ای ۵ تب.

## جریان مسیریابی آفلاین
1. گراف نمونه تهران از `offline_map_data.dart` / `assets/maps/*.json` بارگذاری می‌شود.
2. `RoutingService.route` فقط A* محلی را صدا می‌زند.
3. `NavigationController` turn-by-turn، ETA، سرعت و reroute را مدیریت می‌کند.
4. GPS با Kalman + Dead Reckoning پایدار می‌ماند.
5. TTS فارسی مانورها و هشدارها را اعلام می‌کند.

## امنیت
- فایل دیتابیس با SQLCipher رمز می‌شود.
- passphrase از `SecureKeyStore` (قابل ارتقا به Keystore/Keychain).
- Least privilege در manifest.

## عملکرد
- هدف: 60 FPS، Cold start < 2s (با lazy init سرویس‌ها).
- گراف و POI در حافظه؛ مسیر در isolate-ready API (قابل انتقال به `compute`).

## محدودیت‌های شناخته‌شده / مسیر تکمیل بومی
| مورد | وضعیت |
|------|--------|
| A* offline routing | ✅ |
| SQLCipher DB + migration | ✅ |
| Offline POI search | ✅ |
| Lane guidance UI | ✅ |
| GLB asset | ✅ (`assets/models/car.glb`) |
| Sample offline map package | ✅ |
| Vosk STT full model | 🔶 نیاز به باینری/مدل فارسی جدا |
| GraphHopper/Valhalla native | 🔶 قابل اتصال از طریق FFI/MethodChannel |
| Android Auto / CarPlay UI کامل | 🔶 قرارداد + manifest آماده، UI بومی لازم |
| AR camera overlay | 🔶 اسکلت/گسترش آینده |

## تست
```bash
flutter test
flutter analyze
```
