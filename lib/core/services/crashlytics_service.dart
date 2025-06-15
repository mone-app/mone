// lib/core/services/crashlytics_service.dart

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static CrashlyticsService? _instance;
  static CrashlyticsService get instance {
    _instance ??= CrashlyticsService._internal();
    return _instance!;
  }

  CrashlyticsService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize Crashlytics with error handlers
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Pass all uncaught "fatal errors" from the framework to Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Enable Crashlytics collection
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      _isInitialized = true;

      // Log initialization
      FirebaseCrashlytics.instance.log('Crashlytics initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Crashlytics: $e');
    }
  }
}
