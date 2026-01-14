import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/models/watch_progress.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
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

  // State
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;
  final RxBool isInitialized = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool showControls = true.obs;

  // Position tracking
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;

  // Premium features
  final RxDouble playbackSpeed = 1.0.obs;
  final RxString currentQuality = 'Auto'.obs;
  static const List<String> availableQualities = ['Auto', '1080p', '720p', '480p', '360p'];
  static const List<double> availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

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
        showControls: true,
        showControlsOnInitialize: true,
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
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (isPlaying.value) {
      videoPlayerController?.pause();
    } else {
      videoPlayerController?.play();
    }
  }

  /// Seek by seconds
  void seek(int seconds) {
    final newPosition = currentPosition.value + Duration(seconds: seconds);
    final clampedPosition = newPosition.isNegative
        ? Duration.zero
        : (newPosition > totalDuration.value ? totalDuration.value : newPosition);
    videoPlayerController?.seekTo(clampedPosition);
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

    // Dispose player
    _disposePlayer();

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Disable Wakelock
    WakelockPlus.disable();

    super.onClose();
  }
}
