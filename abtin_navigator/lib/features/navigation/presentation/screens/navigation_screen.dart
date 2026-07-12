import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/navigation_controller.dart';
import '../widgets/maneuver_banner.dart';
import '../widgets/speedometer.dart';
import '../widgets/car_marker.dart';
import '../widgets/nav_compass.dart';

/// نمای اصلی ناوبری: نقشه‌ی تمام‌صفحه (با پرسپکتیو سه‌بعدی) + نوار مانورِ داینامیک
/// + قطب‌نما + سرعت‌سنج + تابلوی محدودیت (شرطی) + دکمه‌ی موقعیت.
/// چیدمان دقیقاً مطابق تصویر مرجع و همه‌ی داده‌ها از [navigationControllerProvider].
class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  final MapController _map = MapController();

  // مسیر نمونه‌ی نمایشی (در نسخه‌ی نهایی از موتور A*/GraphHopper آفلاین می‌آید).
  static const List<LatLng> _demoRoute = [
    LatLng(35.7570, 51.4100),
    LatLng(35.7620, 51.4050),
    LatLng(35.7660, 51.3990),
    LatLng(35.7700, 51.3930),
    LatLng(35.7740, 51.3880),
    LatLng(35.7776, 51.4103),
  ];

  @override
  Widget build(BuildContext context) {
    final routing = ref.watch(routingSettingsProvider);
    final nav = ref.watch(navigationControllerProvider);
    final routeColor = AppColors.routeColors[routing.routeColorIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF0D1420),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // ---- نقشه‌ی تمام‌صفحه با پرسپکتیو سه‌بعدی ----
            _MapWithPerspective(
              tilt: routing.threeDMap ? 0.55 : 0.28,
              child: FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter: nav.position ?? const LatLng(35.7650, 51.4000),
                  initialZoom: 15.5,
                  initialRotation: -nav.headingDeg,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: isDark
                        ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'ir.abtin.navigator',
                    tileProvider: NetworkTileProvider(),
                    // آفلاین: اینجا با MbTilesTileProvider / FMTC جایگزین می‌شود.
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _demoRoute,
                        color: routeColor.withOpacity(routing.routeIntensity),
                        strokeWidth: 9,
                        borderColor: Colors.black.withOpacity(0.35),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      if (routing.showVehicle)
                        Marker(
                          point: nav.position ?? _demoRoute.first,
                          width: 90,
                          height: 90,
                          child: CarMarker(
                            headingDeg: nav.headingDeg,
                            headlights: routing.headlightsAtNight && isDark,
                          ),
                        ),
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
            ),

            // ---- نوار مانور داینامیک (بالا) ----
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: ManeuverBanner(
                state: nav,
                onClose: () =>
                    ref.read(bottomNavIndexProvider.notifier).state = 3,
              ),
            ),

            // ---- قطب‌نما (راست، زیر نوار) ----
            Positioned(
              top: MediaQuery.of(context).padding.top + 176,
              right: 16,
              child: NavCompass(headingDeg: nav.headingDeg),
            ),

            // ---- سرعت‌سنج + تابلوی محدودیت (پایین چپ) ----
            Positioned(
              bottom: 20,
              left: 16,
              child: Row(
                children: [
                  Speedometer(
                    speed: nav.currentSpeedKmh,
                    overLimit: nav.isOverLimit,
                  ),
                  const SizedBox(width: 10),
                  // تابلوی محدودیت فقط هنگام نزدیک‌شدن به محدوده نمایش داده می‌شود.
                  if (nav.shouldShowSpeedLimit)
                    SpeedLimitSign(limit: nav.speedLimitKmh!),
                ],
              ),
            ),

            // ---- دکمه‌ی موقعیت من (پایین راست) ----
            Positioned(
              bottom: 24,
              right: 16,
              child: _LocationButton(
                onTap: () => _map.move(
                    nav.position ?? const LatLng(35.7650, 51.4000), 15.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// اعمال پرسپکتیوِ سه‌بعدی روی نقشه (شبیه‌سازی شیب دوربین تا زمان مهاجرت به MapLibre).
class _MapWithPerspective extends StatelessWidget {
  final Widget child;
  final double tilt; // 0 = تخت، بیشتر = شیب بیشتر
  const _MapWithPerspective({required this.child, required this.tilt});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..rotateX(tilt),
      child: OverflowBox(
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 1.7,
        child: child,
      ),
    );
  }
}

/// دکمه‌ی شناور موقعیت من (پین سبز مطابق تصویر).
class _LocationButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LocationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF141B2B),
          border: Border.all(color: AppColors.borderDark),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12),
          ],
        ),
        child: const Icon(Icons.location_on_rounded,
            color: AppColors.primary, size: 28),
      ),
    );
  }
}
