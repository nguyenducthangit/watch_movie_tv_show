import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/models/watch_progress.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/services/watch_progress_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Player Controller - HLS Video Player
class PlayerController extends GetxController {
  late VideoItem video;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  // Services
  WatchProgressService get _progressService => Get.find<WatchProgressService>();

  // State
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;
  final RxBool showControls = true.obs;
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

  final RxBool isFullscreen = false.obs;

  Timer? _hideControlsTimer;
  Timer? _progressTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;

    if (args['video'] != null) {
      video = args['video'] as VideoItem;
    } else {
      logger.e('No video provided to PlayerController');
      hasError.value = true;
      errorMessage.value = 'Failed to load video';
      return;
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (video.streamUrl == null || video.streamUrl!.isEmpty) {
        throw Exception('No stream URL provided');
      }

      // Initialize video player
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(video.streamUrl!));

      await videoPlayerController!.initialize();

      // Get saved progress
      Duration? startAt;
      final savedProgress = StorageService.instance.getWatchProgress(video.id);
      if (savedProgress != null && savedProgress.hasProgress) {
        startAt = Duration(milliseconds: savedProgress.positionMs);
        await videoPlayerController!.seekTo(startAt);
      }

      // Initialize Chewie controller
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        showControls: false, // Disable built-in controls, use custom controls instead
        aspectRatio: 16 / 9,
        autoInitialize: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: availableSpeeds,
      );

      // Add listeners
      videoPlayerController!.addListener(_handleVideoPlayerEvent);

      isInitialized.value = true;
      WakelockPlus.enable();

      // Start progress tracking timer
      _startProgressTimer();

      logger.i('Video Player initialized for: ${video.title}');
    } catch (e) {
      logger.e('Failed to initialize player: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    }
  }

  void _handleVideoPlayerEvent() {
    if (videoPlayerController == null) return;

    final value = videoPlayerController!.value;

    isPlaying.value = value.isPlaying;
    isBuffering.value = value.isBuffering;
    currentPosition.value = value.position;
    totalDuration.value = value.duration;

    if (value.hasError) {
      hasError.value = true;
      errorMessage.value = 'Video playback error occurred';
    }

    // Check if video ended
    if (value.position.inMilliseconds > 0 &&
        value.position.inMilliseconds >= value.duration.inMilliseconds - 500) {
      _onVideoComplete();
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _saveProgress();
    });
  }

  void _onVideoComplete() {
    _progressService.markAsComplete(video.id);
    StorageService.instance.deleteWatchProgress(video.id);
  }

  void _saveProgress() {
    if (!isInitialized.value || videoPlayerController == null) return;

    final position = currentPosition.value.inMilliseconds;
    final duration = totalDuration.value.inMilliseconds;

    if (duration > 0 && position < duration) {
      final progress = WatchProgress(videoId: video.id, positionMs: position, durationMs: duration);
      StorageService.instance.saveWatchProgress(progress);

      final progressPercent = position / duration;
      _progressService.updateProgress(video.id, progressPercent);

      logger.d(
        'Saved progress: ${position}ms / ${duration}ms (${(progressPercent * 100).round()}%)',
      );
    }
  }

  void toggleControls() {
    showControls.value = !showControls.value;

    if (showControls.value) {
      _startHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  void _startHideTimer() {
    _cancelHideTimer();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (showControls.value && !isBuffering.value) {
        showControls.value = false;
      }
    });
  }

  void _cancelHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  void togglePlayPause() {
    if (videoPlayerController == null) return;

    if (isPlaying.value) {
      videoPlayerController!.pause();
    } else {
      videoPlayerController!.play();
    }
    showControls.value = true;
    _startHideTimer();
  }

  void seek(int seconds) {
    if (videoPlayerController == null) return;

    final newPosition = currentPosition.value + Duration(seconds: seconds);
    final clampedPosition = newPosition.isNegative
        ? Duration.zero
        : (newPosition > totalDuration.value ? totalDuration.value : newPosition);

    videoPlayerController!.seekTo(clampedPosition);

    showControls.value = true;
    _startHideTimer();
  }

  void seekForward() => seek(10);
  void seekBackward() => seek(-10);

  void setPlaybackSpeed(double speed) {
    if (videoPlayerController == null) return;

    playbackSpeed.value = speed;
    videoPlayerController!.setPlaybackSpeed(speed);
    logger.d('Playback speed set to: ${speed}x');
  }

  void setQuality(String quality) {
    currentQuality.value = quality;
    logger.d('Quality set to: $quality');
    // Note: HLS streams auto-adjust quality, this is mostly for UI display
  }

  void toggleFullscreen() {
    if (isFullscreen.value) {
      // Exiting fullscreen - change orientation first, then update state after next frame
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      // Wait for next frame to ensure orientation is updated
      SchedulerBinding.instance.addPostFrameCallback((_) {
        isFullscreen.value = false;
      });
    } else {
      // Entering fullscreen
      isFullscreen.value = true;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    logger.d('Fullscreen: ${isFullscreen.value}');
  }

  String get formattedPosition {
    final pos = currentPosition.value;
    return '${pos.inMinutes}:${(pos.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  String get formattedDuration {
    final dur = totalDuration.value;
    return '${dur.inMinutes}:${(dur.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  double get progressPercent {
    if (totalDuration.value.inMilliseconds == 0) return 0.0;
    return currentPosition.value.inMilliseconds / totalDuration.value.inMilliseconds;
  }

  void retry() {
    hasError.value = false;
    chewieController?.dispose();
    videoPlayerController?.dispose();
    chewieController = null;
    videoPlayerController = null;
    _initPlayer();
  }

  @override
  void onClose() {
    _saveProgress();
    _cancelHideTimer();
    _progressTimer?.cancel();

    chewieController?.dispose();
    videoPlayerController?.dispose();

    // Restore system UI and orientation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WakelockPlus.disable();
    super.onClose();
  }
}
