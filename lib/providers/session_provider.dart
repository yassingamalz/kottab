import "package:flutter/material.dart";
import 'package:flutter/foundation.dart';
import 'package:kottab/models/surah_model.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:kottab/services/memorization_service.dart';

/// Model for a memorization session
class MemorizationSession {
  final int surahId;
  final String surahName;
  final int startVerse;
  final int endVerse;
  final DateTime timestamp;
  final SessionType type;
  final double quality;
  final String notes;

  const MemorizationSession({
    required this.surahId,
    required this.surahName,
    required this.startVerse,
    required this.endVerse,
    required this.timestamp,
    required this.type,
    required this.quality,
    this.notes = '',
  });

  /// Get the verse range as a formatted string
  String get verseRange => '$startVerse-$endVerse';

  /// Get the number of verses in this session
  int get verseCount => endVerse - startVerse + 1;

  /// Clone this session with updated fields
  MemorizationSession copyWith({
    int? surahId,
    String? surahName,
    int? startVerse,
    int? endVerse,
    DateTime? timestamp,
    SessionType? type,
    double? quality,
    String? notes,
  }) {
    return MemorizationSession(
      surahId: surahId ?? this.surahId,
      surahName: surahName ?? this.surahName,
      startVerse: startVerse ?? this.startVerse,
      endVerse: endVerse ?? this.endVerse,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
    );
  }
}

/// Type of memorization session
enum SessionType {
  newMemorization,
  recentReview,
  oldReview,
}

/// Provider to manage memorization sessions
class SessionProvider extends ChangeNotifier {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final MemorizationService _memorizationService = MemorizationService();

  List<MemorizationSession> _recentSessions = [];
  List<Surah> _surahs = [];
  List<VerseSet> _dueSets = [];
  bool _isLoading = true;
  bool _dataInitialized = false;

  /// The current session being edited (null if not editing)
  MemorizationSession? _currentSession;

  SessionProvider() {
    _loadData();
  }

  /// Initialize by loading data
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load surahs for session creation
      _surahs = await _memorizationService.getSurahsWithProgress();
      
      // Load verse sets due for today
      _dueSets = await _memorizationService.getDueVerseSets();

      // In a real app, we would load recent sessions from storage
      // For now, try to load from the service if available
      final List<String> memorizedSets = await _memorizationService.getAllMemorizedSetIds();
      
