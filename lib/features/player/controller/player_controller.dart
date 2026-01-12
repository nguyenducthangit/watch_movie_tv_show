import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/models/watch_progress.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

/// Player Controller
class PlayerController extends GetxController {
  late VideoItem video;
  String? localPath;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;
  final RxBool isInitialized = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>;
    video = args['video'] as VideoItem;
    localPath = args['localPath'] as String?;

    // Lock orientation to landscape for fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

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

      // Get saved position
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
        fullScreenByDefault: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        showControlsOnInitialize: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
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
                ElevatedButton(onPressed: retry, child: const Text('Retry')),
              ],
            ),
          );
        },
      );

      // Listen to video player events
      videoPlayerController!.addListener(_handlePlayerEvent);

      isInitialized.value = true;
      totalDuration.value = videoPlayerController!.value.duration;
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
      _clearProgress();
    }
  }

  /// Save watch progress
  void _saveProgress() {
    if (!isInitialized.value || videoPlayerController == null) return;

    final position = currentPosition.value.inMilliseconds;
    final duration = totalDuration.value.inMilliseconds;

    if (duration > 0 && position < duration) {
      final progress = WatchProgress(videoId: video.id, positionMs: position, durationMs: duration);
      StorageService.instance.saveWatchProgress(progress);
      logger.d('Saved progress: ${position}ms / ${duration}ms');
    }
  }

  /// Clear progress (when finished)
  void _clearProgress() {
    StorageService.instance.deleteWatchProgress(video.id);
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
    videoPlayerController?.seekTo(newPosition);
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

    // Restore orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.onClose();
  }
}
