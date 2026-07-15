import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/navigation_instruction_panel.dart';
import '../widgets/speed_limit_sign.dart';
import '../widgets/speedometer_gauge.dart';
import '../widgets/map_side_controls.dart';
import '../widgets/bottom_action_bar.dart';
import '../services/settings_service.dart';
import '../services/offline_map_service.dart';
import '../widgets/arrow_marker_3d.dart';
import '../widgets/favorite_locations_sheet.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();

  // داده‌های داینامیک
  double _currentSpeed = 68.0;
  LatLng _currentPosition = const LatLng(35.7219, 51.3347); // تهران - میرداماد
  double _remainingDistance = 7.2;
  String _remainingTime = "۱۲ دقیقه";
  String _arrivalTime = "۲۲:۴۷";

  bool _showSpeed = true;
  bool _showSpeedLimit = true;
  bool _useOfflineMap = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _simulateMovement();
  }

  Future<void> _loadSettings() async {
    await SettingsService.init();
    setState(() {
      _showSpeed = SettingsService.showSpeed;
      _showSpeedLimit = SettingsService.showSpeedLimit;
    });
  }

  // شبیه‌سازی حرکت خودرو (داینامیک)
  void _simulateMovement() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _currentSpeed = (_currentSpeed + (DateTime.now().millisecond % 7) - 2).clamp(45, 95);
        _remainingDistance = (_remainingDistance - 0.15).clamp(0.1, 20);
        _remainingTime = "${(_remainingDistance * 1.6).toInt()} دقیقه";
        
        // حرکت مختصر روی نقشه
        _currentPosition = LatLng(
          _currentPosition.latitude + 0.0003,
          _currentPosition.longitude + 0.0002,
        );
        
        _mapController.move(_currentPosition, SettingsService.mapZoom);
      });
      _simulateMovement();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== نقشه آنلاین واقعی =====
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: SettingsService.mapZoom,
              minZoom: 5,
              maxZoom: 19,
            ),
            children: [
              if (_useOfflineMap)
                FutureBuilder<TileLayer>(
                  future: OfflineMapService.createOfflineTileLayer(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) return snapshot.data!;
                    return const SizedBox();
                  },
                )
              else
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.navi_app',
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 50,
                    height: 50,
                    child: ArrowMarker3D(rotation: 35),
                  ),
                ],
              ),
            ],
          ),

          // پنل دستورالعمل بالا
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: NavigationInstructionPanel(
                  distanceText: '${_remainingDistance.toStringAsFixed(1)} km',
                  instructionPrefix: 'به سمت',
                  instructionHighlight: 'شیخ بهایی',
                  instructionSuffix: 'شمالی',
                  arrivalTime: _arrivalTime,
                  remainingDistance: '${_remainingDistance.toStringAsFixed(1)} km',
                  remainingTime: _remainingTime,
                  onExpandTap: () {},
                ),
              ),
            ),
          ),

          // تابلوی سرعت مجاز
          if (_showSpeedLimit)
            Positioned(
              top: 8,
              right: 16,
              child: SafeArea(
                bottom: false,
                child: const SpeedLimitSign(limit: 60),
              ),
            ),

          // سرعت‌سنج
          if (_showSpeed)
            Positioned(
              bottom: 118,
              left: 16,
              child: SpeedometerGauge(speed: _currentSpeed),
            ),

          // کنترل‌های کناری
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.38,
            child: MapSideControls(
              onMyLocation: () {
                _mapController.move(_currentPosition, SettingsService.mapZoom);
              },
            ),
          ),

          // دکمه مکان‌های مورد علاقه (FAB)
          Positioned(
            bottom: 90,
            right: 24,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => FavoriteLocationsSheet(
                    onLocationSelected: (loc) {
                      _mapController.move(
                        LatLng(loc.lat, loc.lng),
                        SettingsService.mapZoom,
                      );
                    },
                  ),
                );
              },
              child: const Icon(Icons.star, color: Colors.amber),
            ),
          ),

          // نوار پایین
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BottomActionBar(
                  onRouteTap: () => _startNavigation(),
                  onSaveTap: () {},
                  onSearchTap: () {},
                  onVoiceTap: () {},
                  onSettingsTap: () => _openSettings(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startNavigation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('مسیریابی آنلاین شروع شد')),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (_) => _SettingsSheet(
        onSettingsChanged: () {
          setState(() {
            _showSpeed = SettingsService.showSpeed;
            _showSpeedLimit = SettingsService.showSpeedLimit;
          });
        },
      ),
    );
  }
}

// ===== شیت تنظیمات داینامیک =====
class _SettingsSheet extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  const _SettingsSheet({required this.onSettingsChanged});

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('تنظیمات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('نمایش سرعت‌سنج'),
            value: SettingsService.showSpeed,
            onChanged: (val) async {
              await SettingsService.setShowSpeed(val);
              widget.onSettingsChanged();
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('نمایش تابلوی سرعت مجاز'),
            value: SettingsService.showSpeedLimit,
            onChanged: (val) async {
              await SettingsService.setShowSpeedLimit(val);
              widget.onSettingsChanged();
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('راهنمای صوتی'),
            value: SettingsService.voiceGuidance,
            onChanged: (val) async {
              await SettingsService.setVoiceGuidance(val);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('استفاده از نقشه آفلاین (MBTiles)'),
            value: _useOfflineMap,
            onChanged: (val) {
              setState(() => _useOfflineMap = val);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }
}