import 'dart:async';
import 'package:flutter/material.dart';

/// A utility class for monitoring and optimizing app performance
class AppPerformance {
  /// Private constructor to prevent instantiation
  AppPerformance._();

  /// Singleton instance
  static final AppPerformance _instance = AppPerformance._();

  /// Get the singleton instance
  static AppPerformance get instance => _instance;

  /// Map to store performance metrics
  final Map<String, PerformanceMetric> _metrics = {};

  /// Initialize performance monitoring
  void init() {
    // Set up any global performance monitoring here
    debugPrint('AppPerformance: Initialized performance monitoring');
  }

  /// Start measuring a performance metric
  void startMeasure(String name) {
    _metrics[name] = PerformanceMetric(name: name)..start();
  }

  /// End measuring a performance metric and get the duration
  Duration? endMeasure(String name) {
    final metric = _metrics[name];
    if (metric != null) {
      final duration = metric.end();
      debugPrint('AppPerformance: $name took ${duration.inMilliseconds}ms');
      return duration;
    }
    return null;
  }

  /// Run a function and measure its performance
  Future<T> measure<T>(String name, Future<T> Function() func) async {
    startMeasure(name);
    try {
      return await func();
    } finally {
      endMeasure(name);
    }
  }

  /// Run a synchronous function and measure its performance
  T measureSync<T>(String name, T Function() func) {
    startMeasure(name);
    try {
      return func();
    } finally {
      endMeasure(name);
    }
  }

  /// Get all performance metrics
  Map<String, PerformanceMetric> get metrics => _metrics;

  /// Clear all performance metrics
  void clear() {
    _metrics.clear();
  }

  /// Performance optimization: Ensure efficient widget rebuilds
  static void optimizeRebuild(BuildContext context, String widgetName, {bool verbose = false}) {
    if (verbose) {
      debugPrint('Rebuild: $widgetName');
    }
  }

  /// Performance optimization: Minimize unnecessary rebuilds using const constructors
  static void optimizeConstConstructors() {
    // This is more of a reminder for the developer
    // Use const constructors wherever possible
  }

  /// Performance optimization: Use lazy loading for heavy UI components
  static Widget lazyLoadWidget({
    required Widget child,
    Widget? placeholder,
    bool isLoaded = false,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    if (isLoaded) {
      return child;
    }

    return FutureBuilder<bool>(
      future: Future.delayed(delay, () => true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }
        return placeholder ?? const SizedBox.shrink();
      },
    );
  }
}

/// A class to represent a performance metric
class PerformanceMetric {
  final String name;
  DateTime? _startTime;
  DateTime? _endTime;
  Duration? _duration;

  PerformanceMetric({required this.name});

  /// Start measuring
  void start() {
    _startTime = DateTime.now();
    _endTime = null;
    _duration = null;
  }

  /// End measuring and return the duration
  Duration end() {
    if (_startTime == null) {
      throw Exception('PerformanceMetric: Cannot end a metric that has not been started');
    }

    _endTime = DateTime.now();
    _duration = _endTime!.difference(_startTime!);
    return _duration!;
  }

  /// Get the duration
  Duration? get duration => _duration;

  /// Check if this metric is currently running
  bool get isRunning => _startTime != null && _endTime == null;
}