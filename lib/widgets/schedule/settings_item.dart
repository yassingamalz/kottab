import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';

import '../../config/app_theme.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String description;
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const SettingsItem({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    this.minValue = 1,
    this.maxValue = 50,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Value selector
          Row(
            children: [
              // Decrease button
              IconButton(
                onPressed: value > minValue
                    ? () => onChanged(value - 1)
                    : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: value > minValue
                      ? AppColors.primary
                      : Colors.grey.shade400,
                ),
              ),

              // Value display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ArabicNumbers.toArabicDigits(value),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Increase button
              IconButton(
                onPressed: value < maxValue
                    ? () => onChanged(value + 1)
                    : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: value < maxValue
                      ? AppColors.primary
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}