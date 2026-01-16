import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/app_config.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Settings Controller
class SettingsController extends GetxController {
  final RxBool isClearingCache = false.obs;
  final RxBool isClearingDownloads = false.obs;

  /// Clear image cache (manifest + thumbnails)
  Future<void> clearImageCache() async {
    try {
      isClearingCache.value = true;
      // Clear manifest cache
      await clearManifestCache();
      Get.snackbar('Success', 'Cache cleared');
      logger.i('Cache cleared');
    } catch (e) {
      logger.e('Failed to clear cache: $e');
      Get.snackbar('Error', 'Failed to clear cache');
    } finally {
      isClearingCache.value = false;
    }
  }

  /// Clear manifest cache (now just clears storage cache)
  Future<void> clearManifestCache() async {
    try {
      // Since we're using API now, just clear local storage cache
      await StorageService.instance.clearAll();
    } catch (e) {
      logger.e('Failed to clear cache: $e');
    }
  }

  /// Clear all downloads
  Future<void> clearAllDownloads() async {
    final hasDownloads =
        DownloadService.to.activeDownloads.isNotEmpty ||
        DownloadService.to.completedDownloads.isNotEmpty;

    if (!hasDownloads) {
      Get.snackbar('Info', 'No downloads to clear');
      return;
    }

    Get.defaultDialog(
      title: 'Delete All Downloads',
      middleText: 'This will delete all downloaded videos. This action cannot be undone.',
      textConfirm: 'Delete All',
      textCancel: 'Cancel',
      onConfirm: () async {
        Get.back();
        try {
          isClearingDownloads.value = true;
          await DownloadService.to.deleteAllDownloads();
          Get.snackbar('Success', 'All downloads deleted');
        } catch (e) {
          logger.e('Failed to clear downloads: $e');
          Get.snackbar('Error', 'Failed to delete downloads');
        } finally {
          isClearingDownloads.value = false;
        }
      },
    );
  }

  /// Clear all data
  Future<void> clearAllData() async {
    Get.defaultDialog(
      title: 'Clear All Data',
      middleText: 'This will clear all app data including downloads and watch history.',
      textConfirm: 'Clear All',
      textCancel: 'Cancel',
      onConfirm: () async {
        Get.back();
        try {
          await StorageService.instance.clearAll();
          await clearManifestCache();
          Get.snackbar('Success', 'All data cleared');
        } catch (e) {
          logger.e('Failed to clear all data: $e');
        }
      },
    );
  }

  /// Get app version
  String get appVersion => AppConfig.appVersion;

  /// Get manifest URL
  String get manifestUrl => AppConfig.manifestUrl;
}
