import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/models/surah_model.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:kottab/utils/arabic_numbers.dart';
import 'package:kottab/widgets/surahs/verse_set_card.dart';
import 'package:kottab/providers/session_provider.dart';
import 'package:kottab/widgets/sessions/add_session_modal.dart';
import 'package:provider/provider.dart';

class SurahCard extends StatelessWidget {
  final Surah surah;
  final bool isExpanded;
  final Function(int) onToggle;

  const SurahCard({
    super.key,
    required this.surah,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          // Surah header
          InkWell(
            onTap: () => onToggle(surah.id),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Surah number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        ArabicNumbers.toArabicDigits(surah.id),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Surah name and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.arabicName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${ArabicNumbers.formatVerseCount(surah.verseCount)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress indicator
                  if (surah.memorizedPercentage > 0)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(left: 8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: surah.memorizedPercentage,
                            backgroundColor: Colors.grey.shade100,
                            color: AppColors.primary,
                            strokeWidth: 5,
                          ),
                          Text(
                            ArabicNumbers.formatPercentage(surah.memorizedPercentage),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Expand/collapse icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content with LazyBuilder for better performance
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.background,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: surah.verseSets.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: VerseSetCard(
                            verseSet: surah.verseSets[index],
                            surahName: surah.arabicName,
                            onReviewPressed: () => _handleReviewPressed(context, surah.verseSets[index]),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Handle review button press
  void _handleReviewPressed(BuildContext context, final verseSet) {
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
