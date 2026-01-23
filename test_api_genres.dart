import 'dart:convert';

import 'package:http/http.dart' as http;

/// Test script để lấy tất cả thể loại (genres/categories) từ API
/// Run: dart run test_api_genres.dart
void main() async {
  print('=== TESTING API FOR GENRES/CATEGORIES ===\n');

  // Test với danh sách phim mới nhất
  final endpoints = [
    'https://phimapi.com/danh-sach/phim-moi-cap-nhat?page=1',
    'https://phimapi.com/danh-sach/phim-moi-cap-nhat?page=2',
    'https://phimapi.com/v1/api/danh-sach/phim-moi-cap-nhat?page=1',
  ];

  final Set<String> allGenres = {};
  final Set<String> allQualityTags = {};
  final Set<String> allLangTags = {};
  final Set<String> allTypes = {};

  for (var endpoint in endpoints) {
    try {
      print('Fetching: $endpoint');
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        // Debug: print structure
        print('Response keys: ${data.keys}');

        // Try different data structures
        List? items;
        if (data['data'] != null && data['data']['items'] != null) {
          items = data['data']['items'] as List?;
        } else if (data['items'] != null) {
          items = data['items'] as List?;
        }

        if (items != null && items.isNotEmpty) {
          print('Found ${items.length} items');

          for (var item in items.take(10)) {
            // Lấy category
            final category = item['category'] as Map<String, dynamic>?;
            if (category != null) {
              for (var key in category.keys) {
                final catList = category[key];
                if (catList is List) {
                  for (var c in catList) {
                    if (c is Map && c['name'] != null) {
                      allGenres.add(c['name'].toString());
                    }
                  }
                }
              }
            }

            // Lấy quality
            if (item['quality'] != null && item['quality'].toString().isNotEmpty) {
              allQualityTags.add(item['quality'].toString());
            }

            // Lấy lang
            if (item['lang'] != null && item['lang'].toString().isNotEmpty) {
              allLangTags.add(item['lang'].toString());
            }

            // Lấy type (phim lẻ, phim bộ, etc)
            if (item['type'] != null && item['type'].toString().isNotEmpty) {
              allTypes.add(item['type'].toString());
            }

            // Lấy chieurap (cinema)
            if (item['chieurap'] != null) {
              print('Chieurap: ${item['chieurap']}');
            }
          }

          // Nếu đã có data thì break
          if (allGenres.isNotEmpty || allQualityTags.isNotEmpty) {
            break;
          }
        } else {
          print('No items found in response');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching $endpoint: $e');
    }
  }

  print('\n=== COLLECTED GENRES ===');
  final sortedGenres = allGenres.toList()..sort();
  for (var genre in sortedGenres) {
    print('- $genre');
  }

  print('\n=== COLLECTED QUALITY TAGS ===');
  final sortedQuality = allQualityTags.toList()..sort();
  for (var quality in sortedQuality) {
    print('- $quality');
  }

  print('\n=== COLLECTED LANGUAGE TAGS ===');
  final sortedLangs = allLangTags.toList()..sort();
  for (var lang in sortedLangs) {
    print('- $lang');
  }

  print('\n=== COLLECTED TYPES ===');
  final sortedTypes = allTypes.toList()..sort();
  for (var type in sortedTypes) {
    print('- $type');
  }

  print('\n=== TOTAL STATS ===');
  print('Total unique genres: ${allGenres.length}');
  print('Total unique quality tags: ${allQualityTags.length}');
  print('Total unique language tags: ${allLangTags.length}');
  print('Total unique types: ${allTypes.length}');
}
