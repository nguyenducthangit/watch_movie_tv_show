import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';
import 'package:watch_movie_tv_show/app/data/models/download_task.dart';
import 'package:watch_movie_tv_show/app/data/models/hls_models.dart';
import 'package:watch_movie_tv_show/app/services/download_service.dart';
import 'package:watch_movie_tv_show/app/services/hls_parser.dart';
import 'package:watch_movie_tv_show/app/services/storage_service.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';
import 'package:watch_movie_tv_show/features/downloads/controller/downloads_controller.dart';

/// HLS Download Service
/// Handles downloading HLS streams with all segments
class HLSDownloadService extends GetxService {
  final Dio _dio = Dio();
  final _storage = StorageService.instance;

  String? _downloadDirectory;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _initService();
  }

  Future<void> _initService() async {
    if (_isInitialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    _downloadDirectory = '${appDir.path}/videos';

    // Create directory if not exists
    final dir = Directory(_downloadDirectory!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    _isInitialized = true;
    logger.i('HLSDownloadService initialized');
  }

  /// Ensure service is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initService();
    }
  }

  /// Start HLS download
  Future<void> startHLSDownload({
    required String videoId,
    required String videoTitle,
    required String m3u8Url,
    required String quality,
    required DownloadTask task,
    int selectedVariantIndex = 0, // Allow user to select variant
  }) async {
    try {
      // Ensure service is initialized
      await _ensureInitialized();

      logger.i('Starting HLS download: $videoTitle');

      // 1. Create video directory
      final videoDir = Directory('$_downloadDirectory/$videoId');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      // 2. Fetch playlist content
      final playlistContent = await _fetchPlaylist(m3u8Url);

      // 3. Check if master or media playlist
      final isMaster = HLSParser.isMasterPlaylist(playlistContent);

      HLSPlaylist playlist;
      if (isMaster) {
        // Extract quality variants and select
        final variants = HLSParser.parseMasterPlaylist(playlistContent, m3u8Url);
        logger.i('Found ${variants.length} quality variants');

        // Use user-selected variant index (with bounds check)
        final variantIndex = selectedVariantIndex.clamp(0, variants.length - 1);
        final selectedVariant = variants.isNotEmpty ? variants[variantIndex] : null;

        if (selectedVariant == null) {
          throw Exception('No quality variants found in master playlist');
        }

        logger.i('Selected variant $variantIndex: ${selectedVariant.bandwidth} bps');

        // Fetch media playlist
        final mediaContent = await _fetchPlaylist(selectedVariant.url);
        playlist = HLSParser.parseMediaPlaylist(mediaContent, selectedVariant.url);
      } else {
        // Direct media playlist
        playlist = HLSParser.parseMediaPlaylist(playlistContent, m3u8Url);
      }

      logger.i('Playlist has ${playlist.totalSegments} segments');

      // 4. Update task with total segments
      task.isHLS = true;
      task.totalSegments = playlist.totalSegments;
      task.downloadedSegments = 0;
      await _storage.saveDownloadTask(task);

      // 5. Download encryption key if exists
      if (playlist.isEncrypted) {
        logger.i('Downloading encryption key...');
        await _downloadEncryptionKey(playlist.encryptionKey!, videoDir.path);
      }

      // 6. Download segments sequentially (Phase 1 MVP)
      for (var i = 0; i < playlist.segments.length; i++) {
        final segment = playlist.segments[i];

        // Check if cancelled/failed
        final currentTask = _storage.getDownloadTask(videoId);
        if (currentTask == null || currentTask.status == DownloadStatus.failed) {
          logger.w('Download cancelled: $videoId');
          return;
        }

        // Download segment
        await _downloadSegment(segment, videoDir.path, i);

        // Update progress
        task.downloadedSegments = i + 1;
        task.progress = (i + 1) / playlist.totalSegments;
        await _storage.saveDownloadTask(task);

        // Trigger selective UI update for this specific task
        try {
          Get.find<DownloadsController>().update(['download_task_$videoId']);

          // Update storage usage
          Get.find<DownloadService>().calculateStorage();
        } catch (e) {
          // Controller might not be registered yet or disposed
        }

        logger.d('Downloaded segment ${i + 1}/${playlist.totalSegments}');
      }

      // 7. Rewrite playlist with local paths
      final localPlaylistPath = await _rewritePlaylist(playlist, videoDir.path, playlistContent);

      // 8. Mark as completed
      task.status = DownloadStatus.completed;
      task.localPath = localPlaylistPath;
      task.downloadedSegments = playlist.totalSegments;
      task.progress = 1.0;
      await _storage.saveDownloadTask(task);

      logger.i('HLS download completed: $videoTitle');
    } catch (e, stack) {
      logger.e('HLS download failed: $e');
      logger.e('Stack: $stack');

      // Mark as failed
      task.status = DownloadStatus.failed;
      task.errorMessage = e.toString();
      await _storage.saveDownloadTask(task);

      rethrow;
    }
  }

  /// Fetch playlist content
  Future<String> _fetchPlaylist(String url) async {
    try {
      final response = await _dio.get<String>(url);
      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to fetch playlist: ${response.statusCode}');
    } catch (e) {
      logger.e('Error fetching playlist: $e');
      rethrow;
    }
  }

  /// Download encryption key
  Future<void> _downloadEncryptionKey(HLSKey key, String videoDir) async {
    try {
      final response = await _dio.get<List<int>>(
        key.uri,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data != null) {
        final keyFile = File('$videoDir/key.bin');
        await keyFile.writeAsBytes(response.data!);
        logger.i('Encryption key downloaded');
      }
    } catch (e) {
      logger.e('Failed to download encryption key: $e');
      rethrow;
    }
  }

  /// Download segment with retry logic
  Future<void> _downloadSegment(
    HLSSegment segment,
    String videoDir,
    int index, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final response = await _dio.get<List<int>>(
          segment.url,
          options: Options(responseType: ResponseType.bytes),
        );

        if (response.data != null) {
          final segmentFile = File('$videoDir/segment_$index.ts');
          await segmentFile.writeAsBytes(response.data!);
          return; // Success, exit retry loop
        }
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          logger.e('Failed to download segment $index after $maxRetries attempts: $e');

          // Provide specific error messages
          if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
            throw Exception('Network error: Please check your internet connection');
          } else if (e.toString().contains('timeout')) {
            throw Exception('Download timeout: Server is not responding');
          } else {
            throw Exception('Failed to download segment $index: $e');
          }
        }

        // Exponential backoff: 1s, 2s, 4s
        final delay = Duration(seconds: 1 << (attempt - 1));
        logger.w(
          'Segment $index download failed (attempt $attempt/$maxRetries), retrying in ${delay.inSeconds}s...',
        );
        await Future.delayed(delay);
      }
    }
  }

  /// Rewrite playlist with local paths
  Future<String> _rewritePlaylist(
    HLSPlaylist playlist,
    String videoDir,
    String originalContent,
  ) async {
    try {
      var rewritten = originalContent;

      // Replace encryption key URI
      if (playlist.isEncrypted) {
        final keyUri = playlist.encryptionKey!.uri;
        rewritten = rewritten.replaceAll(keyUri, 'key.bin');
      }

      // Replace segment URLs
      for (var i = 0; i < playlist.segments.length; i++) {
        final segment = playlist.segments[i];
        rewritten = rewritten.replaceAll(segment.url, 'segment_$i.ts');
      }

      // Save rewritten playlist
      final playlistFile = File('$videoDir/playlist.m3u8');
      await playlistFile.writeAsString(rewritten);

      logger.i('Playlist rewritten and saved');
      return playlistFile.path;
    } catch (e) {
      logger.e('Failed to rewrite playlist: $e');
      rethrow;
    }
  }

  /// Delete HLS download
  Future<void> deleteHLSDownload(String videoId) async {
    try {
      await _ensureInitialized();

      final videoDir = Directory('$_downloadDirectory/$videoId');
      if (await videoDir.exists()) {
        await videoDir.delete(recursive: true);
        logger.i('Deleted HLS download: $videoId');
      }
    } catch (e) {
      logger.e('Failed to delete HLS download: $e');
      rethrow;
    }
  }

  /// Get local playlist path
  Future<String?> getLocalPlaylistPath(String videoId) async {
    await _ensureInitialized();

    final playlistFile = File('$_downloadDirectory/$videoId/playlist.m3u8');
    return playlistFile.existsSync() ? playlistFile.path : null;
  }
}
