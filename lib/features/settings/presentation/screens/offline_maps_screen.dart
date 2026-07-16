import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/offline_map_download_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_notification_banner.dart';
import '../../../../core/widgets/common_widgets.dart';

/// صفحه‌ی «دانلود نقشه‌ی آفلاین» — دانلودِ کاشی‌های یک کشور برای استفاده
/// بدون اینترنت (طبق درخواست: مثلاً ایران).
class OfflineMapsScreen extends ConsumerStatefulWidget {
  const OfflineMapsScreen({super.key});

  @override
  ConsumerState<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends ConsumerState<OfflineMapsScreen> {
  final Map<String, double> _progress = {};
  final Map<String, bool> _downloaded = {};
  String? _downloadingId;

  @override
  void initState() {
    super.initState();
    _refreshStatuses();
  }

  Future<void> _refreshStatuses() async {
    final service = ref.read(offlineMapDownloadServiceProvider);
    for (final region in downloadableRegions) {
      final done = await service.isDownloaded(region);
      if (!mounted) return;
      setState(() => _downloaded[region.id] = done);
    }
  }

  Future<void> _startDownload(DownloadableRegion region) async {
    final service = ref.read(offlineMapDownloadServiceProvider);
    final notifier = ref.read(appNotificationProvider.notifier);
    setState(() {
      _downloadingId = region.id;
      _progress[region.id] = 0;
    });
    notifier.show('در حال دانلود نقشه‌ی ${region.name}...',
        type: AppNotifyType.loading);
    try {
      await for (final p in service.download(region)) {
        if (!mounted) return;
        setState(() => _progress[region.id] = p);
      }
      if (!mounted) return;
      setState(() {
        _downloadingId = null;
        _downloaded[region.id] = true;
      });
      notifier.show('نقشه‌ی ${region.name} برای استفاده‌ی آفلاین ذخیره شد',
          type: AppNotifyType.success);
    } catch (e) {
      if (!mounted) return;
      setState(() => _downloadingId = null);
      notifier.show('دانلود نقشه‌ی ${region.name} ناموفق بود',
          type: AppNotifyType.error);
    }
  }

  Future<void> _removeDownload(DownloadableRegion region) async {
    final service = ref.read(offlineMapDownloadServiceProvider);
    await service.remove(region);
    if (!mounted) return;
    setState(() => _downloaded[region.id] = false);
    ref.read(appNotificationProvider.notifier).show(
          'نقشه‌ی ${region.name} حذف شد',
          type: AppNotifyType.info,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دانلود نقشه‌ی آفلاین')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          const Text(
            'برای استفاده از برنامه بدون اتصال اینترنت، نقشه‌ی کشور مورد نظر را از پیش دانلود کنید.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader('کشورها'),
          ...downloadableRegions.map(_regionTile),
        ],
      ),
    );
  }

  Widget _regionTile(DownloadableRegion region) {
    final downloading = _downloadingId == region.id;
    final progress = _progress[region.id] ?? 0;
    final done = _downloaded[region.id] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const GlowIcon(Icons.map_rounded, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(region.name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        downloading
                            ? 'در حال دانلود... ${(progress * 100).toStringAsFixed(0)}%'
                            : done
                                ? 'برای استفاده‌ی آفلاین آماده است'
                                : 'دانلود نشده',
                        style: TextStyle(
                          fontSize: 12,
                          color: done
                              ? AppColors.navSelected
                              : AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (downloading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.primary,
                    ),
                  )
                else if (done)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger),
                    onPressed: () => _removeDownload(region),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.download_rounded,
                        color: AppColors.primary),
                    onPressed: () => _startDownload(region),
                  ),
              ],
            ),
            if (downloading) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.borderDark,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
