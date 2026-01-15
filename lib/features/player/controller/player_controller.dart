import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:watch_movie_tv_show/app/data/models/subtitle_data.dart';
import 'package:watch_movie_tv_show/app/data/models/subtitle_entry.dart';
import 'package:watch_movie_tv_show/app/data/models/video_item.dart';
import 'package:watch_movie_tv_show/app/data/models/watch_progress.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/services/subtitle_service.dart';
import 'package:watch_movie_tv_show/app/services/watch_progress_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Player Controller - YouTube only
class PlayerController extends GetxController {
  late VideoItem video;

  YoutubePlayerController? youtubeController;

  // Services
  WatchProgressService get _progressService => Get.find<WatchProgressService>();
  SubtitleService get _subtitleService => Get.find<SubtitleService>();

  // State
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;
  final RxBool showControls = false.obs;
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

  Timer? _hideControlsTimer;

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
      if (video.youtubeId == null || video.youtubeId!.isEmpty) {
        throw Exception('No YouTube ID provided');
      }

      Duration? startAt;
      final savedProgress = StorageService.instance.getWatchProgress(video.id);
      if (savedProgress != null && savedProgress.hasProgress) {
        startAt = Duration(milliseconds: savedProgress.positionMs);
      }

      youtubeController = YoutubePlayerController(
        initialVideoId: video.youtubeId!,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
          hideControls: true,
          controlsVisibleAtStart: false,
          forceHD: false,
          startAt: startAt?.inSeconds ?? 0,
          showLiveFullscreenButton: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          useHybridComposition: true,
        ),
      );

      youtubeController!.addListener(_handleYoutubePlayerEvent);
      isInitialized.value = true;

      WakelockPlus.enable();
      logger.i('YouTube Player initialized for: ${video.title}');
    } catch (e) {
      logger.e('Failed to initialize player: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    }
  }

  void _handleYoutubePlayerEvent() {
    if (youtubeController == null) return;

    final value = youtubeController!.value;

    isPlaying.value = value.isPlaying;
    isBuffering.value = value.playerState == PlayerState.buffering;
    currentPosition.value = value.position;

    if (youtubeController!.metadata.duration.inSeconds > 0) {
      totalDuration.value = youtubeController!.metadata.duration;
    }

    if (value.hasError) {
      hasError.value = true;
      errorMessage.value = 'YouTube playback error: ${value.errorCode}';
    }

    if (value.playerState == PlayerState.ended) {
      _onVideoComplete();
    }

    _updateCurrentSubtitle();
  }

  void _onVideoComplete() {
    _progressService.markAsComplete(video.id);
    StorageService.instance.deleteWatchProgress(video.id);
  }

  void _saveProgress() {
    if (!isInitialized.value) return;

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
    if (isPlaying.value) {
      youtubeController?.pause();
    } else {
      youtubeController?.play();
    }
    showControls.value = true;
    _startHideTimer();
  }

  void seek(int seconds) {
    final newPosition = currentPosition.value + Duration(seconds: seconds);
    final clampedPosition = newPosition.isNegative
        ? Duration.zero
        : (newPosition > totalDuration.value ? totalDuration.value : newPosition);

    youtubeController?.seekTo(clampedPosition);

    showControls.value = true;
    _startHideTimer();
  }

  void seekForward() => seek(10);
  void seekBackward() => seek(-10);

  void setPlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    youtubeController?.setPlaybackRate(speed);
    logger.d('Playback speed set to: ${speed}x');
  }

  void setQuality(String quality) {
    currentQuality.value = quality;
    logger.d('Quality set to: $quality');
  }

  void toggleSubtitle() {
    subtitleEnabled.value = !subtitleEnabled.value;
    logger.d('Subtitle ${subtitleEnabled.value ? 'enabled' : 'disabled'}');
  }

  Future<void> changeSubtitleLanguage(String language) async {
    selectedSubtitleLanguage.value = language;

    if (language == 'off') {
      subtitleEnabled.value = false;
      return;
    }

    subtitleEnabled.value = true;

    // TODO: Implement with external subtitle source when available
    if (currentSubtitle.value != null) {
      logger.i('Translating subtitle to: $language');
      final translatedData = await _subtitleService.translateSubtitle(
        currentSubtitle.value!,
        language,
      );
      currentSubtitle.value = translatedData;
    }
  }

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
    youtubeController?.dispose();
    youtubeController = null;
    _initPlayer();
  }

  @override
  void onClose() {
    _saveProgress();
    _cancelHideTimer();
    youtubeController?.dispose();

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
