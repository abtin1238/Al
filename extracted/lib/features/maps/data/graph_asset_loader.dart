import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../navigation/domain/entities/route_info.dart';
import '../../routing/data/offline_routing_engine.dart';

/// بارگذاری گراف جاده از asset JSON (بسته نقشه آفلاین).
class GraphAssetLoader {
  static const defaultAsset = 'assets/maps/tehran_sample_graph.json';

  static Future<({List<GraphNode> nodes, Map<int, List<GraphEdge>> edges})>
      load([String asset = defaultAsset]) async {
    final raw = await rootBundle.loadString(asset);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final nodesJson = data['nodes'] as List<dynamic>;
    final edgesJson = data['edges'] as List<dynamic>;

    final nodes = <GraphNode>[];
    for (final n in nodesJson) {
      final m = n as Map<String, dynamic>;
      nodes.add(GraphNode(
        (m['id'] as num).toInt(),
        LatLng((m['lat'] as num).toDouble(), (m['lon'] as num).toDouble()),
      ));
    }

    const modes = {
      TravelMode.car,
      TravelMode.truck,
      TravelMode.motorcycle,
      TravelMode.bicycle,
      TravelMode.pedestrian,
    };

    final adj = <int, List<GraphEdge>>{};
    void add(int a, int b, double meters, double speed) {
      (adj[a] ??= []).add(GraphEdge(
        to: b,
        distanceMeters: meters,
        speedKmh: speed,
        allowedModes: modes,
      ));
      (adj[b] ??= []).add(GraphEdge(
        to: a,
        distanceMeters: meters,
        speedKmh: speed,
        allowedModes: modes,
      ));
    }

    for (final e in edgesJson) {
      final m = e as Map<String, dynamic>;
      add(
        (m['a'] as num).toInt(),
        (m['b'] as num).toInt(),
        ((m['m'] as num?) ?? 50).toDouble(),
        ((m['speed'] as num?) ?? 40).toDouble(),
      );
    }

    return (nodes: nodes, edges: adj);
  }
}
