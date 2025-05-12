import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:kottab/providers/quran_provider.dart';
import 'package:kottab/widgets/surahs/surah_card.dart';
import '../config/app_colors.dart';

class SurahsScreen extends StatefulWidget {
  const SurahsScreen({super.key});

  @override
  State<SurahsScreen> createState() => _SurahsScreenState();
}

class _SurahsScreenState extends State<SurahsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuranProvider>(context, listen: false).refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<QuranProvider>(
        builder: (context, quranProvider, child) {
          if (quranProvider.isLoading) {
            return _buildLoadingState();
          }

          if (quranProvider.surahs.isEmpty) {
            return _buildEmptyState();
          }

          return _buildSurahsList(quranProvider);
        },
      ),
    );
  }

  /// Build the loading state UI
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Build the empty state UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<QuranProvider>(context, listen: false).refreshData();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  /// Build the surahs list UI
  Widget _buildSurahsList(QuranProvider quranProvider) {
    return RefreshIndicator(
      onRefresh: () => quranProvider.refreshData(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          itemCount: quranProvider.surahs.length,
          itemBuilder: (context, index) {
            final surah = quranProvider.surahs[index];
            final isExpanded = quranProvider.expandedSurahId == surah.id;

            return SurahCard(
              surah: surah,
              isExpanded: isExpanded,
              onToggle: (surahId) {
                quranProvider.toggleSurahExpanded(surahId);
              },
              onAddVerseSet: (surahId, startVerse, endVerse) {
                quranProvider.addVerseSet(
                  surahId: surahId,
                  startVerse: startVerse,
                  endVerse: endVerse,
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Show a dialog to record a review
  void _showReviewDialog(BuildContext context, VerseSet verseSet, String surahName) {
    double quality = 0.8;
    String notes = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تسجيل مراجعة',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$surahName ${verseSet.rangeText}',
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Quality slider
            Text(
              'جودة المراجعة',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Slider(
                      value: quality,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(quality * 100).round()}%',
                      onChanged: (value) {
                        setState(() {
                          quality = value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ضعيف',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'ممتاز',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Notes field
            TextField(
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
              onChanged: (value) {
                notes = value;
              },
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
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<QuranProvider>(context, listen: false).recordReview(
                surahId: verseSet.surahId,
                startVerse: verseSet.startVerse,
                endVerse: verseSet.endVerse,
                quality: quality,
                notes: notes,
              );
            },
            child: Text(
              'حفظ',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}