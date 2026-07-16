import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';

final _speedCamProvider = StateNotifierProvider<_BoolN, bool>(
    (ref) => _BoolN('speed_cam', true));
final _trafficProvider = StateNotifierProvider<_BoolN, bool>(
    (ref) => _BoolN('traffic', true));
final _accidentProvider = StateNotifierProvider<_BoolN, bool>(
    (ref) => _BoolN('accident', true));
final _policeProvider = StateNotifierProvider<_BoolN, bool>(
    (ref) => _BoolN('police', true));

class _BoolN extends StateNotifier<bool> {
  final String key;
  _BoolN(this.key, bool def) : super(def) {
    SharedPreferences.getInstance()
        .then((p) => state = p.getBool(key) ?? def);
  }
  Future<void> set(bool v) async {
    state = v;
    (await SharedPreferences.getInstance()).setBool(key, v);
  }
}

class TrafficSettingsScreen extends ConsumerWidget {
  const TrafficSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ترافیک و هشدارها')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          const SectionHeader('هشدارها'),
          _toggle(ref, _speedCamProvider, Icons.speed_rounded,
              'دوربین سرعت', 'هشدار نزدیک شدن به دوربین'),
          const SizedBox(height: 8),
          _toggle(ref, _policeProvider, Icons.local_police_rounded,
              'گشت پلیس', 'گزارش حضور پلیس از کاربران'),
          const SizedBox(height: 8),
          _toggle(ref, _accidentProvider, Icons.warning_amber_rounded,
              'تصادف', 'هشدار تصادف در مسیر'),
          const SectionHeader('ترافیک'),
          _toggle(ref, _trafficProvider, Icons.traffic_rounded,
              'ترافیک لحظه‌ای', 'نمایش ترافیک روی نقشه'),
        ],
      ),
    );
  }

  Widget _toggle(WidgetRef ref,
      StateNotifierProvider<_BoolN, bool> provider,
      IconData icon, String title, String subtitle) {
    final val = ref.watch(provider);
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark)),
              ],
            ),
          ),
          Switch(
            value: val,
            onChanged: (v) => ref.read(provider.notifier).set(v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
