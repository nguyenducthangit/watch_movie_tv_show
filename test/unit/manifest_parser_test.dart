import 'package:flutter_test/flutter_test.dart';
import 'package:watch_movie_tv_show/app/data/models/manifest.dart';

void main() {
  group('Manifest Parsing', () {
    test('should parse valid manifest JSON', () {
      final json = {
        "version": 1,
        "updatedAt": "2023-10-27T10:00:00Z",
        "items": [
          {
            "id": "vid_01",
            "title": "Test Video",
            "description": "A test video",
            "durationSec": 120,
            "thumbnailUrl": "https://example.com/thumb.jpg",
            "streamUrl": "https://example.com/video.mp4",
            "tags": ["drama", "featured"],
            "download": {
              "qualities": [
                {"label": "720p", "url": "https://example.com/720p.mp4", "sizeMB": 150.5},
              ],
            },
          },
        ],
      };

      final manifest = Manifest.fromJson(json);

      expect(manifest.version, 1);
      expect(manifest.items.length, 1);

      final video = manifest.items.first;
      expect(video.id, 'vid_01');
      expect(video.title, 'Test Video');
      expect(video.tags, contains('drama'));
      expect(video.hasDownloadOptions, true);
      expect(video.bestQuality?.label, '720p');
      expect(video.bestQuality?.sizeMB, 150.5);
    });

    test('should parse manifest without optional fields', () {
      final json = {
        "version": 1,
        "updatedAt": "2023-10-27T10:00:00Z",
        "items": [
          {
            "id": "vid_02",
            "title": "Simple Video",
            "thumbnailUrl": "https://example.com/thumb.jpg",
            "streamUrl": "https://example.com/video.mp4",
          },
        ],
      };

      final manifest = Manifest.fromJson(json);
      final video = manifest.items.first;

      expect(video.description, null);
      expect(video.tags, null);
      expect(video.downloadQualities, null);
      expect(video.hasDownloadOptions, false);
    });
  });
}
