import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/providers/search_provider.dart';
import 'package:kottab/widgets/search/search_bar.dart';
import 'package:kottab/widgets/search/search_history.dart';
import 'package:kottab/widgets/search/search_results.dart';
import 'package:kottab/widgets/shared/custom_snackbar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    // Reset search when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchProvider>(context, listen: false).clearSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                return SearchBarWidget(
                  initialQuery: searchProvider.currentQuery,
                  onSearch: (query) {
                    searchProvider.search(query);
                  },
                  onClear: () {
                    searchProvider.clearSearch();
                  },
                );
              },
            ),

            // Search content
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, searchProvider, child) {
                  // Show loading indicator
                  if (searchProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Show search results if we have a query
                  if (searchProvider.currentQuery.isNotEmpty) {
                    return SingleChildScrollView(
                      child: SearchResults(
                        results: searchProvider.searchResults,
                        query: searchProvider.currentQuery,
                        onResultTap: (result) {
                          _handleResultTap(context, result);
                        },
                      ),
                    );
                  }

                  // Show search history if no query
                  return SingleChildScrollView(
                    child: SearchHistory(
                      searchHistory: searchProvider.searchHistory,
                      onItemTap: (query) {
                        searchProvider.search(query);
                      },
                      onItemRemove: (query) {
                        searchProvider.removeFromHistory(query);
                      },
                      onClearAll: () {
                        searchProvider.clearSearchHistory();

                        // Show confirmation
                        showCustomSnackBar(
                          context: context,
                          message: 'تم مسح سجل البحث',
                          type: SnackBarType.info,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle tapping on a search result
  void _handleResultTap(BuildContext context, SearchResult result) {
    // In a real app, we would navigate to the appropriate screen
    // For now, just show a snackbar

    String message;

    switch (result.type) {
      case SearchResultType.surah:
        message = 'تم اختيار سورة ${result.surahName}';
        break;
      case SearchResultType.verseSet:
        message = 'تم اختيار ${result.surahName} ${result.startVerse}-${result.endVerse}';
        break;
      case SearchResultType.activity:
        message = 'تم اختيار نشاط: ${result.matchText}';
        break;
    }

    showCustomSnackBar(
      context: context,
      message: message,
      type: SnackBarType.info,
    );

    // Close the search screen
    // In a real app, we would navigate to the appropriate screen instead
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.of(context).pop();
    });
  }
}