import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/data/models/movie_model.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/models/video_quality.dart';
import 'package:watch_movie_tv_show/app/data/repositories/ophim_repository.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/services/watchlist_service.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Detail Controller
class DetailController extends GetxController {
  late VideoItem video;

  final RxBool isDownloading = false.obs;
  final RxBool isDownloaded = false.obs;
  final RxDouble downloadProgress = 0.0.obs;

  final Rx<VideoQuality?> selectedQuality = Rx<VideoQuality?>(null);
  final RxBool isInWatchlist = false.obs;
  final RxList<VideoItem> relatedVideos = <VideoItem>[].obs;
  final RxBool isLoadingDetail = false.obs;

  // Enhanced: Full movie detail with all metadata
  final Rx<MovieModel?> movieDetail = Rx<MovieModel?>(null);
  final Rx<EpisodeItem?> selectedEpisode = Rx<EpisodeItem?>(null);
  final RxInt selectedServerIndex = 0.obs;

  WatchlistService get _watchlistService => Get.find<WatchlistService>();
  final OphimRepository _repository = OphimRepository();

  @override
  void onInit() {
    super.onInit();
    // Get video from arguments
    video = Get.arguments as VideoItem;
    _loadMovieDetail();
    _loadRelatedVideos();
  }

  /// Load full movie detail from API
  /// Prioritizes loading detail immediately when user opens detail page
  Future<void> _loadMovieDetail() async {
    try {
      if (video.slug == null || video.slug!.isEmpty) return;

      isLoadingDetail.value = true;
      
      // Fetch detail with high priority (user is viewing this movie)
      logger.i('Loading movie detail for: ${video.slug} (high priority)');
      final detail = await _repository.fetchMovieDetail(video.slug!);

      // Store full MovieModel for UI access
      movieDetail.value = detail;

      // Generate downloadQualities from episodes (if not already set)
      List<VideoQuality>? qualities;
      if (detail.hasEpisodes && detail.episodes!.isNotEmpty) {
        qualities = _generateDownloadQualities(detail);
      }

      // Update video with full details
      video = video.copyWith(
        description: detail.content,
        year: detail.year,
        quality: detail.quality,

        episodeCurrent: detail.episodeCurrent,
        episodeTotal: detail.episodeTotal,
        time: detail.time,
        type: detail.type,
        actor: detail.actor,
        director: detail.director,
        country: detail.country,
        trailerUrl: detail.trailerUrl,
        downloadQualities: qualities,
      );

      // Auto-select first episode if series
      if (detail.hasEpisodes && detail.episodes!.isNotEmpty) {
        final firstServer = detail.episodes!.first;
        if (firstServer.episodes.isNotEmpty) {
          selectedEpisode.value = firstServer.episodes.first;
        }
      }

      logger.i('Loaded movie detail: ${detail.name}');
    } catch (e) {
      logger.e('Failed to load movie detail: $e');
      // Continue anyway with basic info from list
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Generate download qualities from episodes
  List<VideoQuality> _generateDownloadQualities(MovieModel movie) {
    final qualities = <VideoQuality>[];

    // Use first server's first episode as download source
    if (movie.episodes != null && movie.episodes!.isNotEmpty) {
      final server = movie.episodes!.first;
      if (server.episodes.isNotEmpty) {
        final episode = server.episodes.first;

        // For HLS streams, create multiple quality options
        // The actual quality selection happens during download via variant index
        final m3u8Url = episode.linkM3u8;

        if (m3u8Url.isNotEmpty) {
          // Create quality options that user can choose from
          // These will map to variant indices during download (0=highest, 1=medium, 2=lowest)
          qualities.addAll([
            VideoQuality(
              label: L.hd.tr,
              url: m3u8Url,
              sizeMB: null, // Unknown for HLS
            ),
            VideoQuality(label: L.sd.tr, url: m3u8Url, sizeMB: null),
            VideoQuality(label: '360${L.p.tr}', url: m3u8Url, sizeMB: null),
          ]);
        }
      }
    }

    return qualities;
  }

  @override
  void onReady() {
    super.onReady();
    _checkDownloadStatus();
  }

  /// Check download status
  void _checkDownloadStatus() {
    final downloadService = DownloadService.to;
    isDownloaded.value = downloadService.isDownloaded(video.id);
    isDownloading.value = downloadService.isDownloading(video.id);
    downloadProgress.value = downloadService.getProgress(video.id);

    // Listen to active downloads changes
    ever(downloadService.activeDownloads, (_) {
      isDownloading.value = downloadService.isDownloading(video.id);
      downloadProgress.value = downloadService.getProgress(video.id);
    });

    ever(downloadService.completedDownloads, (_) {
      isDownloaded.value = downloadService.isDownloaded(video.id);
    });

    // Check watchlist
    isInWatchlist.value = _watchlistService.isInWatchlist(video.id);

    // Listen to watchlist changes
    ever(_watchlistService.watchlistIds, (_) {
      isInWatchlist.value = _watchlistService.isInWatchlist(video.id);
    });
  }

  void _loadRelatedVideos() {
    relatedVideos.clear();
  }

  /// Toggle watchlist
  Future<void> toggleWatchlist() async {
    await _watchlistService.toggleWatchlist(video.id);
  }

  /// Share video
  void shareVideo() {
    final movieUrl = video.slug != null
        ? '${L.checkOutThisMovie.tr}: ${video.displayTitle}'
        : '${L.checkoutThisVideo.tr}: ${video.displayTitle}';
    Share.share(movieUrl);
  }

  /// Select episode to play
  void selectEpisode(EpisodeItem episode) {
    selectedEpisode.value = episode;
    logger.i('Selected episode: ${episode.name}');
  }

  /// Select server
  void selectServer(int index) {
    selectedServerIndex.value = index;
    // Auto-select first episode of new server
    if (movieDetail.value?.episodes != null && movieDetail.value!.episodes!.length > index) {
      final server = movieDetail.value!.episodes![index];
      if (server.episodes.isNotEmpty) {
        selectedEpisode.value = server.episodes.first;
      }
    }
  }

  /// Play video - fetch detail with stream URL if not already loaded
  Future<void> playVideo({EpisodeItem? episode}) async {
    try {
      isLoadingDetail.value = true;

      // Fetch movie detail to get episodes and stream URL
      if (video.slug == null || video.slug!.isEmpty) {
        Get.snackbar('Error', 'Invalid movie slug');
        return;
      }

      logger.i('Fetching detail for slug: ${video.slug}');
      final detail = movieDetail.value ?? await _repository.fetchMovieDetail(video.slug!);

      logger.i('Movie detail fetched: ${detail.name}');
      logger.i('Has episodes: ${detail.hasEpisodes}');

      // Use provided episode or selected episode or first episode
      EpisodeItem? episodeToPlay = episode ?? selectedEpisode.value;

      if (detail.hasEpisodes && detail.episodes!.isNotEmpty) {
        final serverIndex = selectedServerIndex.value;
        final server = detail.episodes![serverIndex.clamp(0, detail.episodes!.length - 1)];

        if (server.episodes.isNotEmpty) {
          episodeToPlay ??= server.episodes.first;
          logger.i('Playing episode: ${episodeToPlay.name} from server: ${server.serverName}');
        }
      }

      // Convert to VideoItem with stream URL from specific episode
      final videoWithStream = await _repository.movieWithEpisodeToVideoItem(
        detail,
        episodeToPlay: episodeToPlay,
      );

      logger.i('VideoItem created with streamUrl: ${videoWithStream.streamUrl}');

      if (videoWithStream.streamUrl == null || videoWithStream.streamUrl!.isEmpty) {
        Get.snackbar('Error', 'No stream available for this video');
        logger.e('Stream URL is null or empty!');
        return;
      }

      // Check if we have a local file
      final localPath = await DownloadService.to.getLocalPath(video.id);

      logger.i('Navigating to player with stream URL: ${videoWithStream.streamUrl}');
      Get.toNamed(MRoutes.player, arguments: {'video': videoWithStream, 'localPath': localPath});
    } catch (e, stack) {
      logger.e('Failed to play video: $e');
      logger.e('Stack trace: $stack');

      final errorMessage = _getReadableErrorMessage(e);
      Get.snackbar(
        L.noInternetTitle.tr,
        errorMessage,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Show quality picker and start download
  void startDownload(VideoQuality quality) {
    DownloadService.to.startDownload(video, quality);
    Get.back(); // Close bottom sheet
    logger.i('Started download: ${video.title} - ${quality.label}');
  }

  /// Cancel download
  void cancelDownload() {
    DownloadService.to.cancelDownload(video.id);
  }

  /// Get download button text
  String get downloadButtonText {
    if (isDownloaded.value) return 'Downloaded';
    if (isDownloading.value) {
      return 'Downloading ${(downloadProgress.value * 100).toInt()}%';
    }
    return 'Download';
  }

  /// Check if has watch progress
  bool get hasWatchProgress {
    final progress = StorageService.instance.getWatchProgress(video.id);
    return progress?.hasProgress ?? false;
  }

  /// Get watch progress text
  String? get watchProgressText {
    final progress = StorageService.instance.getWatchProgress(video.id);
    if (progress?.hasProgress ?? false) {
      return progress!.remainingFormatted;
    }
    return null;
  }

  /// Convert exception to user-friendly error message
  String _getReadableErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('internet connection') || errorStr.contains('Unable to connect')) {
      return L.checkConnection.tr;
    }
    if (errorStr.contains('not found') || errorStr.contains('404')) {
      return 'Movie not available';
    }
    if (errorStr.contains('Server error') || errorStr.contains('500')) {
      return 'Server is currently unavailable. Please try again later.';
    }
    if (errorStr.contains('timeout') || errorStr.contains('too long')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    return 'Unable to load video. Please try again later.';
  }
}
