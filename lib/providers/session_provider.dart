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
  bool _isLoading = true;

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

      // TODO: In a real app, we would load recent sessions from storage
      // For now, create some sample data
      _recentSessions = _createSampleSessions();
    } catch (e) {
      print('Error loading session data: $e');
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

  /// Get the current session being edited
  MemorizationSession? get currentSession => _currentSession;

  /// Check if data is still loading
  bool get isLoading => _isLoading;

  /// Start a new session with default values
  void startNewSession({
    int surahId = 1,
    SessionType type = SessionType.newMemorization,
  }) {
    // Find the surah
    final surah = _surahs.firstWhere(
          (s) => s.id == surahId,
      orElse: () => _surahs.first,
    );

    // Find the next verse range to memorize
    int startVerse = 1;
    int endVerse = 5;

    if (surah.verseSets.isNotEmpty) {
      // Find first non-memorized set or use the last set + 1
      final notStartedSet = surah.verseSets.firstWhere(
            (set) => set.status == MemorizationStatus.notStarted,
        orElse: () => surah.verseSets.last,
      );

      if (notStartedSet.status == MemorizationStatus.notStarted) {
        startVerse = notStartedSet.startVerse;
        endVerse = notStartedSet.endVerse;
      } else {
        // Start after the last verse
        startVerse = notStartedSet.endVerse + 1;
        endVerse = startVerse + 4; // Default to 5 verses

        // Make sure we don't exceed the surah's verse count
        if (endVerse > surah.verseCount) {
          endVerse = surah.verseCount;
        }
      }
    }

    // Create a new session
    _currentSession = MemorizationSession(
      surahId: surah.id,
      surahName: surah.arabicName,
      startVerse: startVerse,
      endVerse: endVerse,
      timestamp: DateTime.now(),
      type: type,
      quality: 0.8, // Default to 80%
    );

    notifyListeners();
  }

  /// Update the current session surah
  void updateSessionSurah(int surahId) {
    if (_currentSession == null) return;

    // Find the surah
    final surah = _surahs.firstWhere(
          (s) => s.id == surahId,
      orElse: () => _surahs.first,
    );

    // Update the current session
    _currentSession = _currentSession!.copyWith(
      surahId: surah.id,
      surahName: surah.arabicName,
    );

    notifyListeners();
  }

  /// Update the current session type
  void updateSessionType(SessionType type) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(type: type);
    notifyListeners();
  }

  /// Update the current session verse range
  void updateSessionVerseRange(int startVerse, int endVerse) {
    if (_currentSession == null) return;

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

        // Clear current session
        _currentSession = null;

        notifyListeners();
      }

      return success;
    } catch (e) {
      print('Error saving session: $e');
      return false;
    }
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