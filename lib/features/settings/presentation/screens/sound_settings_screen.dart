import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';

final _voiceEnabledProvider =
    StateNotifierProvider<_BoolNotifier, bool>((ref) => _BoolNotifier('voice_enabled', true));
final _voiceVolumeProvider =
    StateNotifierProvider<_DoubleNotifier, double>((ref) => _DoubleNotifier('voice_volume', 0.8));
final _vibrationProvider =
    StateNotifierProvider<_BoolNotifier, bool>((ref) => _BoolNotifier('vibration', true));

class _BoolNotifier extends StateNotifier<bool> {
  final String key;
  _BoolNotifier(this.key, bool def) : super(def) { _load(def); }
  Future<void> _load(bool def) async {
    final p = await SharedPreferences.getInstance();
    state = p.getBool(key) ?? def;
  }
  Future<void> set(bool v) async {
    state = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, v);
  }
}

class _DoubleNotifier extends StateNotifier<double> {
  final String key;
  _DoubleNotifier(this.key, double def) : super(def) { _load(def); }
  Future<void> _load(double def) async {
    final p = await SharedPreferences.getInstance();
    state = p.getDouble(key) ?? def;
  }
  Future<void> set(double v) async {
    state = v;
    final p = await SharedPreferences.getInstance();
    await p.setDouble(key, v);
  }
}

class SoundSettingsScreen extends ConsumerWidget {
  const SoundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceEnabled = ref.watch(_voiceEnabledProvider);
    final volume = ref.watch(_voiceVolumeProvider);
    final vibration = ref.watch(_vibrationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('صدا و اعلان‌ها')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          const SectionHeader('راهنمای صوتی'),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.record_voice_over_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('راهنمای صوتی',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                Switch(
                  value: voiceEnabled,
                  onChanged: (v) =>
                      ref.read(_voiceEnabledProvider.notifier).set(v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          if (voiceEnabled) ...[
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.volume_up_rounded, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text('میزان صدا',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Slider(
                    value: volume,
                    onChanged: (v) =>
                        ref.read(_voiceVolumeProvider.notifier).set(v),
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.borderDark,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('کم', style: TextStyle(fontSize: 11)),
                      Text('زیاد', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SectionHeader('اعلان‌ها'),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.vibration_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('لرزش',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('لرزش هنگام هشدار مسیر',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark)),
                    ],
                  ),
                ),
                Switch(
                  value: vibration,
                  onChanged: (v) =>
                      ref.read(_vibrationProvider.notifier).set(v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
