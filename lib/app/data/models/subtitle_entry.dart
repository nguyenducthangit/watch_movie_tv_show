/// Subtitle Entry Model
/// Represents a single subtitle entry with start/end time and text
class SubtitleEntry {
  const SubtitleEntry({
    required this.startTime,
    required this.endTime,
    required this.text,
    this.translatedText,
  });

  final Duration startTime;
  final Duration endTime;
  final String text;
  final String? translatedText;

  /// Check if this subtitle should be displayed at current position
  bool isActiveAt(Duration position) {
    return position >= startTime && position <= endTime;
  }

  /// Get display text (translated if available, otherwise original)
  String get displayText => translatedText ?? text;

  /// Copy with
  SubtitleEntry copyWith({
    Duration? startTime,
    Duration? endTime,
    String? text,
    String? translatedText,
  }) {
    return SubtitleEntry(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      text: text ?? this.text,
      translatedText: translatedText ?? this.translatedText,
    );
  }

  @override
  String toString() => 'SubtitleEntry($startTime - $endTime: $text)';
}
