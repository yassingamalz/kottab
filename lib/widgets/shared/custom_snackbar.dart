import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';

/// Display a custom snackbar with the given message and type
void showCustomSnackBar({
  required BuildContext context,
  required String message,
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  // Configure colors based on type
  late final Color backgroundColor;
  late final Color textColor;
  late final IconData icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = AppColors.primaryLight;
      textColor = AppColors.primary;
      icon = Icons.check_circle;
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      icon = Icons.error;
      break;
    case SnackBarType.warning:
      backgroundColor = Colors.amber.shade50;
      textColor = Colors.amber.shade800;
      icon = Icons.warning;
      break;
    case SnackBarType.info:
      backgroundColor = AppColors.blueLight;
      textColor = AppColors.blue;
      icon = Icons.info;
      break;
  }

  // Create and show the snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      action: SnackBarAction(
        label: 'إغلاق',
        textColor: textColor,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

/// Types of snackbar notifications
enum SnackBarType {
  success,
  error,
  warning,
  info,
}