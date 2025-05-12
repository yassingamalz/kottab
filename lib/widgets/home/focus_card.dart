import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';

import '../../config/app_theme.dart';

enum FocusCardType {
  newMemorization,
  recentReview,
  oldReview,
}

class FocusCard extends StatelessWidget {
  final FocusCardType type;
  final String surahName;
  final String verseRange;
  final double progress;
  final String statusText;
  final bool isCompleted;
  final VoidCallback onTap;

  const FocusCard({
    super.key,
    required this.type,
    required this.surahName,
    required this.verseRange,
    required this.progress,
    required this.statusText,
    this.isCompleted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Configure colors and icons based on type
    late final Color bgColor;
    late final Color borderColor;
    late final Color iconColor;
    late final IconData iconData;
    late final String title;

    switch (type) {
      case FocusCardType.newMemorization:
        bgColor = AppColors.primaryLight;
        borderColor = AppColors.primary.withOpacity(0.3);
        iconColor = AppColors.primary;
        iconData = Icons.bolt;
        title = 'حفظ جديد';
        break;
      case FocusCardType.recentReview:
        bgColor = AppColors.blueLight;
        borderColor = AppColors.blue.withOpacity(0.3);
        iconColor = AppColors.blue;
        iconData = Icons.refresh;
        title = 'مراجعة حديثة';
        break;
      case FocusCardType.oldReview:
        bgColor = AppColors.purpleLight;
        borderColor = AppColors.purple.withOpacity(0.3);
        iconColor = AppColors.purple;
        iconData = Icons.repeat;
        title = 'مراجعة سابقة';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Background progress indicator
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            // Card content
            Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$surahName $verseRange',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),

                // Status
                isCompleted
                    ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                    : Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}