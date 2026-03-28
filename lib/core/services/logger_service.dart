import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Log a debug message
  static void d(String message, {dynamic error, StackTrace? stack}) {
    _logger.d(message, error: error, stackTrace: stack);
    if (kReleaseMode) {
      _crashlytics.log('DEBUG: $message');
    }
  }

  /// Log an info message
  static void i(String message) {
    _logger.i(message);
    _crashlytics.log('INFO: $message');
  }

  /// Log a warning message
  static void w(String message) {
    _logger.w(message);
    _crashlytics.log('WARNING: $message');
  }

  /// Log an error message
  static void e(String message, {dynamic error, StackTrace? stack, bool fatal = false}) {
    _logger.e(message, error: error, stackTrace: stack);
    _crashlytics.recordError(error ?? message, stack, reason: message, fatal: fatal);
  }

  /// Track a screen view
  static Future<void> trackScreen(String screenName) async {
    i('Screen Viewed: $screenName');
    await _analytics.logScreenView(screenName: screenName);
  }

  /// Track a custom event
  static Future<void> trackEvent(String name, {Map<String, Object>? parameters}) async {
    i('Event: $name ${parameters ?? ''}');
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Set user ID for analytics and crashlytics
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId);
  }
}
