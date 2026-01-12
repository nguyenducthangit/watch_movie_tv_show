import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extensions for Duration
extension DurationExtension on Duration {
  /// Format duration to mm:ss or HH:mm:ss
  String toFormattedString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Extensions for int (seconds to duration string)
extension IntDurationExtension on int {
  /// Convert seconds to formatted duration
  String toFormattedDuration() {
    return Duration(seconds: this).toFormattedString();
  }
}

/// Extensions for double (file size)
extension FileSizeExtension on double {
  /// Format MB to readable string
  String toFileSizeString() {
    if (this >= 1024) {
      return '${(this / 1024).toStringAsFixed(1)} GB';
    }
    return '${toStringAsFixed(0)} MB';
  }
}

/// Extensions for int (bytes to readable)
extension BytesSizeExtension on int {
  /// Format bytes to readable string
  String toBytesString() {
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (this >= gb) {
      return '${(this / gb).toStringAsFixed(1)} GB';
    } else if (this >= mb) {
      return '${(this / mb).toStringAsFixed(0)} MB';
    } else if (this >= kb) {
      return '${(this / kb).toStringAsFixed(0)} KB';
    }
    return '$this B';
  }
}

/// Extensions for String
extension StringExtension on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if string is valid URL
  bool get isValidUrl {
    final uri = Uri.tryParse(this);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }
}

/// Extensions for DateTime
extension DateTimeExtension on DateTime {
  /// Format to readable date
  String toFormattedDate() {
    return DateFormat('MMM d, yyyy').format(this);
  }

  /// Format to relative time (e.g., "2 hours ago")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    }
    return 'Just now';
  }
}

/// Extensions for BuildContext
extension ContextExtension on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Get screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Get screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Get padding (safe area)
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? colorScheme.error : null),
    );
  }
}

/// Extensions for List
extension ListExtension<T> on List<T> {
  /// Safe get at index
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
