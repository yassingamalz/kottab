import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:kottab/providers/search_provider.dart';

class SearchResults extends StatelessWidget {
  final List<SearchResult> results;
  final String query;
  final Function(SearchResult) onResultTap;

  const SearchResults({
    super.key,
    required this.results,
    required this.query,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return const SizedBox.shrink();
    }

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد نتائج لـ "$query"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'حاول البحث بكلمات مختلفة أو تحقق من الهجاء',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'نتائج البحث (${results.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        // Results list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];

            return ListTile(
              leading: _buildResultIcon(result),
              title: Text(
                result.displayText,
                textDirection: TextDirection.rtl,
              ),
              subtitle: result.type == SearchResultType.verseSet && result.status != null
                  ? Text(
                _getStatusText(result.status!),
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: _getStatusColor(result.status!),
                ),
              )
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onResultTap(result),
            );
          },
        ),
      ],
    );
  }

  /// Build the appropriate icon for the result
  Widget _buildResultIcon(SearchResult result) {
    switch (result.type) {
      case SearchResultType.surah:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              result.surahId.toString(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case SearchResultType.verseSet:
        Color bgColor;
        Color iconColor;

        switch (result.status) {
          case MemorizationStatus.memorized:
            bgColor = AppColors.primaryLight;
            iconColor = AppColors.primary;
            break;
          case MemorizationStatus.inProgress:
            bgColor = Colors.amber.shade100;
            iconColor = Colors.amber.shade700;
            break;
          case MemorizationStatus.notStarted:
          default:
            bgColor = Colors.grey.shade200;
            iconColor = Colors.grey.shade700;
            break;
        }

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.bookmark,
            color: iconColor,
          ),
        );
      case SearchResultType.activity:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.blueLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.history,
            color: AppColors.blue,
          ),
        );
    }
  }

  /// Get text for memorization status
  String _getStatusText(MemorizationStatus status) {
    switch (status) {
      case MemorizationStatus.memorized:
        return 'محفوظ';
      case MemorizationStatus.inProgress:
        return 'قيد الحفظ';
      case MemorizationStatus.notStarted:
        return 'لم يبدأ';
    }
  }

  /// Get color for memorization status
  Color _getStatusColor(MemorizationStatus status) {
    switch (status) {
      case MemorizationStatus.memorized:
        return AppColors.primary;
      case MemorizationStatus.inProgress:
        return Colors.amber.shade700;
      case MemorizationStatus.notStarted:
        return Colors.grey;
    }
  }
}