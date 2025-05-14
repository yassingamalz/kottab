import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/models/surah_model.dart';
import 'package:kottab/utils/arabic_numbers.dart';
import 'package:kottab/widgets/surahs/verse_set_card.dart';

class SurahCard extends StatelessWidget {
  final Surah surah;
  final bool isExpanded;
  final Function(int) onToggle;
  final Function(int, int, int) onAddVerseSet;

  const SurahCard({
    super.key,
    required this.surah,
    required this.isExpanded,
    required this.onToggle,
    required this.onAddVerseSet,
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
              child: Column(
                children: [
                  // Use a separate ListView Builder for verse sets to improve performance
                  if (surah.verseSets.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: surah.verseSets.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: VerseSetCard(
                            verseSet: surah.verseSets[index],
                            surahName: surah.arabicName,
                          ),
                        );
                      },
                    ),

                  // Add new verse set button
                  InkWell(
                    onTap: () => _showAddVerseSetDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'إضافة مجموعة جديدة',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Show dialog to add a new verse set
  void _showAddVerseSetDialog(BuildContext context) {
    int startVerse = 1;
    int endVerse = 10;

    // Find the last verse in existing sets
    if (surah.verseSets.isNotEmpty) {
      final lastSet = surah.verseSets.reduce(
              (a, b) => a.endVerse > b.endVerse ? a : b
      );
      startVerse = lastSet.endVerse + 1;
      endVerse = startVerse + 9;

      // Ensure we don't exceed the surah's verse count
      if (endVerse > surah.verseCount) {
        endVerse = surah.verseCount;
      }
    }

    // Show dialog
    showDialog(
      context: context,
      builder: (context) => AddVerseSetDialog(
        surahName: surah.arabicName,
        maxVerses: surah.verseCount,
        initialStartVerse: startVerse,
        initialEndVerse: endVerse,
        onAdd: (start, end) {
          Navigator.of(context).pop();
          onAddVerseSet(surah.id, start, end);
        },
      ),
    );
  }
}

/// Dialog to add a new verse set
class AddVerseSetDialog extends StatefulWidget {
  final String surahName;
  final int maxVerses;
  final int initialStartVerse;
  final int initialEndVerse;
  final Function(int, int) onAdd;

  const AddVerseSetDialog({
    super.key,
    required this.surahName,
    required this.maxVerses,
    required this.initialStartVerse,
    required this.initialEndVerse,
    required this.onAdd,
  });

  @override
  State<AddVerseSetDialog> createState() => _AddVerseSetDialogState();
}

class _AddVerseSetDialogState extends State<AddVerseSetDialog> {
  late int startVerse;
  late int endVerse;

  @override
  void initState() {
    super.initState();
    startVerse = widget.initialStartVerse;
    endVerse = widget.initialEndVerse;
  }

  @override
  Widget build(BuildContext context) {
    // Make sure we have valid verse ranges
    if (startVerse > widget.maxVerses) {
      startVerse = widget.maxVerses;
    }
    if (endVerse > widget.maxVerses) {
      endVerse = widget.maxVerses;
    }
    
    return AlertDialog(
      title: Text(
        'إضافة مجموعة آيات جديدة',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'سورة ${widget.surahName}',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Range input
          Row(
            children: [
              // Start verse
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'من الآية',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<int>(
                        value: startVerse,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: List.generate(
                          widget.maxVerses,
                          (i) {
                            final value = i + 1;
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(ArabicNumbers.toArabicDigits(value)),
                            );
                          },
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              startVerse = value;
                              if (endVerse < startVerse) {
                                endVerse = startVerse;
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // End verse
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إلى الآية',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<int>(
                        value: endVerse,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: List.generate(
                          widget.maxVerses - startVerse + 1,
                          (i) {
                            final value = startVerse + i;
                            // Ensure we don't exceed max verses
                            if (value <= widget.maxVerses) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(ArabicNumbers.toArabicDigits(value)),
                              );
                            }
                            return null;
                          },
                        ).where((item) => item != null).cast<DropdownMenuItem<int>>().toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              endVerse = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Number of verses
          Text(
            'عدد الآيات: ${ArabicNumbers.toArabicDigits(endVerse - startVerse + 1)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'إلغاء',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => widget.onAdd(startVerse, endVerse),
          child: Text(
            'إضافة',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
