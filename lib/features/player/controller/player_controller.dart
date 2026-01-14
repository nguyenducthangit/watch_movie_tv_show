import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/data/models/subtitle_data.dart';
import 'package:watch_movie_tv_show/app/data/models/subtitle_entry.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/models/watch_progress.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/services/subtitle_service.dart';
import 'package:watch_movie_tv_show/app/services/watch_progress_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Player Controller
/// Enhanced with gesture controls, speed/quality selection, and progress tracking
class PlayerController extends GetxController {
  late VideoItem video;
  String? localPath;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  // Services
  WatchProgressService get _progressService => Get.find<WatchProgressService>();
  SubtitleService get _subtitleService => Get.find<SubtitleService>();

  // State
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;
  final RxBool showControls = false.obs; // Hidden by default
  final RxBool isInitialized = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Position tracking
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;

  // Premium features
  final RxDouble playbackSpeed = 1.0.obs;
  final RxString currentQuality = 'Auto'.obs;
  static const List<String> availableQualities = ['Auto', '1080p', '720p', '480p', '360p'];
  static const List<double> availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // Subtitle state
  final RxBool subtitleEnabled = false.obs;
  final Rx<SubtitleData?> currentSubtitle = Rx(null);
  final RxString selectedSubtitleLanguage = 'off'.obs;
  final RxList<String> availableSubtitleLanguages = <String>[
    'off',
    'en',
    'vi',
    'es',
    'fr',
    'de',
    'ja',
  ].obs;
  final Rx<SubtitleEntry?> currentSubtitleEntry = Rx(null);
  final RxBool isFullscreen = false.obs;

  // Auto-hide timer for controls
  Timer? _hideControlsTimer;

  @override
  void onInit() {
    super.onInit();
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>;

    if (args['video'] != null) {
      video = args['video'] as VideoItem;
    } else if (args['localPath'] != null) {
      // Create minimal video item from download info
      video = VideoItem(
        id: args['title'] ?? 'downloaded_video',
        title: args['title'] ?? 'Downloaded Video',
        streamUrl: '', // Not needed for local file
        thumbnailUrl: '',
        description: '',
      );
    } else {
      logger.e('No video or local path provided to PlayerController');
      hasError.value = true;
      errorMessage.value = 'Failed to load video';
      return;
    }

    localPath = args['localPath'] as String?;

    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initPlayer();
  }

