import 'package:flutter/foundation.dart';
import 'package:kottab/models/surah_model.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:kottab/services/memorization_service.dart';

/// Model for a search result
class SearchResult {
  final int surahId;
  final String surahName;
  final int? startVerse;
  final int? endVerse;
  final MemorizationStatus? status;
  final String matchText;
  final SearchResultType type;

  const SearchResult({
    required this.surahId,
    required this.surahName,
    this.startVerse,
    this.endVerse,
    this.status,
    required this.matchText,
    required this.type,
  });

  /// Get a formatted display text for the result
  String get displayText {
    switch (type) {
      case SearchResultType.surah:
        return surahName;
      case SearchResultType.verseSet:
        return '$surahName ${startVerse?.toString() ?? ''}-${endVerse?.toString() ?? ''}';
      case SearchResultType.activity:
        return matchText;
    }
  }
}

/// Type of search result
enum SearchResultType {
  surah,
  verseSet,
  activity,
}

/// Provider to manage search functionality
class SearchProvider extends ChangeNotifier {
  final MemorizationService _memorizationService = MemorizationService();

  List<String> _searchHistory = [];
  List<Surah> _allSurahs = [];
  List<SearchResult> _searchResults = [];
  bool _isLoading = true;
  String _currentQuery = '';

  SearchProvider() {
    _loadData();
  }

  /// Initialize by loading data
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSurahs = await _memorizationService.getSurahsWithProgress();

      // TODO: Load search history from SharedPreferences
      _searchHistory = [
        'البقرة',
        'الفاتحة',
        'آية الكرسي',
        'مراجعة',
      ];
    } catch (e) {
      print('Error loading search data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh search data
  Future<void> refreshData() async {
    await _loadData();
  }

  /// Get search history
  List<String> get searchHistory => _searchHistory;

  /// Get search results
  List<SearchResult> get searchResults => _searchResults;

  /// Get current query
  String get currentQuery => _currentQuery;

  /// Check if data is still loading
  bool get isLoading => _isLoading;

  /// Search for the given query
  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _currentQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      // Add to search history if not already there
      if (!_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);

        // Limit history to 10 items
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.sublist(0, 10);
        }

        // TODO: Save search history to SharedPreferences
      }

      // Perform search
      _searchResults = await _performSearch(query);
    } catch (e) {
      print('Error performing search: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    _currentQuery = '';
    notifyListeners();
  }

  /// Clear search history
  void clearSearchHistory() {
    _searchHistory = [];
    // TODO: Clear search history in SharedPreferences
    notifyListeners();
  }

  /// Remove an item from search history
  void removeFromHistory(String query) {
    _searchHistory.remove(query);
    // TODO: Update search history in SharedPreferences
    notifyListeners();
  }

  /// Perform the actual search
  Future<List<SearchResult>> _performSearch(String query) async {
    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();

    // Search in surahs
    for (final surah in _allSurahs) {
      // Match surah name
      if (surah.name.toLowerCase().contains(lowerQuery) ||
          surah.arabicName.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          surahId: surah.id,
          surahName: surah.arabicName,
          matchText: surah.arabicName,
          type: SearchResultType.surah,
        ));
      }

      // Match verse sets
      for (final verseSet in surah.verseSets) {
        // Match by verse range or status
        if (verseSet.rangeText.contains(lowerQuery) ||
            _getStatusText(verseSet.status).contains(lowerQuery)) {
          results.add(SearchResult(
            surahId: surah.id,
            surahName: surah.arabicName,
            startVerse: verseSet.startVerse,
            endVerse: verseSet.endVerse,
            status: verseSet.status,
            matchText: '${surah.arabicName} ${verseSet.rangeText}',
            type: SearchResultType.verseSet,
          ));
        }
      }
    }

    // TODO: In a real app, we would also search in activity history
    // For now, just add some sample results if the query matches certain keywords
    if ('مراجعة'.contains(lowerQuery)) {
      results.add(const SearchResult(
        surahId: 2,
        surahName: 'البقرة',
        startVerse: 1,
        endVerse: 5,
        matchText: 'مراجعة البقرة 1-5',
        type: SearchResultType.activity,
      ));
    }

    if ('حفظ'.contains(lowerQuery)) {
      results.add(const SearchResult(
        surahId: 1,
        surahName: 'الفاتحة',
        startVerse: 1,
        endVerse: 7,
        matchText: 'حفظ الفاتحة 1-7',
        type: SearchResultType.activity,
      ));
    }

    return results;
  }

  /// Get status text from MemorizationStatus
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
}