      _dataInitialized = true;
    } catch (e) {
      print('Error loading session data: $e');
      // Create empty lists to avoid null errors
      _surahs = [];
      _recentSessions = [];
      _dueSets = [];
      
      _dataInitialized = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh the session data
  Future<void> refreshData() async {
    await _loadData();
  }

  /// Get recent sessions
  List<MemorizationSession> get recentSessions => _recentSessions;

  /// Get available surahs
  List<Surah> get surahs => _surahs;
  
  /// Get verse sets due for today
  List<VerseSet> get dueSets => _dueSets;

  /// Get the current session being edited
  MemorizationSession? get currentSession => _currentSession;

  /// Check if data is still loading
  bool get isLoading => _isLoading;

  /// Start a new session with default values
  void startNewSession({
    int surahId = 1,
    SessionType type = SessionType.newMemorization,
  }) {
    // If data not initialized, load it first
    if (!_dataInitialized || _surahs.isEmpty) {
      _loadData().then((_) {
        startNewSession(surahId: surahId, type: type);
      });
      return;
    }

    // Find the surah
    Surah? surah;
    try {
      surah = _surahs.firstWhere((s) => s.id == surahId);
    } catch (e) {
      // If surah not found, use the first available
      if (_surahs.isNotEmpty) {
        surah = _surahs.first;
      } else {
        // Create a fallback surah
        surah = const Surah(
          id: 1,
          name: "Al-Fatihah",
          arabicName: "الفاتحة",
          verseCount: 7,
        );
      }
    }

    // Find the next verse range to memorize based on session type and due sets
    int startVerse = 1;
    int endVerse = 5;
    
    if (type == SessionType.newMemorization) {
      // Always start with Al-Fatiha if not memorized yet
      bool alFatihaMemorized = false;
      if (_surahs.isNotEmpty) {
        final fatiha = _surahs.firstWhere((s) => s.id == 1, orElse: () => null as Surah);
        if (fatiha != null) {
          alFatihaMemorized = fatiha.verseSets.every((set) => set.status == MemorizationStatus.memorized);
        }
      }
      
      // If not memorized Al-Fatiha yet and trying to memorize another surah, force Al-Fatiha
      if (!alFatihaMemorized && surahId > 1) {
        surahId = 1;
        surah = _surahs.firstWhere((s) => s.id == 1, orElse: () => 
          const Surah(id: 1, name: "Al-Fatihah", arabicName: "الفاتحة", verseCount: 7)
        );
      }
      
      // For new memorization, find first non-memorized set
      if (surah != null && surah.verseSets.isNotEmpty) {
        // Try to find a not started set first
        VerseSet? notStartedSet;
        try {
          notStartedSet = surah.verseSets.firstWhere(
            (set) => set.status == MemorizationStatus.notStarted
          );
          startVerse = notStartedSet.startVerse;
          endVerse = notStartedSet.endVerse;
        } catch (e) {
          // No not-started sets found, try to find sets in progress
          try {
            final inProgressSet = surah.verseSets.firstWhere(
              (set) => set.status == MemorizationStatus.inProgress
            );
            startVerse = inProgressSet.startVerse;
            endVerse = inProgressSet.endVerse;
          } catch (e) {
            // No sets found, use defaults starting at verse 1
            startVerse = 1;
            endVerse = Math.min(startVerse + dailyVerseTarget - 1, surah.verseCount);
          }
        }
      }
    } else {
      // For reviews, find verse sets with status != notStarted
      if (surah != null && surah.verseSets.isNotEmpty) {
        List<VerseSet> reviewableSets = surah.verseSets.where(
          (set) => set.status != MemorizationStatus.notStarted
        ).toList();
        
        if (reviewableSets.isNotEmpty) {
          // For recent review, sort by repetition count and last review date
          if (type == SessionType.recentReview) {
            reviewableSets.sort((a, b) {
              // Sort by repetition count first (ascending)
              if (a.repetitionCount != b.repetitionCount) {
                return a.repetitionCount.compareTo(b.repetitionCount);
              }
              // Then by last review date (most recent first)
              if (a.lastReviewDate != null && b.lastReviewDate != null) {
                return b.lastReviewDate!.compareTo(a.lastReviewDate!);
              }
              return 0;
            });
          } else {
            // For old review, sort by repetition count (descending)
            reviewableSets.sort((a, b) => b.repetitionCount.compareTo(a.repetitionCount));
          }
          
          // Use the first set after sorting
          VerseSet setToReview = reviewableSets.first;
          startVerse = setToReview.startVerse;
          endVerse = setToReview.endVerse;
        } else {
          // Default with surah boundary check
          startVerse = 1;
          endVerse = Math.min(startVerse + 4, surah.verseCount);
        }
      }
    }

    // Create a new session with valid parameters
    _currentSession = MemorizationSession(
      surahId: surah?.id ?? 1,
      surahName: surah?.arabicName ?? "الفاتحة",
      startVerse: startVerse > 0 ? startVerse : 1,
      endVerse: endVerse > 0 ? endVerse : (startVerse + 4),
      timestamp: DateTime.now(),
      type: type,
      quality: 0.8, // Default to 80%
    );

    notifyListeners();
  }

  /// Get the default number of verses to memorize daily
  int get dailyVerseTarget {
    if (_settings.containsKey('dailyVerseTarget')) {
      return _settings['dailyVerseTarget'];
    }
    return 10; // Default value
  }
  
  /// User settings
  Map<String, dynamic> _settings = {};

  /// Update the current session surah
  void updateSessionSurah(int surahId) {
    if (_currentSession == null) return;

    // Always check if Al-Fatiha is memorized before allowing other surahs
    if (_currentSession!.type == SessionType.newMemorization && surahId > 1) {
      bool alFatihaMemorized = false;
      if (_surahs.isNotEmpty) {
        try {
          final fatiha = _surahs.firstWhere((s) => s.id == 1);
          alFatihaMemorized = fatiha.verseSets.every((set) => set.status == MemorizationStatus.memorized);
        } catch (e) {
          // Fatiha not found
          alFatihaMemorized = false;
        }
      }
      
      // If Al-Fatiha not memorized, force it
      if (!alFatihaMemorized) {
        surahId = 1;
      }
    }

    // Find the surah
    Surah? surah;
    try {
      surah = _surahs.firstWhere((s) => s.id == surahId);
    } catch (e) {
      print('Surah not found: $surahId');
      
      // Try to find any surah as fallback
      if (_surahs.isNotEmpty) {
        surah = _surahs.first;
      } else {
        // Create a fallback surah if list is empty
        surah = const Surah(
          id: 1,
          name: "Al-Fatihah", 
          arabicName: "الفاتحة",
          verseCount: 7,
        );
      }
    }

    if (surah == null) return;

    // Calculate verse range based on the surah boundaries and session type
    int startVerse, endVerse;
    
    if (_currentSession!.type == SessionType.newMemorization) {
      // For new memorization, find the first non-memorized verse set
      try {
        final notStartedSet = surah.verseSets.firstWhere(
          (set) => set.status == MemorizationStatus.notStarted
        );
        startVerse = notStartedSet.startVerse;
        endVerse = notStartedSet.endVerse;
      } catch (e) {
        // If no not-started sets, use defaults with surah boundary check
        startVerse = 1;
        endVerse = Math.min(startVerse + dailyVerseTarget - 1, surah.verseCount);
      }
    } else {
      // For reviews, try to find appropriate verse sets
      List<VerseSet> reviewableSets = surah.verseSets.where(
        (set) => set.status != MemorizationStatus.notStarted
      ).toList();
      
      if (reviewableSets.isNotEmpty) {
        // For recent review, sort by repetition count and last review date
        if (_currentSession!.type == SessionType.recentReview) {
          reviewableSets.sort((a, b) {
            // Sort by repetition count first (ascending)
            if (a.repetitionCount != b.repetitionCount) {
              return a.repetitionCount.compareTo(b.repetitionCount);
            }
            // Then by last review date (most recent first)
            if (a.lastReviewDate != null && b.lastReviewDate != null) {
              return b.lastReviewDate!.compareTo(a.lastReviewDate!);
            }
            return 0;
          });
        } else {
          // For old review, sort by repetition count (descending)
          reviewableSets.sort((a, b) => b.repetitionCount.compareTo(a.repetitionCount));
        }
        
        // Use the first set after sorting
        VerseSet setToReview = reviewableSets.first;
        startVerse = setToReview.startVerse;
        endVerse = setToReview.endVerse;
      } else {
        // Default with surah boundary check
        startVerse = 1;
        endVerse = Math.min(startVerse + 4, surah.verseCount);
      }
    }

    // Update the current session
    _currentSession = _currentSession!.copyWith(
      surahId: surah.id,
      surahName: surah.arabicName,
      startVerse: startVerse,
      endVerse: endVerse,
    );

    notifyListeners();
  }

  /// Update the current session type
  void updateSessionType(SessionType type) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(type: type);
    notifyListeners();
  }

  /// Update the current session verse range with surah boundary check
  void updateSessionVerseRange(int startVerse, int endVerse) {
    if (_currentSession == null) return;

    // Find the surah to validate verse range
    Surah? surah;
    try {
      surah = _surahs.firstWhere((s) => s.id == _currentSession!.surahId);
    } catch (e) {
      print('Surah not found for validation: ${_currentSession!.surahId}');
      
      // Create default surah if not found
      surah = Surah(
        id: _currentSession!.surahId,
        name: "Surah ${_currentSession!.surahId}",
        arabicName: "سورة ${_currentSession!.surahId}",
        verseCount: Math.max(endVerse, 100),  // Assume at least endVerse length
      );
    }
    
    // Validate the verse range
    if (startVerse < 1) startVerse = 1;
    if (endVerse < startVerse) endVerse = startVerse;
    if (surah != null && endVerse > surah.verseCount) {
      endVerse = surah.verseCount;
    }

    // Update the current session with validated values
    _currentSession = _currentSession!.copyWith(
      startVerse: startVerse,
      endVerse: endVerse,
    );

    notifyListeners();
  }

  /// Update the current session quality
  void updateSessionQuality(double quality) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(quality: quality);
    notifyListeners();
  }

  /// Update the current session notes
  void updateSessionNotes(String notes) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(notes: notes);
    notifyListeners();
  }

  /// Clear the current session
  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }

  /// Save the current session and record it - IMPROVED to ensure UI updates
  Future<bool> saveCurrentSession() async {
    if (_currentSession == null) return false;

    try {
      // Store the current session data before clearing it
      final sessionToSave = _currentSession!;
      
      // Record the session in the memorization service
      final success = await _memorizationService.recordMemorizationSession(
        surahId: sessionToSave.surahId,
        startVerse: sessionToSave.startVerse,
        endVerse: sessionToSave.endVerse,
        quality: sessionToSave.quality,
        notes: sessionToSave.notes,
      );

      if (success) {
        // Add to recent sessions
        _recentSessions.insert(0, sessionToSave);

        // Clear current session first to avoid state issues
        _currentSession = null;

        // Update the statistics provider - force refresh all providers
        await _memorizationService.refreshStatistics();
        
        // Explicitly reload surahs with updated progress
        _surahs = await _memorizationService.getSurahsWithProgress();
        
        // Get an updated list of due verse sets
        _dueSets = await _memorizationService.getDueVerseSets();

        // Log for debugging
        print("SessionProvider: Session saved successfully - reloaded Surahs and due sets");
        if (_surahs.isNotEmpty) {
          final fatiha = _surahs.firstWhere((s) => s.id == 1, orElse: () => null as Surah);
          if (fatiha != null) {
            print("Al-Fatiha progress: ${fatiha.memorizedPercentage * 100}%");
          }
        }

        // Force notify listeners to ensure all UI is updated
        notifyListeners();
        
        // Schedule another UI refresh after a short delay
        Future.delayed(Duration(milliseconds: 300), () {
          notifyListeners();
        });
      }

      return success;
    } catch (e) {
      print('Error saving session: $e');
      return false;
    }
  }
}

// Helper class for Math methods
class Math {
  static int min(int a, int b) => a < b ? a : b;
  static int max(int a, int b) => a > b ? a : b;
}
