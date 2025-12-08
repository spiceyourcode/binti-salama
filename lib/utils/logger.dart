import 'package:flutter/foundation.dart';

/// Custom logger utility for Binti Salama
/// Uses debugPrint in debug mode, silent in release mode
class AppLogger {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('WARNING: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('INFO: $message');
    }
  }
}
