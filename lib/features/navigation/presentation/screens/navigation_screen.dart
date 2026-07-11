import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/route_info.dart';
import '../widgets/maneuver_banner.dart';
import '../widgets/speedometer.dart';

/// نمای اصلی ناوبری (نقشه‌ی تمام‌صفحه + بنر مانور + سرعت‌سنج).
/// از flutter_map با کاشی‌های OpenStreetMap استفاده می‌کند و برای حالت آفلاین
/// می‌توان provider کاشی را به MBTiles محلی تغییر داد.
class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  final MapController _map = MapController();

  // مسیر نمونه‌ی نمایشی (در نسخه‌ی نهایی از موتور A* آفلاین می‌آید).
  static const List<LatLng> _demoRoute = [
    LatLng(35.7570, 51.4100),
    LatLng(35.7620, 51.4050),
    LatLng(35.7660, 51.3990),
    LatLng(35.7700, 51.3930),
    LatLng(35.7740, 51.3880),
    LatLng(35.7776, 51.4103),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routing = ref.watch(routingSettingsProvider);
    final routeColor = AppColors.routeColors[routing.routeColorIndex];

    return Scaffold(
      body: Stack(
        children: [
          // ---- نقشه ----
          FlutterMap(
            mapController: _map,
            options: const MapOptions(
              initialCenter: LatLng(35.7650, 51.4000),
              initialZoom: 14.5,
              initialRotation: -20,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ir.abtin.navigator',
                // TODO(offline): برای آفلاین کامل، از FMTCTileProvider
                // یا MBTiles محلی استفاده کنید.
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _demoRoute,
                    color: routeColor.withOpacity(routing.routeIntensity),
                    strokeWidth: 8,
                    borderColor: Colors.black.withOpacity(0.3),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // خودرو
                  if (routing.showVehicle)
                    Marker(
                      point: _demoRoute.first,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary
                                    .withOpacity(0.6),
                                blurRadius: 14),
                          ],
                        ),
                        child: const Icon(Icons.navigation_rounded,
                            color: Colors.black, size: 24),
                      ),
                    ),
                  // مقصد
                  Marker(
                    point: _demoRoute.last,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on_rounded,
                        color: AppColors.danger, size: 40),
                  ),
                ],
              ),
            ],
          ),

          // ---- بنر مانور (بالا) ----
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: const ManeuverBanner(
              distance: '۳۵۰ متر',
              instruction: 'به سمت شیخ بهایی شمالی',
              type: ManeuverType.turnRight,
              remainingTime: '۵ دقیقه',
              remainingDistance: '۷.۲ کیلومتر',
              eta: '۲۲:۴۷',
            ),
          ),

          // ---- قطب‌نما ----
          Positioned(
            top: MediaQuery.of(context).padding.top + 170,
            left: 16,
            child: _compass(),
          ),

          // ---- سرعت‌سنج و محدودیت سرعت (پایین راست) ----
          Positioned(
            bottom: 24,
            right: 16,
            child: Row(
              children: const [
                SpeedLimitSign(limit: 60),
                SizedBox(width: 10),
                Speedometer(speed: 68, overLimit: true),
              ],
            ),
          ),

          // ---- دکمه‌ی موقعیت من (پایین چپ) ----
          Positioned(
            bottom: 24,
            left: 16,
            child: FloatingActionButton(
              backgroundColor: AppColors.surfaceDark,
              onPressed: () => _map.move(const LatLng(35.7650, 51.4000), 14.5),
              child: const Icon(Icons.my_location_rounded,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compass() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceDark.withOpacity(0.9),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: const Icon(Icons.explore_rounded, color: AppColors.danger, size: 30),
    );
  }
}
