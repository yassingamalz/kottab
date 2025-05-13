import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';

class SearchHistory extends StatelessWidget {
  final List<String> searchHistory;
  final Function(String) onItemTap;
  final Function(String) onItemRemove;
  final VoidCallback onClearAll;

  const SearchHistory({
    super.key,
    required this.searchHistory,
    required this.onItemTap,
    required this.onItemRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (searchHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'لا يوجد سجل بحث',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with clear button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل البحث',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  'مسح الكل',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search history list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searchHistory.length,
          itemBuilder: (context, index) {
            final item = searchHistory[index];

            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(
                item,
                textDirection: TextDirection.rtl,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onItemRemove(item),
              ),
              onTap: () => onItemTap(item),
            );
          },
        ),
      ],
    );
  }
}