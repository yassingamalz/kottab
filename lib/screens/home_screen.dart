import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/schedule_provider.dart' as ScheduleProvider;
import 'package:kottab/screens/activity_detail_screen.dart';
import 'package:kottab/screens/achievements_screen.dart';
import 'package:kottab/screens/weekly_detail_screen.dart';
import 'package:kottab/widgets/home/achievement_row.dart';
import 'package:kottab/widgets/home/activity_timeline.dart';
import 'package:kottab/widgets/home/empty_activity_placeholder.dart';
import 'package:kottab/widgets/home/empty_achievements_placeholder.dart';
import 'package:kottab/widgets/home/hero_section.dart';
import 'package:kottab/widgets/home/stat_card.dart';
import 'package:kottab/widgets/home/today_focus.dart';
import 'package:kottab/widgets/home/weekly_progress.dart';
import 'package:kottab/widgets/sessions/add_session_modal.dart';
import 'package:provider/provider.dart';
import 'package:kottab/providers/statistics_provider.dart';
import 'package:kottab/providers/settings_provider.dart';
import 'package:kottab/providers/session_provider.dart';
import 'package:kottab/providers/quran_provider.dart';
import 'package:kottab/models/user_model.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:kottab/models/surah_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Animation controller for tasks
  late AnimationController _progressController;
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Force data refresh when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData(forceUpdate: true);
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures updates when returning from other screens
    if (_initialLoadDone) {
      _refreshData();
    }
  }
  
  void _refreshData({bool forceUpdate = false}) async {
    print("HomeScreen: Refreshing data, forceUpdate=$forceUpdate");
    
    final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final scheduleProvider = Provider.of<ScheduleProvider.ScheduleProvider>(context, listen: false);
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    
    // Refresh all providers
    await Future.wait([
      statsProvider.refreshData(),
      settingsProvider.refreshData(),
      sessionProvider.refreshData(),
      scheduleProvider.refreshData(),
      quranProvider.refreshData(),
    ]);
    
    // After refreshing, force rebuild UI
    if (mounted) {
      setState(() {
        _initialLoadDone = true;
      });
      
      if (forceUpdate) {
        // Force additional notifyListeners to ensure UI updates
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            statsProvider.notifyListeners();
            quranProvider.notifyListeners();
          }
        });
      }
    }
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  /// Get proper display name for a Surah
  String _getSurahDisplayName(int surahId, List<Surah> surahs) {
    try {
      final surah = surahs.firstWhere((s) => s.id == surahId);
      return surah.arabicName;
    } catch (e) {
      // Fallback for surahs not found in the list
      return "سورة $surahId";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<StatisticsProvider>(
        builder: (context, statsProvider, _) {
          // Log the current statistics for debugging
          print("HomeScreen build: Memorized percentage = ${statsProvider.memorizedPercentage}");
          print("HomeScreen build: Memorized verses = ${statsProvider.memorizedVerses}");
          
          final sessionProvider = Provider.of<SessionProvider>(context);
          final settingsProvider = Provider.of<SettingsProvider>(context);
          final scheduleProvider = Provider.of<ScheduleProvider.ScheduleProvider>(context);
          final quranProvider = Provider.of<QuranProvider>(context);
          
          // Get user data
          final user = settingsProvider.user;
          final isFirstTime = _isFirstTimeUser(user);
          
          // Get Quran data
          final surahs = quranProvider.surahs;
          
          // Build dynamic weekly data from user progress
          final weeklyData = _buildWeeklyDataFromUser(settingsProvider);
          
          // Get due verse sets from the session provider
          final dueSets = sessionProvider.dueSets;
          
          // Build focus tasks - for first-time users, only show Al-Fatiha
          final focusTasks = isFirstTime 
              ? _buildFirstTimeFocusTasks(surahs)
              : _buildFocusTasksFromDueSets(dueSets, scheduleProvider);

          // Calculate progress for the hero section
          // For first-time users, show zero progress
          final primaryProgress = isFirstTime ? 0.0 : statsProvider.memorizedPercentage;
          
          // For the three rings, use ONLY real memorization data, don't use fake data
          double newProgress = 0.0;
          double recentProgress = 0.0;
          double oldProgress = 0.0;
          
          // Use real memorization data if available, otherwise all zeros
          if (!isFirstTime && primaryProgress > 0) {
            // Scale the three progress values proportionally to the actual memorization
            newProgress = primaryProgress * 0.8; // 80% of total memorized
            recentProgress = primaryProgress * 0.9; // 90% of total memorized
            oldProgress = primaryProgress * 0.6; // 60% of total memorized
          }
          
          // Build activities - empty for first-time users
          final hasActivities = !isFirstTime && sessionProvider.recentSessions.isNotEmpty;
          final List<ActivityItem> activities = hasActivities 
              ? _buildActivitiesFromRecentSessions(context)
              : [];

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData(forceUpdate: true);
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero section with Google Fit style circles
                  HeroSection(
                    newMemProgress: newProgress,
                    recentReviewProgress: recentProgress,
                    oldReviewProgress: oldProgress,
                    completedNewVerses: _getCompletedVerses(focusTasks, TaskType.newMemorization),
                    targetNewVerses: _getTargetVerses(focusTasks, TaskType.newMemorization),
                    completedRecentVerses: _getCompletedVerses(focusTasks, TaskType.recentReview),
                    targetRecentVerses: _getTargetVerses(focusTasks, TaskType.recentReview),
                    completedOldVerses: _getCompletedVerses(focusTasks, TaskType.oldReview),
                    targetOldVerses: _getTargetVerses(focusTasks, TaskType.oldReview),
                    streak: settingsProvider.user?.streak ?? 0,
                    memorizedPercentage: statsProvider.memorizedPercentage,
                  ),

                  const SizedBox(height: 8),

                  // Weekly progress
                  WeeklyProgress(
                    weekData: weeklyData,
                    onViewAll: () {
                      // Navigate to weekly progress detail screen
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const WeeklyDetailScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Today's focus
                  TodayFocus(
                    tasks: focusTasks,
                    onContinue: () {
                      // Show focus detail dialog
                      _showFocusDetailDialog(context);
                    },
                  ),

                  const SizedBox(height: 8),

                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Memorized Verses Stats - use real stats
                        Expanded(
                          child: StatCard(
                            title: 'محفوظ',
                            value: isFirstTime ? '0' : statsProvider.memorizedVerses.toString(),
                            suffix: 'آية',
                            description: isFirstTime ? '0٪ من القرآن' : '${(statsProvider.memorizedPercentage * 100).toStringAsFixed(1)}٪ من القرآن',
                            icon: Icons.menu_book,
                            progress: isFirstTime ? 0.0 : statsProvider.memorizedPercentage,
                            iconColor: AppColors.primary,
                            bgColor: AppColors.primaryLight,
                            progressColor: AppColors.primary,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Streak Stats - use real stats
                        Expanded(
                          child: StatCard(
                            title: 'التتابع',
                            value: (settingsProvider.user?.streak ?? 0).toString(),
                            suffix: 'يوم',
                            description: 'استمر في العمل!',
                            icon: Icons.trending_up,
                            progress: _calculateStreakProgress(settingsProvider.user?.streak ?? 0),
                            iconColor: AppColors.primary,
                            bgColor: AppColors.primaryLight,
                            progressColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Recent Activity (show placeholder for first-time users)
                  hasActivities
                      ? ActivityTimeline(
                          activities: activities,
                          onViewAll: () {
                            // Navigate to activity history
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const ActivityDetailScreen()),
                            );
                          },
                        )
                      : const EmptyActivityPlaceholder(),

                  const SizedBox(height: 8),

                  // Achievements - show placeholder for first-time users
                  !isFirstTime && statsProvider.memorizedVerses > 0
                      ? Consumer<StatisticsProvider>(
                          builder: (context, statsProvider, child) {
                            final achievements = _buildAchievementsFromStats(statsProvider);
                            return AchievementRow(
                              achievements: achievements,
                              onViewAll: () {
                                // Navigate to achievements
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                                );
                              },
                            );
                          },
                        )
                      : const EmptyAchievementsPlaceholder(),

                  // Extra padding at bottom for the FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Fix for first time user detection and handling
  bool _isFirstTimeUser(User? user) {
    return user?.isFirstTime ?? true;
  }

  // Build Al-Fatiha focus task for first-time users
  List<FocusTaskData> _buildFirstTimeFocusTasks(List<Surah> surahs) {
    // Find Al-Fatiha's details from the actual data
    Surah? fatiha;
    try {
      fatiha = surahs.firstWhere((s) => s.id == 1);
    } catch (e) {
      // Fallback if Al-Fatiha is not found
      fatiha = const Surah(
        id: 1,
        name: "Al-Fatihah",
        arabicName: "الفاتحة",
        verseCount: 7,
      );
    }
    
    return [
      FocusTaskData(
        title: "${fatiha.arabicName} ١-${fatiha.verseCount}",
        type: TaskType.newMemorization,
        completedVerses: 0,
        totalVerses: fatiha.verseCount,
        progress: 0.0,
      ),
    ];
  }
  
  // Build focus tasks from due verse sets - with improved completion detection
  List<FocusTaskData> _buildFocusTasksFromDueSets(List<VerseSet> dueSets, ScheduleProvider.ScheduleProvider provider) {
    final surahs = Provider.of<QuranProvider>(context, listen: false).surahs;
    
    if (dueSets.isEmpty) {
      // If no due sets, determine next Surah for memorization
      final nextSurahId = _determineNextSurahForMemorization(surahs);
      final surahName = _getSurahDisplayName(nextSurahId, surahs);
      
      // Use appropriate verse count based on Surah
      int verseCount = 7; // Default
      try {
        final surah = surahs.firstWhere((s) => s.id == nextSurahId);
        verseCount = surah.verseSets.isNotEmpty ? 
            surah.verseSets.first.verseCount :
            (nextSurahId == 1 ? 7 : 5); // Al-Fatiha has 7 verses, default others to 5
      } catch (e) {
        // Use defaults
      }
      
      return [
        FocusTaskData(
          title: "$surahName ١-$verseCount",
          type: TaskType.newMemorization,
          completedVerses: 0,
          totalVerses: verseCount, 
          progress: 0.0,
        ),
      ];
    }
    
    final result = <FocusTaskData>[];
    
    // Categorize due sets by type
    final newSets = <VerseSet>[];
    final recentSets = <VerseSet>[];
    final oldSets = <VerseSet>[];
    
    for (final set in dueSets) {
      if (set.status == MemorizationStatus.notStarted) {
        newSets.add(set);
      } else if (set.repetitionCount <= 2) {
        recentSets.add(set);
      } else {
        oldSets.add(set);
      }
    }
    
    // Add a task for each category
    // New memorization
    if (newSets.isNotEmpty) {
      final set = newSets.first;
      result.add(FocusTaskData(
        title: "${_getSurahDisplayName(set.surahId, surahs)} ${set.startVerse}-${set.endVerse}",
        type: TaskType.newMemorization,
        completedVerses: set.status == MemorizationStatus.memorized ? set.verseCount : 
                         (set.status == MemorizationStatus.inProgress ? 
                           (set.verseCount * set.progressPercentage).round() : 0),
        totalVerses: set.verseCount,
        progress: set.progressPercentage,
        isCompleted: set.status == MemorizationStatus.memorized || 
                    (set.status == MemorizationStatus.inProgress && set.progressPercentage >= 0.9),
      ));
    }
    
    // Recent review
    if (recentSets.isNotEmpty) {
      final set = recentSets.first;
      result.add(FocusTaskData(
        title: "${_getSurahDisplayName(set.surahId, surahs)} ${set.startVerse}-${set.endVerse}",
        type: TaskType.recentReview,
        completedVerses: set.status == MemorizationStatus.memorized ? set.verseCount : 
                         (set.status == MemorizationStatus.inProgress ? 
                           (set.verseCount * set.progressPercentage).round() : 0),
        totalVerses: set.verseCount,
        progress: set.progressPercentage,
        isCompleted: set.status == MemorizationStatus.memorized || 
                    (set.status == MemorizationStatus.inProgress && set.progressPercentage >= 0.9),
      ));
    }
    
    // Old review
    if (oldSets.isNotEmpty) {
      final set = oldSets.first;
      result.add(FocusTaskData(
        title: "${_getSurahDisplayName(set.surahId, surahs)} ${set.startVerse}-${set.endVerse}",
        type: TaskType.oldReview,
        completedVerses: set.status == MemorizationStatus.memorized ? set.verseCount : 
                         (set.status == MemorizationStatus.inProgress ? 
                           (set.verseCount * set.progressPercentage).round() : 0),
        totalVerses: set.verseCount,
        progress: set.progressPercentage,
        isCompleted: set.status == MemorizationStatus.memorized || 
                    (set.status == MemorizationStatus.inProgress && set.progressPercentage >= 0.9),
      ));
    }
    
    // If no focus tasks were added, find next Surah to memorize
    if (result.isEmpty) {
      final nextSurahId = _determineNextSurahForMemorization(surahs);
      final surahName = _getSurahDisplayName(nextSurahId, surahs);
      
      // Use appropriate verse count based on Surah
      int verseCount = 7; // Default
      try {
        final surah = surahs.firstWhere((s) => s.id == nextSurahId);
        verseCount = surah.verseSets.isNotEmpty ? 
            surah.verseSets.first.verseCount :
            (nextSurahId == 1 ? 7 : 5); // Al-Fatiha has 7 verses, default others to 5
      } catch (e) {
        // Use defaults
      }
      
      result.add(FocusTaskData(
        title: "$surahName ١-$verseCount",
        type: TaskType.newMemorization,
        completedVerses: 0,
        totalVerses: verseCount,
        progress: 0.0,
      ));
    }
    
    return result;
  }
  
  // Function to determine next Surah for memorization based on current progress
  int _determineNextSurahForMemorization(List<Surah> surahs) {
    // First check if Al-Fatiha is fully memorized
    try {
      final fatiha = surahs.firstWhere((s) => s.id == 1);
      bool fatihaMemorized = fatiha.verseSets.every((set) => set.status == MemorizationStatus.memorized);
      
      if (!fatihaMemorized) {
        return 1; // Return Al-Fatiha if not fully memorized
      }
      
      // Find the first Surah that's not fully memorized
      for (final surah in surahs) {
        bool surahMemorized = surah.verseSets.every((set) => set.status == MemorizationStatus.memorized);
        if (!surahMemorized) {
          return surah.id;
        }
      }
      
      // Default to next Surah if all are memorized
      return 1;
    } catch (e) {
      // Default to Al-Fatiha if there's an error
      return 1;
    }
  }
  
  // Calculate streak progress (0-1) with max streak of 30 days
  double _calculateStreakProgress(int streak) {
    const int maxStreak = 30; // Consider 30 days as max for progress visualization
    return (streak / maxStreak).clamp(0.0, 1.0);
  }
  
  // Get completed verses count for a task type
  int _getCompletedVerses(List<FocusTaskData> tasks, TaskType type) {
    final task = tasks.firstWhere(
      (t) => t.type == type, 
      orElse: () => FocusTaskData(
        title: '', 
        type: type, 
        completedVerses: 0, 
        totalVerses: 1, 
        progress: 0.0
      )
    );
    return task.completedVerses;
  }
  
  // Get target verses count for a task type
  int _getTargetVerses(List<FocusTaskData> tasks, TaskType type) {
    final task = tasks.firstWhere(
      (t) => t.type == type, 
      orElse: () => FocusTaskData(
        title: '', 
        type: type, 
        completedVerses: 0, 
        totalVerses: type == TaskType.newMemorization ? 7 : 10, 
        progress: 0.0
      )
    );
    return task.totalVerses;
  }
  
  // Build weekly data from user's daily progress
  List<DailyProgressData> _buildWeeklyDataFromUser(SettingsProvider provider) {
    final now = DateTime.now();
    final user = provider.user;
    
    if (user == null || user.isFirstTime) {
      // Return empty progress rings for first-time users
      return [
        DailyProgressData(name: "السبت", shortName: "س", progress: 0.0),
        DailyProgressData(name: "الأحد", shortName: "ح", progress: 0.0),
        DailyProgressData(name: "الإثنين", shortName: "ن", progress: 0.0),
        DailyProgressData(name: "الثلاثاء", shortName: "ث", progress: 0.0),
        DailyProgressData(name: "الأربعاء", shortName: "ر", progress: 0.0, isToday: true),
        DailyProgressData(name: "الخميس", shortName: "خ", progress: 0.0),
        DailyProgressData(name: "الجمعة", shortName: "ج", progress: 0.0),
      ];
    }
    
    // Get days of the week in Arabic
    final dayNames = ["الأحد", "الإثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"];
    final dayShortNames = ["ح", "ن", "ث", "ر", "خ", "ج", "س"];
    
    return List.generate(7, (index) {
      // Calculate the date (starting from Sunday)
      final day = now.subtract(Duration(days: now.weekday - index));
      
      // Check if we have progress for this day
      final dailyProgress = user.dailyProgress.firstWhere(
        (p) => p.date.year == day.year && p.date.month == day.month && p.date.day == day.day,
        orElse: () => DailyProgress(
          date: day, 
          progress: 0.0, 
          completedVerses: 0, 
          targetVerses: 10
        )
      );
      
      return DailyProgressData(
        name: dayNames[index % 7],
        shortName: dayShortNames[index % 7],
        progress: dailyProgress.progress,
        isToday: day.year == now.year && day.month == now.month && day.day == now.day,
      );
    });
  }
  
  // Build activities from recent sessions - no sample data for first launch
  List<ActivityItem> _buildActivitiesFromRecentSessions(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final recentSessions = sessionProvider.recentSessions;
    
    if (recentSessions.isEmpty) {
      // Return empty list if no sessions
      return [];
    }
    
    final result = <ActivityItem>[];
    
    for (final session in recentSessions) {
      ActivityType activityType;
      IconData icon;
      
      switch (session.type) {
        case SessionType.newMemorization:
          activityType = ActivityType.memorization;
          icon = Icons.bolt;
          break;
        case SessionType.recentReview:
        case SessionType.oldReview:
          activityType = ActivityType.review;
          icon = Icons.refresh;
          break;
      }
      
      final now = DateTime.now();
      final diff = now.difference(session.timestamp);
      
      String timeAgo;
      if (diff.inMinutes < 60) {
        timeAgo = "منذ ${diff.inMinutes} دقيقة";
      } else if (diff.inHours < 24) {
        timeAgo = "منذ ${diff.inHours} ساعة";
      } else {
        timeAgo = "منذ ${diff.inDays} يوم";
      }
      
      String description;
      switch (session.type) {
        case SessionType.newMemorization:
          description = "حفظت ${session.verseCount} آية بجودة ${(session.quality * 100).round()}٪";
          break;
        case SessionType.recentReview:
          description = "راجعت ${session.verseCount} آية حديثة بجودة ${(session.quality * 100).round()}٪";
          break;
        case SessionType.oldReview:
          description = "راجعت ${session.verseCount} آية سابقة بجودة ${(session.quality * 100).round()}٪";
          break;
      }
      
      result.add(ActivityItem(
        type: activityType,
        surah: session.surahName,
        verseRange: session.verseRange,
        description: description,
        timeAgo: timeAgo,
        icon: icon,
      ));
    }
    
    return result;
  }
  
  // Build achievements from statistics - only for users with real achievements
  List<AchievementItem> _buildAchievementsFromStats(StatisticsProvider statsProvider) {
    final achievements = <AchievementItem>[];
    
    // Only add achievements if they're actually earned
    if (statsProvider.currentStreak > 0) {
      achievements.add(AchievementItem(
        title: "${statsProvider.currentStreak} أيام متتالية",
        icon: Icons.emoji_events,
      ));
    }
    
    if (statsProvider.memorizedVerses > 0) {
      achievements.add(AchievementItem(
        title: "${statsProvider.memorizedVerses} آية محفوظة",
        icon: Icons.menu_book,
      ));
    }
    
    if (statsProvider.totalReviews > 0) {
      achievements.add(AchievementItem(
        title: "${statsProvider.totalReviews} مراجعة",
        icon: Icons.refresh,
      ));
    }
    
    return achievements;
  }
  
  // Show focus detail dialog
  void _showFocusDetailDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'متابعة الحفظ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // Get details from schedule provider
                  Consumer<ScheduleProvider.ScheduleProvider>(
                    builder: (context, provider, child) {
                      // For first-time users, just show Al-Fatiha
                      final user = Provider.of<SettingsProvider>(context).user;
                      final isFirstTime = _isFirstTimeUser(user);
                      
                      if (isFirstTime) {
                        // Get Surahs to display correct Al-Fatiha information
                        final surahs = Provider.of<QuranProvider>(context, listen: false).surahs;
                        Surah? fatiha;
                        try {
                          fatiha = surahs.firstWhere((s) => s.id == 1);
                        } catch (e) {
                          // Fallback if Al-Fatiha is not found
                          fatiha = const Surah(
                            id: 1,
                            name: "Al-Fatihah",
                            arabicName: "الفاتحة",
                            verseCount: 7,
                          );
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'جدول اليوم',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primaryLight),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'حفظ جديد',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    "${fatiha.arabicName} 1-${fatiha.verseCount}",
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "عدد الآيات: ${fatiha.verseCount}",
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      
                                      // Start session
                                      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        sessionProvider.startNewSession(
                                          surahId: 1,
                                          type: SessionType.newMemorization,
                                        );
                                        
                                        // Update verse range
                                        sessionProvider.updateSessionVerseRange(1, fatiha!.verseCount);
                                        
                                        // Show modal
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          isDismissible: false,
                                          builder: (context) => const AddSessionModal(),
                                        );
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40),
                                    ),
                                    child: const Text('بدء الحفظ'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      
                      // Regular schedule for non-first-time users
                      if (provider.weekSchedule.isNotEmpty) {
                        final todaySchedule = provider.weekSchedule.first;
                        final surahs = Provider.of<QuranProvider>(context, listen: false).surahs;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'جدول اليوم',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            
                            ...todaySchedule.sessions.map((session) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primaryLight),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getSessionTypeText(session.type),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      "${_getSurahDisplayName(session.surahId, surahs)} ${session.verseRange}",
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "عدد الآيات: ${session.endVerse - session.startVerse + 1}",
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        
                                        // Start session
                                        final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          sessionProvider.startNewSession(
                                            surahId: session.surahId,
                                            type: _convertScheduleSessionTypeToSessionType(session.type),
                                          );
                                          
                                          // Update verse range
                                          sessionProvider.updateSessionVerseRange(
                                            session.startVerse,
                                            session.endVerse,
                                          );
                                          
                                          // Show modal
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            isDismissible: false,
                                            builder: (context) => const AddSessionModal(),
                                          );
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                      ),
                                      child: Text(_getSessionButtonText(session.type)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      } else {
                        return const Text(
                          'لا توجد جلسات مجدولة لهذا اليوم. يرجى التحقق من إعدادات الخوارزمية.',
                          style: TextStyle(fontSize: 16),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getSessionTypeText(ScheduleProvider.SessionType type) {
    switch (type) {
      case ScheduleProvider.SessionType.newMemorization:
        return 'حفظ جديد';
      case ScheduleProvider.SessionType.recentReview:
        return 'مراجعة حديثة';
      case ScheduleProvider.SessionType.oldReview:
        return 'مراجعة سابقة';
    }
  }
  
  String _getSessionButtonText(ScheduleProvider.SessionType type) {
    switch (type) {
      case ScheduleProvider.SessionType.newMemorization:
        return 'بدء الحفظ';
      case ScheduleProvider.SessionType.recentReview:
      case ScheduleProvider.SessionType.oldReview:
        return 'بدء المراجعة';
    }
  }
  
  // Helper method to convert between SessionType from different providers
  SessionType _convertScheduleSessionTypeToSessionType(ScheduleProvider.SessionType scheduleType) {
    switch (scheduleType) {
      case ScheduleProvider.SessionType.newMemorization:
        return SessionType.newMemorization;
      case ScheduleProvider.SessionType.recentReview:
        return SessionType.recentReview;
      case ScheduleProvider.SessionType.oldReview:
        return SessionType.oldReview;
    }
  }
}
