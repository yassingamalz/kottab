import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final double progress;
  final Color progressColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.suffix,
    required this.description,
    required this.icon,
    required this.progress,
    this.iconColor = AppColors.primary,
    this.bgColor = AppColors.primaryLight,
    this.progressColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with icon
              Row(
                children: [
                  Container(
                    width: 36, // Slightly larger icon container
                    height: 36, // Slightly larger icon container
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 18, // Slightly larger icon
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Constrain the text to prevent overflow
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14, // Increased font size
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16), // Increased spacing

              // Value with suffix - explicitly managed for RTL
              Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 26, // Increased font size
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    suffix,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 15, // Increased font size
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6), // Adjusted spacing

              // Description - constrained to prevent overflow
              SizedBox(
                height: 20, // Fixed height
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13, // Increased font size
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Progress indicator circle at top right
          Positioned(
            top: 0,
            left: 0, // Changed from right to left for RTL layout
            child: SizedBox(
              width: 28, // Slightly larger progress indicator
              height: 28, // Slightly larger progress indicator
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade100,
                color: progressColor,
                strokeWidth: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
