import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/dialog/delete_download.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/utils/extensions.dart';
import 'package:watch_movie_tv_show/features/language/domain/repositories/language_repository.dart';
import 'package:watch_movie_tv_show/features/translation/controller/translation_controller.dart';

/// Downloads Controller
class DownloadsController extends GetxController {
  final DownloadService _downloadService = DownloadService.to;

  // Translation
  TranslationController? get _translationController {
    try {
      return Get.find<TranslationController>();
    } catch (e) {
      return null;
    }
  }

  ILanguageRepository? get _languageRepository {
    try {
      return Get.find<ILanguageRepository>();
    } catch (e) {
      return null;
    }
  }

  // Store translated titles: videoId -> translatedTitle
  final RxMap<String, String> translatedTitles = <String, String>{}.obs;

  // Edit mode state
  final RxBool isEditMode = false.obs;
  final RxList<String> selectedIds = <String>[].obs;

  // Expose download service observables
  RxList<DownloadTask> get activeDownloads => _downloadService.activeDownloads;
  RxList<DownloadTask> get completedDownloads => _downloadService.completedDownloads;
  RxInt get totalStorageBytes => _downloadService.totalStorageBytes;

  /// Get storage used string
  String get storageUsedString {
    return totalStorageBytes.value.toBytesString();
  }

  /// Toggle edit mode
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) {
      selectedIds.clear();
    }
  }

  /// Toggle selection for a video
  void toggleSelection(String videoId) {
    if (selectedIds.contains(videoId)) {
      selectedIds.remove(videoId);
    } else {
      selectedIds.add(videoId);
    }
  }

  /// Select all completed downloads
  void selectAll() {
    selectedIds.clear();
    selectedIds.addAll(completedDownloads.map((task) => task.videoId));
  }

  /// Unselect all
  void unselectAll() {
    selectedIds.clear();
  }

  /// Check if video is selected
  bool isSelected(String videoId) {
    return selectedIds.contains(videoId);
  }

  /// Get selected count
  int get selectedCount => selectedIds.length;

  /// Delete selected downloads
  void deleteSelected() {
    if (selectedIds.isEmpty) return;

    DeleteDownload.show(
      title: '${L.delete.tr} ${selectedIds.length} ${L.videos.tr}',
      middleText: 'Are you sure you want to delete ${selectedIds.length} video(s)?',
      textConfirm: L.delete.tr,
      textCancel: L.cancel.tr,
      onRemove: () {
        // Delete each selected video
        for (final videoId in selectedIds.toList()) {
          _downloadService.deleteDownload(videoId);
        }
        // Exit edit mode
        toggleEditMode();
      },
    );
  }

  /// Play downloaded video
  // void playVideo(DownloadTask task) {
  //   Get.toNamed(
  //     MRoutes.player,
  //     arguments: {
  //       'video': null, // We don't have full video item here
  //       'localPath': task.localPath,
  //       'title': task.videoTitle,
  //     },
  //   );
  // }

  void routeVideoDetails(DownloadTask task) {
    final video = VideoItem(
      id: task.videoId,
      title: task.videoTitle,
      thumbnailUrl: task.thumbnailUrl,
    );

    Get.toNamed(MRoutes.detail, arguments: video);
  }

  /// Cancel download
  void cancelDownload(String videoId) {
    _downloadService.cancelDownload(videoId);
  }

  /// Delete downloaded video
  void deleteDownload(String videoId) {
    DeleteDownload.show(
      title: L.delete.tr,
      middleText: L.deleteConfirm.tr,
      textConfirm: L.delete.tr,
      textCancel: L.cancel.tr,
      onRemove: () {
        _downloadService.deleteDownload(videoId);
      },
    );
  }

  /// Delete all downloads
  void deleteAllDownloads() {
    if (completedDownloads.isEmpty && activeDownloads.isEmpty) return;

    DeleteDownload.show(
      title: AppStrings.clearAllDownloads,
      middleText: AppStrings.clearAllDescription,
      textConfirm: AppStrings.delete,
      textCancel: AppStrings.cancel,
      onRemove: () {
        _downloadService.deleteAllDownloads();
      },
    );
  }

  /// Check if has any downloads
  bool get hasDownloads => activeDownloads.isNotEmpty || completedDownloads.isNotEmpty;

  @override
  void onReady() {
    super.onReady();
    _translateDownloads();

    // Listen for new downloads or language changes
    ever(activeDownloads, (_) => _translateDownloads());
    ever(completedDownloads, (_) => _translateDownloads());
  }

  /// Translate active and completed downloads
  Future<void> _translateDownloads() async {
    final translationCtrl = _translationController;
    final langRepo = _languageRepository;

    if (translationCtrl == null || langRepo == null) return;

    try {
      final currentLang = langRepo.getCurLangCode();
      final allTasks = [...activeDownloads, ...completedDownloads];

      // Filter tasks that need translation (or re-translation if lang changed)
      // Since we don't store "last translated lang" here yet, we'll just try to translate all.
      // TranslationController handles caching, so it's efficient.

      final moviesToTranslate = allTasks
          .map(
            (task) => VideoItem(
              id: task.videoId,
              title: task.videoTitle,
              thumbnailUrl: task.thumbnailUrl,
            ),
          )
          .toList();

      if (moviesToTranslate.isEmpty) return;

      final translatedMovies = await translationCtrl.translateMovieList(
        movies: moviesToTranslate,
        targetLang: currentLang,
        batchSize: 20,
      );

      // Update map
      for (final movie in translatedMovies) {
        translatedTitles[movie.id] = movie.displayTitle;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get display title for a task
  String getDisplayTitle(DownloadTask task) {
    return translatedTitles[task.videoId] ?? task.videoTitle;
  }
}
