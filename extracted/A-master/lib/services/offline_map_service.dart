import 'package:flutter_map/flutter_map.dart';

class OfflineMapService {
  /// Create a simple offline tile layer (placeholder for now)
  static Future<TileLayer> createOfflineTileLayer() async {
    // فعلاً فقط نقشه آنلاین برمی‌گرداند
    // در نسخه بعدی می‌توان از cached tiles یا MBTiles استفاده کرد
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.navi_app',
    );
  }

  /// Simulation for downloading city/province map
  static Future<String> downloadOfflineMap(String city) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'دانلود نقشه $city با موفقیت انجام شد';
  }
}