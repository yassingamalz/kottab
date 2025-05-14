import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:kottab/utils/arabic_numbers.dart';
import 'package:kottab/utils/date_formatter.dart';
import 'package:kottab/providers/session_provider.dart';
import 'package:kottab/widgets/sessions/add_session_modal.dart';

class VerseSetCard extends StatelessWidget {
  final VerseSet verseSet;
  final String surahName;
  final VoidCallback? onReviewPressed;

  const VerseSetCard({
    super.key,
    required this.verseSet,
    required this.surahName,
    this.onReviewPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Configure colors based on status
    late final Color bgColor;
    late final Color textColor;
    late final Color borderColor;
    late final String statusText;
    final bool isDisabled = verseSet.status == MemorizationStatus.notStarted;

    switch (verseSet.status) {
      case MemorizationStatus.memorized:
        bgColor = AppColors.primaryLight;
        textColor = AppColors.primary;
        borderColor = AppColors.primary.withOpacity(0.3);
        statusText = 'محفوظ';
        break;
      case MemorizationStatus.inProgress:
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade800;
        borderColor = Colors.amber.shade200;
        statusText = 'قيد الحفظ';
        break;
      case MemorizationStatus.notStarted:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade600;
        borderColor = Colors.grey.shade200;
        statusText = 'لم يبدأ بعد';
        break;
    }

    // Format the last review date if available
    final String lastReviewText = verseSet.lastReviewDate != null
        ? DateFormatter.getRelativeDateString(verseSet.lastReviewDate!)
        : 'لم تتم المراجعة بعد';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with verse range and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الآيات ${verseSet.rangeText}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    surahName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Review stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ArabicNumbers.toArabicDigits(verseSet.reviewCount)} مراجعات',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                lastReviewText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Review button
          ElevatedButton(
            onPressed: isDisabled 
                ? null 
                : () {
                    if (onReviewPressed != null) {
                      onReviewPressed!();
                    } else {
                      // Show session modal if no callback is provided
                      _showAddSessionModal(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled ? Colors.grey.shade200 : AppColors.primary,
              foregroundColor: isDisabled ? Colors.grey.shade500 : Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              disabledForegroundColor: Colors.grey.shade500,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'تسجيل المراجعة',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDisabled ? Colors.grey.shade500 : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Add this method to show the session modal
  void _showAddSessionModal(BuildContext context) {
    // Get the provider
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    // Initialize a new session with this verse set's data
    sessionProvider.startNewSession(
      surahId: verseSet.surahId,
      type: verseSet.status == MemorizationStatus.memorized 
          ? SessionType.recentReview 
          : SessionType.newMemorization,
    );
    
    // Update verse range
    sessionProvider.updateSessionVerseRange(
      verseSet.startVerse, 
      verseSet.endVerse
    );
    
    // Show modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => const AddSessionModal(),
    );
  }
}
