import 'dart:math';
import 'package:flutter/material.dart';

/// A utility class for handling color contrast and accessibility
class ColorContrast {
  /// Private constructor to prevent instantiation
  ColorContrast._();

  /// Singleton instance
  static final ColorContrast _instance = ColorContrast._();

  /// Get the singleton instance
  static ColorContrast get instance => _instance;

  /// Check if contrast between two colors meets WCAG AA standard (4.5:1 for normal text)
  bool meetsWCAG2AA(Color foreground, Color background) {
    final contrast = calculateContrast(foreground, background);
    return contrast >= 4.5;
  }

  /// Check if contrast between two colors meets WCAG AAA standard (7:1 for normal text)
  bool meetsWCAG2AAA(Color foreground, Color background) {
    final contrast = calculateContrast(foreground, background);
    return contrast >= 7.0;
  }

  /// Calculate contrast ratio between two colors
  double calculateContrast(Color foreground, Color background) {
    final foregroundLuminance = calculateRelativeLuminance(foreground);
    final backgroundLuminance = calculateRelativeLuminance(background);

    final lighter = max(foregroundLuminance, backgroundLuminance);
    final darker = min(foregroundLuminance, backgroundLuminance);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calculate relative luminance of a color (per WCAG 2.0 definition)
  double calculateRelativeLuminance(Color color) {
    // Convert RGB to linear values
    final double r = _linearize(color.red / 255);
    final double g = _linearize(color.green / 255);
    final double b = _linearize(color.blue / 255);

    // Calculate luminance with coefficients
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Convert sRGB component to linear value
  double _linearize(double component) {
    return component <= 0.03928
        ? component / 12.92
        : pow((component + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Get an accessible text color for a given background
  Color getAccessibleTextColor(Color background) {
    final luminance = calculateRelativeLuminance(background);
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Darken a color by a percentage
  Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Lighten a color by a percentage
  Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Create a color that meets minimum contrast requirements
  Color ensureMinimumContrast(
      Color foreground,
      Color background, {
        double minContrast = 4.5,
        double step = 0.05,
      }) {
    double contrast = calculateContrast(foreground, background);
    if (contrast >= minContrast) {
      return foreground;
    }

    // Determine if we should lighten or darken the foreground
    final backgroundLuminance = calculateRelativeLuminance(background);
    final shouldLighten = backgroundLuminance <= 0.5;

    Color adjustedColor = foreground;
    double amount = 0.0;

    while (contrast < minContrast && amount < 1.0) {
      amount += step;
      adjustedColor = shouldLighten
          ? lighten(foreground, amount)
          : darken(foreground, amount);

      contrast = calculateContrast(adjustedColor, background);
    }

    return adjustedColor;
  }

  /// Create a custom color swatch that ensures accessibility
  MaterialColor createAccessibleSwatch(Color baseColor) {
    final Map<int, Color> swatch = {
      50: lighten(baseColor, 0.4),
      100: lighten(baseColor, 0.3),
      200: lighten(baseColor, 0.2),
      300: lighten(baseColor, 0.1),
      400: lighten(baseColor, 0.05),
      500: baseColor,
      600: darken(baseColor, 0.05),
      700: darken(baseColor, 0.1),
      800: darken(baseColor, 0.2),
      900: darken(baseColor, 0.3),
    };

    return MaterialColor(baseColor.value, swatch);
  }

  /// Build a widget to demonstrate the contrast between two colors
  Widget buildContrastDemonstrator(Color foreground, Color background) {
    final contrast = calculateContrast(foreground, background);
    final meetsAA = meetsWCAG2AA(foreground, background);
    final meetsAAA = meetsWCAG2AAA(foreground, background);

    return Container(
      padding: const EdgeInsets.all(16),
      color: background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نموذج نص للاختبار',
            style: TextStyle(
              color: foreground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'نص أصغر للعرض والقراءة',
            style: TextStyle(
              color: foreground,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نسبة التباين: ${contrast.toStringAsFixed(2)}'),
                Text('WCAG AA: ${meetsAA ? 'نعم ✓' : 'لا ✗'}'),
                Text('WCAG AAA: ${meetsAAA ? 'نعم ✓' : 'لا ✗'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}