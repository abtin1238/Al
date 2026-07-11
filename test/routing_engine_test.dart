import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:abtin_navigator/features/routing/data/offline_routing_engine.dart';
import 'package:abtin_navigator/features/routing/data/kalman_filter.dart';
import 'package:abtin_navigator/features/navigation/domain/entities/route_info.dart';

void main() {
  group('OfflineRoutingEngine (A*)', () {
    late OfflineRoutingEngine engine;

    setUp(() {
      engine = OfflineRoutingEngine();
      // گراف خطی ساده: 0 -> 1 -> 2 -> 3
      final nodes = [
        const GraphNode(0, LatLng(35.70, 51.40)),
        const GraphNode(1, LatLng(35.71, 51.41)),
        const GraphNode(2, LatLng(35.72, 51.42)),
        const GraphNode(3, LatLng(35.73, 51.43)),
      ];
      GraphEdge edge(int to) => GraphEdge(
            to: to,
            distanceMeters: 1400,
            speedKmh: 50,
            allowedModes: const {TravelMode.car},
          );
      final edges = {
        0: [edge(1)],
        1: [edge(0), edge(2)],
        2: [edge(1), edge(3)],
        3: [edge(2)],
      };
      engine.loadGraph(nodes, edges);
    });

    test('graph loads', () {
      expect(engine.isLoaded, true);
      expect(engine.nodeCount, 4);
    });

    test('calculates a connected route', () {
      final route = engine.calculateRoute(
        const LatLng(35.70, 51.40),
        const LatLng(35.73, 51.43),
      );
      expect(route, isNotNull);
      expect(route!.polyline.length, greaterThanOrEqualTo(2));
      expect(route.distanceMeters, greaterThan(0));
      expect(route.steps.last.type, ManeuverType.arrive);
    });
  });

  group('GpsKalmanFilter', () {
    test('smooths noisy input toward true value', () {
      final f = GpsKalmanFilter();
      final first = f.process(35.7000, 51.4000, 10);
      expect(first.latitude, closeTo(35.7000, 0.0001));
      final second = f.process(35.7010, 51.4010, 10, speedMps: 5);
      // نتیجه بین دو نمونه قرار می‌گیرد (هموارسازی).
      expect(second.latitude, greaterThan(35.7000));
      expect(second.latitude, lessThanOrEqualTo(35.7010));
    });
  });
}
