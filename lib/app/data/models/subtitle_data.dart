import 'subtitle_entry.dart';

/// Subtitle Data Model
/// Contains all subtitle entries for a video with language info
class SubtitleData {
  const SubtitleData({required this.language, required this.entries, this.translatedLanguage});

  final String language; // Original language code (e.g., 'en', 'vi')
  final List<SubtitleEntry> entries;
  final String? translatedLanguage; // Target language if translated

  /// Get subtitle entry for current position
  SubtitleEntry? getEntryAt(Duration position) {
    try {
      return entries.firstWhere((entry) => entry.isActiveAt(position));
    } catch (e) {
      return null; // No subtitle at this position
    }
  }

  /// Check if translated
  bool get isTranslated => translatedLanguage != null;

  /// Get language display name
  String get languageDisplay {
    if (isTranslated) return '$translatedLanguage (translated from $language)';
    return language;
  }

  /// Copy with
  SubtitleData copyWith({
    String? language,
    List<SubtitleEntry>? entries,
    String? translatedLanguage,
  }) {
    return SubtitleData(
      language: language ?? this.language,
      entries: entries ?? this.entries,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
    );
  }

  @override
  String toString() => 'SubtitleData($language, ${entries.length} entries)';
}
