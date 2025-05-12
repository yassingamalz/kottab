import 'package:flutter/foundation.dart';
import 'package:kottab/data/quran_data.dart';
import 'package:kottab/models/surah_model.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:kottab/services/memorization_service.dart';

/// Provider to manage Quran data and memorization progress
class QuranProvider extends ChangeNotifier {
  final MemorizationService _memorizationService = MemorizationService();

  List<Surah> _surahs = [];
  bool _isLoading = true;
  int? _expandedSurahId;

  QuranProvider() {
    _initData();
  }

  /// Initialize data by loading surahs with their progress
  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _surahs = await _memorizationService.getSurahsWithProgress();
    } catch (e) {
      print('Error loading surahs: $e');
      // Fallback to static data if there's an error
      _surahs = QuranData.getAllSurahs();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh the data from services
  Future<void> refreshData() async {
    await _initData();
  }

  /// Get all surahs
  List<Surah> get surahs => _surahs;

  /// Check if data is still loading
  bool get isLoading => _isLoading;

  /// Get the currently expanded surah ID
  int? get expandedSurahId => _expandedSurahId;

  /// Toggle the expanded state of a surah
  void toggleSurahExpanded(int surahId) {
    if (_expandedSurahId == surahId) {
      _expandedSurahId = null;
    } else {
      _expandedSurahId = surahId;
    }
    notifyListeners();
  }

  /// Record a review for a verse set
  Future<bool> recordReview({
    required int surahId,
    required int startVerse,
    required int endVerse,
    required double quality,
    String notes = '',
  }) async {
    final success = await _memorizationService.recordMemorizationSession(
      surahId: surahId,
      startVerse: startVerse,
      endVerse: endVerse,
      quality: quality,
      notes: notes,
    );

    if (success) {
      await refreshData();
    }

    return success;
  }

  /// Add a new verse set to a surah
  Future<bool> addVerseSet({
    required int surahId,
    required int startVerse,
    required int endVerse,
  }) async {
    // Create a new verse set
    final verseSet = VerseSet.create(
      surahId: surahId,
      startVerse: startVerse,
      endVerse: endVerse,
    );

    // Find the surah and add the verse set
    final surahIndex = _surahs.indexWhere((surah) => surah.id == surahId);
    if (surahIndex == -1) return false;

    // Check if this range overlaps with existing sets
    final existingSets = _surahs[surahIndex].verseSets;
    for (final set in existingSets) {
      // Check if there's an overlap
      if ((startVerse >= set.startVerse && startVerse <= set.endVerse) ||
          (endVerse >= set.startVerse && endVerse <= set.endVerse) ||
          (startVerse <= set.startVerse && endVerse >= set.endVerse)) {
        return false; // Overlap detected
      }
    }

    // Update the surah with the new verse set
    final updatedSets = List<VerseSet>.from(existingSets)..add(verseSet);

    // Sort the sets by start verse
    updatedSets.sort((a, b) => a.startVerse.compareTo(b.startVerse));

    // Update the surah
    final updatedSurah = _surahs[surahIndex].copyWith(verseSets: updatedSets);
    _surahs[surahIndex] = updatedSurah;

    notifyListeners();
    return true;
  }
}