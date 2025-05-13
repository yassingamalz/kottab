import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A utility class for handling errors in the app
class ErrorHandler {
  /// Private constructor to prevent instantiation
  ErrorHandler._();

  /// Singleton instance
  static final ErrorHandler _instance = ErrorHandler._();

  /// Get the singleton instance
  static ErrorHandler get instance => _instance;

  /// Store for error history
  final List<AppError> _errorHistory = [];

  /// Maximum number of errors to keep in history
  static const int maxErrorHistorySize = 10;

  /// Initialize error handling
  void init() {
    // Set up global error handling
    FlutterError.onError = _handleFlutterError;

    // Handle async errors that aren't caught by Flutter's error zone
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('PlatformDispatcher', error, stack);
      return true;
    };

    debugPrint('ErrorHandler: Initialized global error handling');
  }

  /// Handle Flutter errors
  void _handleFlutterError(FlutterErrorDetails details) {
    _logError('Flutter', details.exception, details.stack);

    // Report to console in debug mode
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  }

  /// Log an error
  void _logError(String source, dynamic error, StackTrace? stackTrace) {
    final timestamp = DateTime.now();
    final errorMessage = error.toString();

    debugPrint('ERROR [$source] $errorMessage');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }

    // Add to error history
    _errorHistory.add(AppError(
      source: source,
      message: errorMessage,
      stackTrace: stackTrace?.toString() ?? 'No stack trace',
      timestamp: timestamp,
    ));

    // Trim history if it gets too large
    if (_errorHistory.length > maxErrorHistorySize) {
      _errorHistory.removeAt(0);
    }

    // TODO: In a production app, we would report to a service like Crashlytics
  }

  /// Get the error history
  List<AppError> get errorHistory => List.unmodifiable(_errorHistory);

  /// Clear the error history
  void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// Show an error dialog
  Future<void> showErrorDialog(BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حدث خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  /// Show a network error snackbar
  void showNetworkErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('فشل الاتصال بالإنترنت'),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // TODO: Retry the failed operation
              },
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Try a function that might throw an error and handle it
  Future<T?> tryAsync<T>(
      Future<T> Function() function, {
        Function(dynamic, StackTrace)? onError,
      }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      _logError('tryAsync', error, stackTrace);

      if (onError != null) {
        onError(error, stackTrace);
      }

      return null;
    }
  }

  /// Check for network connectivity
  Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      _logError('isNetworkAvailable', e, StackTrace.current);
      return false;
    }
  }

  /// Build an error widget for widget build failures
  Widget buildErrorWidget(Object error, StackTrace stackTrace) {
    _logError('BuildError', error, stackTrace);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red.shade50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'حدث خطأ أثناء بناء هذا العنصر',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (kDebugMode)
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}

/// A class to represent an application error
class AppError {
  final String source;
  final String message;
  final String stackTrace;
  final DateTime timestamp;

  AppError({
    required this.source,
    required this.message,
    required this.stackTrace,
    required this.timestamp,
  });

  @override
  String toString() {
    return '[$source] $message\n$stackTrace';
  }
}