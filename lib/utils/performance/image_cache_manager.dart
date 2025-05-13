import 'package:flutter/material.dart';

/// A utility class for managing image caching
class ImageCacheManager {
  /// Private constructor to prevent instantiation
  ImageCacheManager._();

  /// Singleton instance
  static final ImageCacheManager _instance = ImageCacheManager._();

  /// Get the singleton instance
  static ImageCacheManager get instance => _instance;

  /// Initialize the image cache with optimal settings
  void init() {
    // Set reasonable limits based on device memory
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50 MB

    debugPrint('ImageCacheManager: Initialized with 100 images / 50MB limit');
  }

  /// Clear the image cache
  void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    debugPrint('ImageCacheManager: Cache cleared');
  }

  /// Report current cache statistics
  void reportCacheStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    debugPrint('ImageCacheManager: Current cache size: ${imageCache.currentSize} images, '
        '${(imageCache.currentSizeBytes / 1024 / 1024).toStringAsFixed(2)} MB');
  }

  /// Optimize an image widget for performance
  Widget optimizedImage({
    required ImageProvider imageProvider,
    double? width,
    double? height,
    BoxFit? fit,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
  }) {
    return Image(
      image: imageProvider,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: loadingBuilder ?? _defaultLoadingBuilder,
      frameBuilder: _frameBuilder,
      errorBuilder: _errorBuilder,
    );
  }

  /// Default loading builder for images
  Widget _defaultLoadingBuilder(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) {
      return child;
    }
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
            : null,
      ),
    );
  }

  /// Frame builder for fade-in effect
  Widget _frameBuilder(BuildContext context, Widget child, int? frame, bool wasWasSynchronouslyLoaded) {
    if (wasWasSynchronouslyLoaded) {
      return child;
    }
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: child,
    );
  }

  /// Error builder for image loading failures
  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// Prefetch an image to warm up the cache
  Future<void> prefetchImage(ImageProvider imageProvider, BuildContext context) async {
    try {
      await precacheImage(imageProvider, context);
    } catch (e) {
      debugPrint('ImageCacheManager: Error prefetching image: $e');
    }
  }
}