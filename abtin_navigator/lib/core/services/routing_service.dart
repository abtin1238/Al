import 'package:latlong2/latlong.dart';

import '../../features/navigation/data/offline_map_data.dart';
import '../../features/navigation/domain/entities/route_info.dart';
import '../../features/routing/data/offline_routing_engine.dart';
import '../ai/smart_route_advisor.dart';

/// سرویس مسیریابی **آفلاین‌اول**.
///
/// ۱) موتور A* روی گراف محلی (تهران نمونه / بسته‌های نصب‌شده)
/// ۲) در صورت نیاز، فراخوانی اختیاری آنلاین فقط برای توسعه — پیش‌فرض خاموش
class RoutingService {
  RoutingService({
    OfflineRoutingEngine? engine,
    SmartRouteAdvisor? advisor,
  })  : _engine = engine ?? OfflineRoutingEngine(),
        _advisor = advisor ?? const SmartRouteAdvisor();

  final OfflineRoutingEngine _engine;
  final SmartRouteAdvisor _advisor;
  bool _ready = false;

  bool get isReady => _ready;
  OfflineRoutingEngine get engine => _engine;

  /// بارگذاری گراف نمونه تهران (bundled) — بدون شبکه.
  void ensureOfflineGraphLoaded() {
    if (_ready && _engine.isLoaded) return;
    final city = buildTehranSampleCity();
    _engine.loadGraph(city.nodes, city.adjacency);
    _ready = true;
  }

  /// بارگذاری گراف دلخواه (مثلاً از SQLite / JSON بسته نقشه).
  void loadGraph(List<GraphNode> nodes, Map<int, List<GraphEdge>> edges) {
    _engine.loadGraph(nodes, edges);
    _ready = _engine.isLoaded;
  }

  /// محاسبه مسیر کاملاً آفلاین.
  Future<RouteInfo> route(
    LatLng origin,
    LatLng destination, {
    TravelMode mode = TravelMode.car,
    RoutePreference preference = RoutePreference.fastest,
    bool applySmartEta = true,
  }) async {
    ensureOfflineGraphLoaded();
    final result = _engine.calculateRoute(
      origin,
      destination,
      mode: mode,
      preference: preference,
    );
    if (result == null) {
      throw RoutingException('مسیری بین این دو نقطه یافت نشد (آفلاین)');
    }
    if (!applySmartEta) return result;

    final smartDuration = _advisor.predictTravelTime(
      distanceMeters: result.distanceMeters,
      mode: mode,
    );
    return RouteInfo(
      polyline: result.polyline,
      steps: result.steps,
      distanceMeters: result.distanceMeters,
      duration: smartDuration,
      mode: result.mode,
      preference: result.preference,
    );
  }

  /// تغییر مسیر خودکار هنگام خروج از مسیر (Map Matching + A*).
  Future<RouteInfo?> reroute({
    required LatLng current,
    required LatLng destination,
    TravelMode mode = TravelMode.car,
    RoutePreference preference = RoutePreference.fastest,
  }) async {
    try {
      return await route(
        current,
        destination,
        mode: mode,
        preference: preference,
      );
    } catch (_) {
      return null;
    }
  }
}

class RoutingException implements Exception {
  final String message;
  RoutingException(this.message);
  @override
  String toString() => message;
}
