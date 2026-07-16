import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';

/// لیست tile providerهای آنلاین به ترتیب اولویت.
/// اگه اولی لود نشد flutter_map خودش به بعدی می‌ره (با FallbackTileProvider).
/// OSM مستقیم بیشترین دسترس‌پذیری رو داره.
const _tileUrl =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// نمای نقشه‌ی آنلاینِ واقعی (OpenStreetMap).
/// - لمس ساده: هیچ کاری نمی‌کنه
/// - لمس طولانی: مقصد رو انتخاب می‌کنه و مسیریابی شروع می‌شه
class OnlineMapView extends StatefulWidget {
  final LatLng camera;
  final double zoom;
  final double headingDeg;
  final List<LatLng> routePolyline;
  final LatLng? destination;
  final Color routeColor;
  final bool isDark;
  final Widget? vehicle;
  final bool followCamera;
  final ValueChanged<LatLng> onLongPressLatLng;
  final MapController? controller;

  const OnlineMapView({
    super.key,
    required this.camera,
    required this.onLongPressLatLng,
    this.zoom = 15,
    this.headingDeg = 0,
    this.routePolyline = const [],
    this.destination,
    this.routeColor = AppColors.primary,
    this.isDark = true,
    this.vehicle,
    this.followCamera = false,
    this.controller,
  });

  @override
  State<OnlineMapView> createState() => _OnlineMapViewState();
}

class _OnlineMapViewState extends State<OnlineMapView> {
  late final MapController _ctrl = widget.controller ?? MapController();
  bool _userInteracting = false;

  @override
  void didUpdateWidget(covariant OnlineMapView old) {
    super.didUpdateWidget(old);
    if (widget.followCamera &&
        !_userInteracting &&
        (old.camera != widget.camera ||
            old.headingDeg != widget.headingDeg)) {
      try {
        _ctrl.moveAndRotate(
            widget.camera, widget.zoom, -widget.headingDeg);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _ctrl,
          options: MapOptions(
            initialCenter: widget.camera,
            initialZoom: widget.zoom,
            minZoom: 2,
            maxZoom: 19,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onMapEvent: (event) {
              // وقتی کاربر دست می‌زنه، followCamera رو موقتاً قطع می‌کنیم
              if (event is MapEventMoveStart) {
                _userInteracting = true;
              } else if (event is MapEventMoveEnd) {
                Future.delayed(
                    const Duration(seconds: 3),
                    () => _userInteracting = false);
              }
            },
            onLongPress: (tapPos, point) =>
                widget.onLongPressLatLng(point),
          ),
          children: [
            // ---- لایه‌ی تایل اصلی: OSM مستقیم (بیشترین دسترس‌پذیری) ----
            TileLayer(
              urlTemplate: _tileUrl,
              userAgentPackageName: 'com.abtin.navigator',
              maxZoom: 19,
              // برای نمای تیره یه filter می‌زنیم
              tileBuilder: widget.isDark ? _darkTileBuilder : null,
            ),
            // ---- مسیر ----
            if (widget.routePolyline.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePolyline,
                    strokeWidth: 7,
                    color: widget.routeColor,
                    borderStrokeWidth: 2.5,
                    borderColor: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
            // ---- مارکرها ----
            MarkerLayer(
              markers: [
                // مقصد
                if (widget.destination != null)
                  Marker(
                    point: widget.destination!,
                    width: 48,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: const _DestinationPin(),
                  ),
                // خودرو / موقعیت کاربر
                if (widget.vehicle != null)
                  Marker(
                    point: widget.camera,
                    width: 70,
                    height: 70,
                    child: widget.vehicle!,
                  )
                else
                  // نقطه‌ی آبی ساده وقتی vehicle نیست
                  Marker(
                    point: widget.camera,
                    width: 28,
                    height: 28,
                    child: const _LocationDot(),
                  ),
              ],
            ),
          ],
        ),
        // ---- attribution ----
        Positioned(
          left: 6,
          bottom: 4,
          child: Text(
            '© OpenStreetMap contributors',
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// فیلتر تاریکی روی تایل‌های نقشه (بدون نیاز به URL جداگانه)
Widget _darkTileBuilder(
    BuildContext context, Widget tileWidget, TileImage tile) {
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix([
      -0.9, 0, 0, 0, 255,
      0, -0.9, 0, 0, 255,
      0, 0, -0.9, 0, 255,
      0, 0, 0, 1, 0,
    ]),
    child: tileWidget,
  );
}

/// پین مقصد با انیمیشن bounce
class _DestinationPin extends StatelessWidget {
  const _DestinationPin();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Icon(
          Icons.location_on_rounded,
          color: AppColors.danger,
          size: 42,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
      ],
    );
  }
}

/// نقطه‌ی آبی درخشان (موقعیت کاربر بدون خودرو)
class _LocationDot extends StatelessWidget {
  const _LocationDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2979FF),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2979FF).withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 2),
        ],
      ),
    );
  }
}
