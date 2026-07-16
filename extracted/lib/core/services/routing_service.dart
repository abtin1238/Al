import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../features/navigation/domain/entities/route_info.dart';

/// سرویسِ مسیریابیِ **آنلاینِ واقعی** بر پایه‌ی OSRM (Open Source Routing Machine)
/// که مستقیماً روی گرافِ جاده‌ایِ واقعیِ OpenStreetMap محاسبه می‌شود —
/// جایگزینِ کاملِ موتورِ A* روی گرافِ نمونه/فیک.
class RoutingService {
  RoutingService();

  static const _baseUrl = 'https://router.project-osrm.org/route/v1';

  /// محاسبه‌ی مسیرِ واقعی بین دو نقطه. سرورِ عمومیِ OSRM فعلاً فقط پروفایلِ
  /// «driving» را پشتیبانی می‌کند؛ برای بقیه‌ی وسایل از همان مسیرِ رانندگی
  /// (نزدیک‌ترین تقریبِ در دسترس) استفاده می‌شود.
  Future<RouteInfo> route(
    LatLng origin,
    LatLng destination, {
    TravelMode mode = TravelMode.car,
    RoutePreference preference = RoutePreference.fastest,
  }) async {
    final profile = 'driving';
    final coords =
        '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
    final uri = Uri.parse('$_baseUrl/$profile/$coords').replace(
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'true',
        'alternatives': 'false',
      },
    );

    final res =
        await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw RoutingException('خطا در دریافت مسیر (${res.statusCode})');
    }

    final Map<String, dynamic> data =
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (data['code'] != 'Ok') {
      throw RoutingException('مسیری بین این دو نقطه یافت نشد');
    }

    final routes = data['routes'] as List;
    if (routes.isEmpty) {
      throw RoutingException('مسیری بین این دو نقطه یافت نشد');
    }
    final routeJson = routes.first as Map<String, dynamic>;

    final geometry = routeJson['geometry'] as Map<String, dynamic>;
    final coordsList = (geometry['coordinates'] as List)
        .map((c) => LatLng((c as List)[1] as double, c[0] as double))
        .toList();

    final steps = <ManeuverStep>[];
    final legs = routeJson['legs'] as List? ?? const [];
    for (final legRaw in legs) {
      final leg = legRaw as Map<String, dynamic>;
      final legSteps = leg['steps'] as List? ?? const [];
      for (final stepRaw in legSteps) {
        final step = stepRaw as Map<String, dynamic>;
        final maneuver = step['maneuver'] as Map<String, dynamic>? ?? const {};
        final loc = maneuver['location'] as List?;
        final point = loc != null
            ? LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble())
            : coordsList.first;
        steps.add(ManeuverStep(
          instruction: _instructionFor(step, maneuver),
          distanceMeters: ((step['distance'] as num?) ?? 0).toDouble(),
          type: _maneuverType(maneuver),
          point: point,
        ));
      }
    }

    return RouteInfo(
      polyline: coordsList,
      steps: steps,
      distanceMeters: ((routeJson['distance'] as num?) ?? 0).toDouble(),
      duration:
          Duration(seconds: ((routeJson['duration'] as num?) ?? 0).round()),
      mode: mode,
      preference: preference,
    );
  }

  String _instructionFor(
    Map<String, dynamic> step,
    Map<String, dynamic> maneuver,
  ) {
    final roadName = (step['name'] as String?) ?? '';
    final type = _maneuverType(maneuver);
    final base = switch (type) {
      ManeuverType.turnRight => 'به راست بپیچید',
      ManeuverType.turnLeft => 'به چپ بپیچید',
      ManeuverType.slightRight => 'کمی به راست بپیچید',
      ManeuverType.slightLeft => 'کمی به چپ بپیچید',
      ManeuverType.uTurn => 'دور بزنید',
      ManeuverType.roundabout => 'وارد میدان شوید',
      ManeuverType.arrive => 'به مقصد رسیدید',
      ManeuverType.depart => 'شروع مسیر',
      ManeuverType.straight => 'مستقیم ادامه دهید',
    };
    if (roadName.isNotEmpty && type != ManeuverType.arrive) {
      return '$base در $roadName';
    }
    return base;
  }

  ManeuverType _maneuverType(Map<String, dynamic> maneuver) {
    final type = (maneuver['type'] as String?) ?? '';
    final modifier = (maneuver['modifier'] as String?) ?? '';
    if (type == 'arrive') return ManeuverType.arrive;
    if (type == 'depart') return ManeuverType.depart;
    if (type == 'roundabout' || type == 'rotary') {
      return ManeuverType.roundabout;
    }
    if (modifier.contains('uturn')) return ManeuverType.uTurn;
    if (modifier == 'right') return ManeuverType.turnRight;
    if (modifier == 'left') return ManeuverType.turnLeft;
    if (modifier == 'slight right') return ManeuverType.slightRight;
    if (modifier == 'slight left') return ManeuverType.slightLeft;
    if (modifier == 'sharp right') return ManeuverType.turnRight;
    if (modifier == 'sharp left') return ManeuverType.turnLeft;
    return ManeuverType.straight;
  }
}

class RoutingException implements Exception {
  final String message;
  RoutingException(this.message);
  @override
  String toString() => message;
}
