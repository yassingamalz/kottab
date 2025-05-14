import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/providers/quran_provider.dart';
import 'package:kottab/widgets/surahs/surah_card.dart';
import '../config/app_colors.dart';

class SurahsScreen extends StatefulWidget {
  const SurahsScreen({super.key});

  @override
  State<SurahsScreen> createState() => _SurahsScreenState();
}

class _SurahsScreenState extends State<SurahsScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Initialize data when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuranProvider>(context, listen: false).refreshData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  /// Build the surahs list UI with improved performance
  Widget _buildSurahsList(QuranProvider quranProvider) {
    return RefreshIndicator(
      onRefresh: () => quranProvider.refreshData(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: quranProvider.surahs.length,
          // Reduce cacheExtent for better performance with large lists
          cacheExtent: 300,
          itemBuilder: (context, index) {
            final surah = quranProvider.surahs[index];
            final isExpanded = quranProvider.expandedSurahId == surah.id;

            return SurahCard(
              surah: surah,
              isExpanded: isExpanded,
              onToggle: (surahId) {
                quranProvider.toggleSurahExpanded(surahId);
                
                // Use simpler scrolling logic when expanding
                if (!isExpanded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final context = _scrollController.position.context.notificationContext;
                    if (context != null) {
                      final renderObject = context.findRenderObject();
                      if (renderObject != null) {
                        _scrollController.position.ensureVisible(
                          renderObject,
                          alignment: 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }
}
