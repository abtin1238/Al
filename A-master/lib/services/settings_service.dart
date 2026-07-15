import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static const String _boxName = 'settings';
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // مقادیر پیش‌فرض
  static bool get showSpeed => _box.get('showSpeed', defaultValue: true);
  static bool get showSpeedLimit => _box.get('showSpeedLimit', defaultValue: true);
  static bool get voiceGuidance => _box.get('voiceGuidance', defaultValue: true);
  static bool get nightMode => _box.get('nightMode', defaultValue: true);
  static double get mapZoom => _box.get('mapZoom', defaultValue: 16.0);
  static String get mapProvider => _box.get('mapProvider', defaultValue: 'osm');

  static Future<void> setShowSpeed(bool value) async => await _box.put('showSpeed', value);
  static Future<void> setShowSpeedLimit(bool value) async => await _box.put('showSpeedLimit', value);
  static Future<void> setVoiceGuidance(bool value) async => await _box.put('voiceGuidance', value);
  static Future<void> setNightMode(bool value) async => await _box.put('nightMode', value);
  static Future<void> setMapZoom(double value) async => await _box.put('mapZoom', value);
  static Future<void> setMapProvider(String value) async => await _box.put('mapProvider', value);
}