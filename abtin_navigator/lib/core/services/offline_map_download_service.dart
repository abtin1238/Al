import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';

/// یک کشور/منطقه‌ی قابل دانلود برای استفاده‌ی آفلاین.
class DownloadableRegion {
  final String id;
  final String name;
  final LatLngBounds bounds;
  DownloadableRegion(this.id, this.name, this.bounds);
}

/// فهرستِ کشورهای قابل دانلود (قابل گسترش). شروع با ایران مطابق درخواست.
/// توجه: `LatLngBounds` سازنده‌ی const ندارد، پس این فهرست نمی‌تواند const باشد.
final List<DownloadableRegion> downloadableRegions = [
  DownloadableRegion(
    'iran',
    'ایران',
    LatLngBounds(const LatLng(25.0, 44.0), const LatLng(39.8, 63.4)),
  ),
  DownloadableRegion(
    'turkey',
    'ترکیه',
    LatLngBounds(const LatLng(35.8, 25.6), const LatLng(42.2, 44.8)),
  ),
  DownloadableRegion(
    'uae',
    'امارات متحده عربی',
    LatLngBounds(const LatLng(22.5, 51.4), const LatLng(26.1, 56.4)),
  ),
  DownloadableRegion(
    'iraq',
    'عراق',
    LatLngBounds(const LatLng(29.0, 38.7), const LatLng(37.4, 48.8)),
  ),
];

const String _tileUrlTemplate =
    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

/// لایه‌ی مرجع برای دانلودِ کاشی‌ها؛ باید با لایه‌ی نمایش‌داده‌شده روی نقشه
/// (در [OnlineMapView]) هم‌خوان باشد تا کاشی‌های دانلودشده مستقیماً استفاده شوند.
final TileLayer _downloadTileLayer = TileLayer(
  urlTemplate: _tileUrlTemplate,
  subdomains: const ['a', 'b', 'c', 'd'],
  userAgentPackageName: 'com.abtin.navigator',
);

/// سرویسِ مدیریتِ دانلودِ نقشه‌ی آفلاین (بر پایه‌ی FMTC).
///
/// این سرویس یک بار در شروعِ برنامه با [initialise] راه‌اندازی می‌شود، سپس
/// برای هر کشور یک «استور» جدا ساخته و کاشی‌های محدوده‌ی جغرافیاییِ آن را
/// در پس‌زمینه دانلود می‌کند تا بعداً بدون اینترنت هم نقشه نمایش داده شود.
class OfflineMapDownloadService {
  OfflineMapDownloadService();

  bool _initialised = false;

  Future<void> initialise() async {
    if (_initialised) return;
    await FMTCObjectBoxBackend().initialise();
    _initialised = true;
  }

  FMTCStore storeFor(DownloadableRegion region) => FMTCStore(region.id);

  Future<void> ensureStoreCreated(DownloadableRegion region) async {
    await initialise();
    await storeFor(region).manage.create();
  }

  /// شروعِ دانلودِ کاشی‌های یک کشور. جریانِ برگشتی پیشرفتِ دانلود را
  /// (۰ تا ۱) گزارش می‌دهد.
  Stream<double> download(DownloadableRegion region) async* {
    await ensureStoreCreated(region);
    final rectRegion = RectangleRegion(region.bounds);
    final downloadable = rectRegion.toDownloadable(
      minZoom: 3,
      maxZoom: 15,
      options: _downloadTileLayer,
    );
    final progressStream =
        storeFor(region).download.startForeground(region: downloadable);
    await for (final event in progressStream) {
      yield event.percentageProgress / 100;
    }
  }

  Future<void> cancelDownload(DownloadableRegion region) async {
    await storeFor(region).download.cancel();
  }

  Future<bool> isDownloaded(DownloadableRegion region) async {
    await initialise();
    try {
      final tileCount = await storeFor(region).stats.length;
      return tileCount > 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> remove(DownloadableRegion region) async {
    await initialise();
    await storeFor(region).manage.delete();
  }

  /// فهرستِ شناسه‌ی استورهایی که حداقل یک کاشی در آن‌ها دانلود شده است.
  /// استفاده در [tileProviderForMap] تا کاشی‌های آفلاینِ همه‌ی مناطقِ
  /// دانلودشده به‌صورتِ یکجا در دسترسِ نقشه‌ی زنده قرار گیرد.
  Future<List<String>> downloadedStoreIds() async {
    await initialise();
    final ids = <String>[];
    for (final region in downloadableRegions) {
      if (await isDownloaded(region)) ids.add(region.id);
    }
    return ids;
  }

  /// یک `TileProvider` که ابتدا کاشی‌های آفلاینِ ذخیره‌شده (هر منطقه‌ای که
  /// کاربر دانلود کرده) را می‌خواند و اگر کاشی محلی نبود، در صورتِ اتصال به
  /// اینترنت از شبکه دریافت می‌کند. این یعنی [OnlineMapView] در مناطقی که
  /// از پیش دانلود شده‌اند، کاملاً آفلاین کار می‌کند.
  Future<FMTCTileProvider> tileProviderForMap() async {
    await initialise();
    final ids = await downloadedStoreIds();
    // اگر هنوز هیچ منطقه‌ای دانلود نشده، یک استورِ عمومیِ کش (cache) با
    // نامِ ثابت استفاده می‌شود تا حداقل کاشی‌های اخیراً بازدیدشده در حافظه
    // بمانند و در قطعیِ موقتِ اینترنت هم چیزی برای نمایش وجود داشته باشد.
    final storeNames = ids.isNotEmpty ? ids : <String>['_browse_cache'];
    if (storeNames.first == '_browse_cache') {
      await FMTCStore('_browse_cache').manage.create();
    }
    return FMTCTileProvider(
      stores: {for (final id in storeNames) id: BrowseStoreStrategy.readUpdateCreate},
    );
  }
}
