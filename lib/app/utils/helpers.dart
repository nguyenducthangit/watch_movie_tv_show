import 'package:logger/logger.dart';

/// App Logger
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// Helper Functions
class Helpers {
  Helpers._();

  /// Debounce function
  static void Function() debounce(
    void Function() callback, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    bool isDebouncing = false;
    return () {
      if (isDebouncing) return;
      isDebouncing = true;
      Future.delayed(duration, () {
        callback();
        isDebouncing = false;
      });
    };
  }

  /// Throttle function
  static void Function() throttle(
    void Function() callback, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    DateTime? lastRun;
    return () {
      final now = DateTime.now();
      if (lastRun == null || now.difference(lastRun!) > duration) {
        lastRun = now;
        callback();
      }
    };
  }

  /// Safe parse int
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safe parse double
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Check if string is blank (null or empty or whitespace)
  static bool isBlank(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if string is not blank
  static bool isNotBlank(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
