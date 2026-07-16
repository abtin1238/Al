import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../features/navigation/domain/entities/place.dart';

/// سرویسِ ژئوکدینگِ **آنلاینِ واقعی** (بر پایه‌ی OpenStreetMap / Nominatim).
///
/// این سرویس جایگزینِ کاملِ دیتابیس‌های نمونه‌ی ثابت (Fake Data) است:
/// هر جستجو مستقیماً و به‌صورت داینامیک از سرویسِ نقشه گرفته می‌شود.
class GeocodingService {
  GeocodingService();

  static const _searchUrl = 'https://nominatim.openstreetmap.org/search';
  static const _reverseUrl = 'https://nominatim.openstreetmap.org/reverse';

  // Nominatim از هر کلاینت می‌خواهد یک User-Agent شناسا معرفی کند.
  static const _headers = {
    'User-Agent': 'AabtinNavigator/1.0 (offline-navigation-app)',
    'Accept-Language': 'fa',
  };

  /// جستجوی متنی و داینامیک روی نقشه‌ی زنده (بدون هیچ داده‌ی از پیش تعریف‌شده).
  /// اگر [near] داده شود نتایج نزدیک‌تر به آن نقطه در اولویت قرار می‌گیرند.
  Future<List<Place>> search(String query, {LatLng? near}) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final params = <String, String>{
      'q': q,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '12',
      'accept-language': 'fa',
    };
    if (near != null) {
      // یک محدوده‌ی جستجوی نرم حول موقعیت فعلی برای نتایج مرتبط‌تر.
      params['viewbox'] =
          '${near.longitude - 0.6},${near.latitude + 0.6},${near.longitude + 0.6},${near.latitude - 0.6}';
      params['bounded'] = '0';
    }

    final uri = Uri.parse(_searchUrl).replace(queryParameters: params);
    final res = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      throw GeocodingException('خطا در دریافت نتایج جستجو (${res.statusCode})');
    }

    final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    return data
        .map((raw) => _placeFromJson(raw as Map<String, dynamic>))
        .whereType<Place>()
        .toList();
  }

  /// ژئوکدینگِ معکوس: تبدیلِ یک نقطه‌ی روی نقشه (لمس طولانی کاربر) به آدرسِ
  /// واقعی — برای نمایشِ نامِ مقصد هنگام مسیریابیِ داینامیک.
  Future<Place> reverse(LatLng point) async {
    final params = <String, String>{
      'lat': '${point.latitude}',
      'lon': '${point.longitude}',
      'format': 'jsonv2',
      'addressdetails': '1',
      'accept-language': 'fa',
      'zoom': '18',
    };
    final uri = Uri.parse(_reverseUrl).replace(queryParameters: params);
    final res = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      throw GeocodingException('خطا در شناسایی نقطه (${res.statusCode})');
    }

    final Map<String, dynamic> data =
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final place = _placeFromJson(data, fallback: point);
    return place ??
        Place(
          id: 'point_${point.latitude}_${point.longitude}',
          title: 'نقطه‌ی انتخابی',
          subtitle:
              '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
          location: point,
        );
  }

  Place? _placeFromJson(Map<String, dynamic> json, {LatLng? fallback}) {
    final latStr = json['lat'] as String?;
    final lonStr = json['lon'] as String?;
    final lat = latStr != null ? double.tryParse(latStr) : fallback?.latitude;
    final lon = lonStr != null ? double.tryParse(lonStr) : fallback?.longitude;
    if (lat == null || lon == null) return null;

    final display = (json['display_name'] as String?) ?? '';
    final address = json['address'] as Map<String, dynamic>?;
    final name = (json['name'] as String?)?.trim();

    String title;
    if (name != null && name.isNotEmpty) {
      title = name;
    } else if (display.contains(',')) {
      title = display.split(',').first.trim();
    } else {
      title = display.isNotEmpty ? display : 'مکان بدون نام';
    }

    String subtitle;
    if (display.isNotEmpty) {
      final parts = display.split(',').map((e) => e.trim()).toList();
      subtitle = parts.length > 1 ? parts.sublist(1).take(3).join('، ') : display;
    } else if (address != null) {
      subtitle = address.values.whereType<String>().take(3).join('، ');
    } else {
      subtitle = '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
    }

    return Place(
      id: 'osm_${json['osm_type'] ?? 'p'}_${json['osm_id'] ?? '${lat}_$lon'}',
      title: title,
      subtitle: subtitle,
      location: LatLng(lat, lon),
      category: _categoryFromJson(json),
    );
  }

  PlaceCategory _categoryFromJson(Map<String, dynamic> json) {
    final cls = (json['class'] as String?) ?? '';
    final type = (json['type'] as String?) ?? '';
    switch (cls) {
      case 'amenity':
        if (type.contains('restaurant') || type.contains('food')) {
          return PlaceCategory.restaurant;
        }
        if (type.contains('cafe')) return PlaceCategory.cafe;
        if (type.contains('fuel')) return PlaceCategory.fuel;
        if (type.contains('parking')) return PlaceCategory.parking;
        if (type.contains('hospital') || type.contains('clinic')) {
          return PlaceCategory.hospital;
        }
        if (type.contains('pharmacy')) return PlaceCategory.pharmacy;
        if (type.contains('bank')) return PlaceCategory.bank;
        return PlaceCategory.other;
      case 'shop':
        return PlaceCategory.shopping;
      case 'tourism':
        if (type.contains('hotel')) return PlaceCategory.hotel;
        return PlaceCategory.travel;
      case 'leisure':
        return PlaceCategory.park;
      default:
        return PlaceCategory.other;
    }
  }
}

class GeocodingException implements Exception {
  final String message;
  GeocodingException(this.message);
  @override
  String toString() => message;
}
