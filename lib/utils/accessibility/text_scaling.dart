import 'package:flutter/material.dart';

/// A utility class for handling text scaling and accessibility
class TextScaling {
  /// Private constructor to prevent instantiation
  TextScaling._();

  /// Singleton instance
  static final TextScaling _instance = TextScaling._();

  /// Get the singleton instance
  static TextScaling get instance => _instance;

  /// Default text scale factor
  static const double defaultTextScaleFactor = 1.0;

  /// Minimum allowed text scale factor
  static const double minTextScaleFactor = 0.8;

  /// Maximum allowed text scale factor
  static const double maxTextScaleFactor = 1.5;

  /// Current text scale factor
  double _textScaleFactor = defaultTextScaleFactor;

  /// Get the current text scale factor
  double get textScaleFactor => _textScaleFactor;

  /// Set the text scale factor
  set textScaleFactor(double value) {
    _textScaleFactor = value.clamp(minTextScaleFactor, maxTextScaleFactor);
  }

  /// Reset the text scale factor to default
  void resetTextScaleFactor() {
    _textScaleFactor = defaultTextScaleFactor;
  }

  /// Increase the text scale factor
  void increaseTextScaleFactor() {
    _textScaleFactor = (_textScaleFactor + 0.1).clamp(minTextScaleFactor, maxTextScaleFactor);
  }

  /// Decrease the text scale factor
  void decreaseTextScaleFactor() {
    _textScaleFactor = (_textScaleFactor - 0.1).clamp(minTextScaleFactor, maxTextScaleFactor);
  }

  /// Get a text style with the current text scale factor applied
  TextStyle getScaledTextStyle(TextStyle style) {
    return style.copyWith(
      fontSize: style.fontSize != null
          ? style.fontSize! * _textScaleFactor
          : null,
    );
  }

  /// Build a widget that respects text scaling
  Widget buildAccessibleText(
      BuildContext context,
      String text,
      TextStyle style, {
        TextAlign? textAlign,
        int? maxLines,
        TextOverflow? overflow,
      }) {
    return Text(
      text,
      style: getScaledTextStyle(style),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Apply a minimum tap target size to a widget for better accessibility
  Widget withMinimumTapTargetSize(Widget child, {double minSize = 48.0}) {
    return SizedBox(
      width: minSize,
      height: minSize,
      child: Center(
        child: child,
      ),
    );
  }

  /// Apply semantic labels to a widget for screen readers
  Widget withSemanticLabel(Widget child, String label) {
    return Semantics(
      label: label,
      child: child,
    );
  }

  /// Create a widget that shows the current text scale factor
  Widget buildScaleFactorIndicator() {
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Scale: ${(_textScaleFactor * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  /// Build a text scaling controller widget
  Widget buildTextScalingController(void Function(double) onScaleChanged) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                decreaseTextScaleFactor();
                onScaleChanged(_textScaleFactor);
              },
              tooltip: 'تصغير النص',
            ),
            Expanded(
              child: Slider(
                value: _textScaleFactor,
                min: minTextScaleFactor,
                max: maxTextScaleFactor,
                divisions: 7,
                label: '${(_textScaleFactor * 100).round()}%',
                onChanged: (value) {
                  _textScaleFactor = value;
                  onScaleChanged(value);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                increaseTextScaleFactor();
                onScaleChanged(_textScaleFactor);
              },
              tooltip: 'تكبير النص',
            ),
          ],
        );
      },
    );
  }
}