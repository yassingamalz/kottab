import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';

class TutorialPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget image;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback? onComplete;

  const TutorialPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    this.isLastPage = false,
    required this.onNext,
    required this.onSkip,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Skip button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'تخطي',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Image
          Expanded(
            child: Center(
              child: image,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Next or Complete button
          ElevatedButton(
            onPressed: isLastPage ? onComplete : onNext,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isLastPage ? 'ابدأ الآن' : 'التالي',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}