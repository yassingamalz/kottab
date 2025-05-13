import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kottab/utils/performance/app_performance.dart';
import 'package:kottab/utils/performance/image_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A utility class for initializing the app with optimized settings
class AppInitializer {
  /// Private constructor to prevent instantiation
  AppInitializer._();

  /// Singleton instance
  static final AppInitializer _instance = AppInitializer._();

  /// Get the singleton instance
  static AppInitializer get instance => _instance;

  /// Flag to track if the app has been initialized
  bool _isInitialized = false;

  /// Flag to track if the app is in first run
  bool _isFirstRun = true;

  /// Get if this is the first run of the app
  bool get isFirstRun => _isFirstRun;

  /// Get if the app has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the app with optimal settings
  Future<void> initializeApp() async {
    if (_isInitialized) {
      debugPrint('AppInitializer: App already initialized');
      return;
    }

    AppPerformance.instance.startMeasure('app_initialization');

    // Enforce portrait orientation for better user experience
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style for better visibility
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize performance monitoring
    AppPerformance.instance.init();

    // Initialize image cache for optimal memory usage
    ImageCacheManager.instance.init();

    // Check if this is the first run of the app
    await _checkFirstRun();

    // Preload essential resources if needed
    await _preloadResources();

    _isInitialized = true;

    final duration = AppPerformance.instance.endMeasure('app_initialization');
    debugPrint('AppInitializer: App initialized in ${duration?.inMilliseconds}ms');
  }

  /// Check if this is the first run of the app
  Future<void> _checkFirstRun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isFirstRun = !(prefs.getBool('app_initialized') ?? false);

      if (_isFirstRun) {
        await prefs.setBool('app_initialized', true);
        debugPrint('AppInitializer: First run detected');
      }
    } catch (e) {
      debugPrint('AppInitializer: Error checking first run: $e');
      _isFirstRun = false;
    }
  }

  /// Preload essential resources
  Future<void> _preloadResources() async {
    // This would be used to preload any essential assets
    // For example, loading images, fonts, or data

    // In a real app, we would have code like:
    // await Future.wait([
    //   precacheImage(AssetImage('assets/images/logo.png'), context),
    //   loadInitialData(),
    // ]);

    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Get the appropriate initial route based on app state
  String getInitialRoute() {
    if (_isFirstRun) {
      return '/onboarding';
    }
    return '/home';
  }

  /// Run post-initialization tasks
  Future<void> runPostInitTasks() async {
    // Tasks that can run after the app is visible to the user
    // For example, checking for updates, analytics initialization

    debugPrint('AppInitializer: Running post-initialization tasks');

    // Example: Simulate a background task
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Clean up resources when the app is closing
  Future<void> dispose() async {
    debugPrint('AppInitializer: Disposing resources');

    // Clear image cache
    ImageCacheManager.instance.clearCache();

    // Clear performance metrics
    AppPerformance.instance.clear();
  }
}