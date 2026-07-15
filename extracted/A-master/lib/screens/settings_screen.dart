import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool showSpeed = true;
  bool showSpeedLimit = true;
  bool voiceGuidance = true;
  bool nightMode = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await SettingsService.init();
    setState(() {
      showSpeed = SettingsService.showSpeed;
      showSpeedLimit = SettingsService.showSpeedLimit;
      voiceGuidance = SettingsService.voiceGuidance;
      nightMode = SettingsService.nightMode;
    });
  }

  Future<void> _save(String key, bool value) async {
    switch (key) {
      case 'showSpeed':
        await SettingsService.setShowSpeed(value);
        break;
      case 'showSpeedLimit':
        await SettingsService.setShowSpeedLimit(value);
        break;
      case 'voiceGuidance':
        await SettingsService.setVoiceGuidance(value);
        break;
      case 'nightMode':
        await SettingsService.setNightMode(value);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('نمایش سرعت‌سنج'),
            value: showSpeed,
            onChanged: (val) {
              setState(() => showSpeed = val);
              _save('showSpeed', val);
            },
          ),
          SwitchListTile(
            title: const Text('نمایش تابلوی سرعت مجاز'),
            value: showSpeedLimit,
            onChanged: (val) {
              setState(() => showSpeedLimit = val);
              _save('showSpeedLimit', val);
            },
          ),
          SwitchListTile(
            title: const Text('راهنمای صوتی'),
            value: voiceGuidance,
            onChanged: (val) {
              setState(() => voiceGuidance = val);
              _save('voiceGuidance', val);
            },
          ),
          SwitchListTile(
            title: const Text('حالت شب'),
            value: nightMode,
            onChanged: (val) {
              setState(() => nightMode = val);
              _save('nightMode', val);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('دانلود نقشه آفلاین'),
            subtitle: const Text('شهر تهران / استان تهران'),
            trailing: const Icon(Icons.download),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('دانلود نقشه آفلاین شروع شد (شبیه‌سازی)')),
              );
            },
          ),
        ],
      ),
    );
  }
}