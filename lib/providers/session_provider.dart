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
      if (_recentSessions.isEmpty && memorizedSets.isNotEmpty) {
        _recentSessions = _createSampleSessionsFromIds(memorizedSets);
      } else if (_recentSessions.isEmpty) {
        _recentSessions = _createSampleSessions();
      }
      
      _dataInitialized = true;
    } catch (e) {
      print('Error loading session data: $e');
      // Create empty lists to avoid null errors
      _surahs = [];
      _recentSessions = [];
      _dueSets = [];
      
      // Try to initialize with default data
      if (_surahs.isEmpty) {
        _surahs = [
          const Surah(
            id: 1,
            name: "Al-Fatihah",
            arabicName: "الفاتحة",
            verseCount: 7,
          ),
          const Surah(
            id: 2,
            name: "Al-Baqarah",
            arabicName: "البقرة",
            verseCount: 286,
          ),
        ];
      }
      
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
      // For new memorization, find first non-memorized set
      if (surah != null && surah.verseSets.isNotEmpty) {
        // Try to find a due set first
        VerseSet? dueSet = _dueSets.firstWhere(
          (set) => set.surahId == surahId && set.status == MemorizationStatus.notStarted,
          orElse: () => null as VerseSet,
        );
        
        if (dueSet != null) {
          startVerse = dueSet.startVerse;
          endVerse = dueSet.endVerse;
        } else {
          // Otherwise find first non-memorized set
          try {
            final notStartedSet = surah.verseSets.firstWhere(
                  (set) => set.status == MemorizationStatus.notStarted,
            );
            startVerse = notStartedSet.startVerse;
            endVerse = notStartedSet.endVerse;
          } catch (e) {
            // No not-started sets found, try to find the last set
            if (surah.verseSets.isNotEmpty) {
              final lastSet = surah.verseSets.reduce(
                    (a, b) => a.endVerse > b.endVerse ? a : b,
              );
              // Start after the last verse
              startVerse = lastSet.endVerse + 1;
              
              // Calculate end verse while respecting surah boundaries
              // Apply the SM-2 rule: don't cross surah boundaries, and limit to verse count setting
              final verseCount = dailyVerseTarget;
              endVerse = Math.min(startVerse + verseCount - 1, surah.verseCount);
              
              // If startVerse is already past the surah's verse count,
              // reset to verse 1 (this can happen with completed surahs)
              if (startVerse > surah.verseCount) {
                startVerse = 1;
                endVerse = Math.min(startVerse + verseCount - 1, surah.verseCount);
              }
            }
          }
        }
      }
    } else {
      // For reviews, find a due verse set
      VerseSet? dueSet;
      
      if (type == SessionType.recentReview) {
        // Find recent review due sets (repetition count <= 2)
        dueSet = _dueSets.firstWhere(
          (set) => set.surahId == surahId && 
                  set.status != MemorizationStatus.notStarted && 
                  set.repetitionCount <= 2,
          orElse: () => null as VerseSet,
        );
      } else {
        // Find old review due sets (repetition count > 2)
        dueSet = _dueSets.firstWhere(
          (set) => set.surahId == surahId && 
                  set.status != MemorizationStatus.notStarted && 
                  set.repetitionCount > 2,
          orElse: () => null as VerseSet,
        );
      }
      
      if (dueSet != null) {
        startVerse = dueSet.startVerse;
        endVerse = dueSet.endVerse;
      } else if (surah != null && surah.verseSets.isNotEmpty) {
        // If no due sets found, use any verse set with appropriate status
        try {
          VerseSet? matchingSet;
          if (type == SessionType.recentReview) {
            matchingSet = surah.verseSets.firstWhere(
                  (set) => set.status == MemorizationStatus.inProgress,
            );
          } else {
            matchingSet = surah.verseSets.firstWhere(
                  (set) => set.status == MemorizationStatus.memorized,
            );
          }
          
          if (matchingSet != null) {
            startVerse = matchingSet.startVerse;
            endVerse = matchingSet.endVerse;
          }
        } catch (e) {
          // Use default values if no matching sets found
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
      VerseSet? notStartedSet;
      try {
        notStartedSet = surah.verseSets.firstWhere(
              (set) => set.status == MemorizationStatus.notStarted,
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
      VerseSet? reviewSet;
      if (_currentSession!.type == SessionType.recentReview) {
        try {
          reviewSet = surah.verseSets.firstWhere(
                (set) => set.status == MemorizationStatus.inProgress,
          );
        } catch (e) {
          reviewSet = null;
        }
      } else { // Old review
        try {
          reviewSet = surah.verseSets.firstWhere(
                (set) => set.status == MemorizationStatus.memorized,
          );
        } catch (e) {
          reviewSet = null;
        }
      }
      
      if (reviewSet != null) {
        startVerse = reviewSet.startVerse;
        endVerse = reviewSet.endVerse;
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

  /// Save the current session and record it
  Future<bool> saveCurrentSession() async {
    if (_currentSession == null) return false;

    try {
      // Record the session in the memorization service
      final success = await _memorizationService.recordMemorizationSession(
        surahId: _currentSession!.surahId,
        startVerse: _currentSession!.startVerse,
        endVerse: _currentSession!.endVerse,
        quality: _currentSession!.quality,
        notes: _currentSession!.notes,
      );

      if (success) {
        // Add to recent sessions
        _recentSessions.insert(0, _currentSession!);

        // Update the statistics provider - force refresh all providers
        await _memorizationService.refreshStatistics();
        
        // Clear current session
        _currentSession = null;

        // Reload data to get updated Surahs and due sets
        await refreshData();
      }

      return success;
    } catch (e) {
      print('Error saving session: $e');
      return false;
    }
  }

  /// Create sample sessions from memorized set IDs
  List<MemorizationSession> _createSampleSessionsFromIds(List<String> memorizedSetIds) {
    final sessions = <MemorizationSession>[];
    final now = DateTime.now();
    
    for (final id in memorizedSetIds.take(3)) {
      try {
        final parts = id.split(':');
        if (parts.length != 2) continue;
        
        final surahId = int.parse(parts[0]);
        final verseParts = parts[1].split('-');
        if (verseParts.length != 2) continue;
        
        final startVerse = int.parse(verseParts[0]);
        final endVerse = int.parse(verseParts[1]);
        
        // Find surah name
        String surahName = "سورة $surahId";
        try {
          final surah = _surahs.firstWhere((s) => s.id == surahId);
          surahName = surah.arabicName;
        } catch (e) {
          // Use default name
        }
        
        sessions.add(MemorizationSession(
          surahId: surahId,
          surahName: surahName,
          startVerse: startVerse,
          endVerse: endVerse,
          timestamp: now.subtract(Duration(days: sessions.length)),
          type: SessionType.newMemorization,
          quality: 0.9,
          notes: 'تم الحفظ بنجاح',
        ));
      } catch (e) {
        print('Error parsing memorized set ID: $id');
      }
    }
    
    return sessions;
  }

  /// Create sample sessions for demonstration
  List<MemorizationSession> _createSampleSessions() {
    final now = DateTime.now();

    return [
      MemorizationSession(
        surahId: 2,
        surahName: 'البقرة',
        startVerse: 1,
        endVerse: 5,
        timestamp: now.subtract(const Duration(hours: 2)),
        type: SessionType.newMemorization,
        quality: 0.9,
        notes: 'آيات سهلة للحفظ',
      ),
      MemorizationSession(
        surahId: 1,
        surahName: 'الفاتحة',
        startVerse: 1,
        endVerse: 7,
        timestamp: now.subtract(const Duration(days: 1)),
        type: SessionType.recentReview,
        quality: 1.0,
        notes: 'مراجعة ممتازة',
      ),
      MemorizationSession(
        surahId: 2,
        surahName: 'البقرة',
        startVerse: 6,
        endVerse: 10,
        timestamp: now.subtract(const Duration(days: 2)),
        type: SessionType.newMemorization,
        quality: 0.7,
        notes: 'تحتاج إلى مزيد من المراجعة',
      ),
    ];
  }
}

// Helper class for Math methods
class Math {
  static int min(int a, int b) => a < b ? a : b;
  static int max(int a, int b) => a > b ? a : b;
}