  /// Initialize video player
  Future<void> _initPlayer() async {
    try {
      // Create video player controller
      if (localPath != null && File(localPath!).existsSync()) {
        videoPlayerController = VideoPlayerController.file(File(localPath!));
      } else {
        videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(video.streamUrl));
      }

      await videoPlayerController!.initialize();

      // Get saved position from both services
      Duration? startAt;
      final savedProgress = StorageService.instance.getWatchProgress(video.id);
      if (savedProgress != null && savedProgress.hasProgress) {
        startAt = Duration(milliseconds: savedProgress.positionMs);
      }

      // Create chewie controller
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        startAt: startAt,
        allowFullScreen: true,
        fullScreenByDefault: false,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: false, // Use custom controls instead
        showControlsOnInitialize: false,
        // Cinematic Theme Customization
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFD4AF37), // Cinematic Gold
          handleColor: const Color(0xFFD4AF37),
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          bufferedColor: Colors.white.withValues(alpha: 0.5),
        ),
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFD4AF37),
          handleColor: const Color(0xFFD4AF37),
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          bufferedColor: Colors.white.withValues(alpha: 0.5),
        ),
        placeholder: Container(
          color: AppColors.black,
          child: const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: retry,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                  child: const Text('Retry', style: TextStyle(color: AppColors.black)),
                ),
              ],
            ),
          );
        },
      );

      // Listen to video player events
      videoPlayerController!.addListener(_handlePlayerEvent);

      isInitialized.value = true;
      totalDuration.value = videoPlayerController!.value.duration;

      // Enable Wakelock to keep screen on
      WakelockPlus.enable();

      logger.i('Player initialized for: ${video.title}');

      // Load subtitle if available
      if (video.subtitleUrl != null) {
        _loadSubtitle();
      }
    } catch (e) {
      logger.e('Failed to initialize player: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    }
  }

  /// Handle player events
  void _handlePlayerEvent() {
    if (videoPlayerController == null) return;

    final value = videoPlayerController!.value;

    isPlaying.value = value.isPlaying;
    isBuffering.value = value.isBuffering;
    currentPosition.value = value.position;
    totalDuration.value = value.duration;

    if (value.hasError) {
      hasError.value = true;
      errorMessage.value = value.errorDescription ?? 'Playback error';
    }

    // Check if completed
    if (value.position >= value.duration && value.duration > Duration.zero) {
      _onVideoComplete();
    }

    // Update current subtitle
    _updateCurrentSubtitle();
  }

  /// Called when video completes
  void _onVideoComplete() {
    _progressService.markAsComplete(video.id);
    StorageService.instance.deleteWatchProgress(video.id);
  }

  /// Save watch progress to both services
  void _saveProgress() {
    if (!isInitialized.value || videoPlayerController == null) return;

    final position = currentPosition.value.inMilliseconds;
    final duration = totalDuration.value.inMilliseconds;

    if (duration > 0 && position < duration) {
      // Save to legacy service
      final progress = WatchProgress(videoId: video.id, positionMs: position, durationMs: duration);
      StorageService.instance.saveWatchProgress(progress);

      // Save to new progress service (for Continue Watching)
      final progressPercent = position / duration;
      _progressService.updateProgress(video.id, progressPercent);

      logger.d(
        'Saved progress: ${position}ms / ${duration}ms (${(progressPercent * 100).round()}%)',
      );
    }
  }

  /// Toggle controls visibility
  void toggleControls() {
    showControls.value = !showControls.value;

    // Auto-hide after 5 seconds if showing
    if (showControls.value) {
      _startHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  /// Start timer to hide controls
  void _startHideTimer() {
    _cancelHideTimer();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (showControls.value && !isBuffering.value) {
        showControls.value = false;
      }
    });
  }

  /// Cancel hide timer
  void _cancelHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (isPlaying.value) {
      videoPlayerController?.pause();
    } else {
      videoPlayerController?.play();
    }
    // Show controls and restart timer
    showControls.value = true;
    _startHideTimer();
  }

  /// Seek by seconds
  void seek(int seconds) {
    final newPosition = currentPosition.value + Duration(seconds: seconds);
    final clampedPosition = newPosition.isNegative
        ? Duration.zero
        : (newPosition > totalDuration.value ? totalDuration.value : newPosition);
    videoPlayerController?.seekTo(clampedPosition);

    // Show controls and restart timer
    showControls.value = true;
    _startHideTimer();
  }

  /// Seek forward 10s
  void seekForward() => seek(10);

  /// Seek backward 10s
  void seekBackward() => seek(-10);

  /// Set playback speed
  void setPlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    videoPlayerController?.setPlaybackSpeed(speed);
    logger.d('Playback speed set to: ${speed}x');
  }

  /// Set video quality (would need actual implementation with multiple streams)
  void setQuality(String quality) {
    currentQuality.value = quality;
    logger.d('Quality set to: $quality');
    // Note: Actual quality switching would require multiple stream URLs
    // and reinitializing the player with the selected quality
  }

  /// Load subtitle from URL
  Future<void> _loadSubtitle() async {
    if (video.subtitleUrl == null) {
      logger.w('No subtitle URL provided for video: ${video.title}');
      return;
    }

    try {
      logger.i('Loading subtitle from: ${video.subtitleUrl}');
      final defaultLang = video.defaultSubtitleLanguage ?? 'en';
      final subtitleData = await _subtitleService.loadSubtitle(video.subtitleUrl!, defaultLang);
      currentSubtitle.value = subtitleData;
      logger.i('Subtitle loaded successfully: ${subtitleData.entries.length} entries');

      // If user already selected a language, keep it
      if (selectedSubtitleLanguage.value == 'off') {
        // Don't auto-enable, keep it off by default
        logger.d('Subtitle loaded but kept OFF by default');
      }
    } catch (e) {
      logger.e('Failed to load subtitle: $e');
    }
  }

  /// Toggle subtitle on/off
  void toggleSubtitle() {
    subtitleEnabled.value = !subtitleEnabled.value;
    logger.d('Subtitle ${subtitleEnabled.value ? 'enabled' : 'disabled'}');
  }

  /// Change subtitle language
  Future<void> changeSubtitleLanguage(String language) async {
    selectedSubtitleLanguage.value = language;

    if (language == 'off') {
      subtitleEnabled.value = false;
      return;
    }

    // Enable subtitle
    subtitleEnabled.value = true;

    // If same as original language, use original subtitle
    final originalLang = video.defaultSubtitleLanguage ?? 'en';
    if (language == originalLang && currentSubtitle.value != null) {
      // Reload original subtitle
      if (video.subtitleUrl != null) {
        final subtitleData = await _subtitleService.loadSubtitle(video.subtitleUrl!, originalLang);
        currentSubtitle.value = subtitleData;
      }
      return;
    }

    // Translate to target language
    if (currentSubtitle.value != null) {
      logger.i('Translating subtitle to: $language');
      final translatedData = await _subtitleService.translateSubtitle(
        currentSubtitle.value!,
        language,
      );
      currentSubtitle.value = translatedData;
    }
  }

  /// Update current subtitle entry based on position
  void _updateCurrentSubtitle() {
    if (!subtitleEnabled.value || currentSubtitle.value == null) {
      currentSubtitleEntry.value = null;
      return;
    }

    final entry = currentSubtitle.value!.getEntryAt(currentPosition.value);
    if (entry != currentSubtitleEntry.value) {
      currentSubtitleEntry.value = entry;
    }
  }

  /// Toggle fullscreen
  void toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value;
    if (isFullscreen.value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    logger.d('Fullscreen: ${isFullscreen.value}');
  }

  /// Get formatted current time
  String get formattedPosition {
    final pos = currentPosition.value;
    return '${pos.inMinutes}:${(pos.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  /// Get formatted total duration
  String get formattedDuration {
    final dur = totalDuration.value;
    return '${dur.inMinutes}:${(dur.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  /// Get progress percentage (0.0 - 1.0)
  double get progressPercent {
    if (totalDuration.value.inMilliseconds == 0) return 0.0;
    return currentPosition.value.inMilliseconds / totalDuration.value.inMilliseconds;
  }

  /// Retry playback
  void retry() {
    hasError.value = false;
    _disposePlayer();
    _initPlayer();
  }

  /// Dispose player controllers
  void _disposePlayer() {
    chewieController?.dispose();
    videoPlayerController?.dispose();
    chewieController = null;
    videoPlayerController = null;
  }

  @override
  void onClose() {
    // Save progress before closing
    _saveProgress();

    // Cancel timers
    _cancelHideTimer();

    // Dispose player
    _disposePlayer();

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Disable Wakelock
    WakelockPlus.disable();

    super.onClose();
  }
}
