import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/schedule_provider.dart';
import 'package:kottab/screens/activity_detail_screen.dart';
import 'package:kottab/screens/achievements_screen.dart';
import 'package:kottab/screens/weekly_detail_screen.dart';
import 'package:kottab/widgets/home/achievement_row.dart';
import 'package:kottab/widgets/home/activity_timeline.dart';
import 'package:kottab/widgets/home/hero_section.dart';
import 'package:kottab/widgets/home/stat_card.dart';
import 'package:kottab/widgets/home/today_focus.dart';
import 'package:kottab/widgets/home/weekly_progress.dart';
import 'package:kottab/widgets/sessions/add_session_modal.dart';
import 'package:provider/provider.dart';
import 'package:kottab/providers/statistics_provider.dart';
import 'package:kottab/providers/settings_provider.dart';
import 'package:kottab/providers/session_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // For animation demo
  double _newMemProgress = 0.0;
  double _recentReviewProgress = 0.0;
  double _oldReviewProgress = 0.0;
  
  // Animation controller for tasks
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Animate progress after widget is built
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _newMemProgress = 0.65;
          _recentReviewProgress = 0.9;
          _oldReviewProgress = 0.3;
        });
        _progressController.forward();
      }
    });
    
    // Force data refresh when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }
  
  void _refreshData() {
    final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    
    // Refresh all providers
    statsProvider.refreshData();
    settingsProvider.refreshData();
    sessionProvider.refreshData();
    scheduleProvider.refreshData();
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer3<StatisticsProvider, SettingsProvider, ScheduleProvider>(
        builder: (context, statsProvider, settingsProvider, scheduleProvider, child) {
          // Build dynamic weekly data from user progress
          final weeklyData = _buildWeeklyDataFromUser(settingsProvider);
          
          // Build dynamic focus tasks from schedule
          final focusTasks = _buildFocusTasksFromSchedule(scheduleProvider);
          
          // Build activities from recent sessions
          final activities = _buildActivitiesFromRecentSessions(context);

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero section with Google Fit style circles
                  HeroSection(
                    newMemProgress: _newMemProgress,
                    recentReviewProgress: _recentReviewProgress,
                    oldReviewProgress: _oldReviewProgress,
                    completedNewVerses: _getCompletedVerses(focusTasks, TaskType.newMemorization),
                    targetNewVerses: _getTargetVerses(focusTasks, TaskType.newMemorization),
                    completedRecentVerses: _getCompletedVerses(focusTasks, TaskType.recentReview),
                    targetRecentVerses: _getTargetVerses(focusTasks, TaskType.recentReview),
                    completedOldVerses: _getCompletedVerses(focusTasks, TaskType.oldReview),
                    targetOldVerses: _getTargetVerses(focusTasks, TaskType.oldReview),
                    streak: settingsProvider.user?.streak ?? 0,
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
                            value: statsProvider.memorizedVerses.toString(),
                            suffix: 'آية',
                            description: '${(statsProvider.memorizedPercentage * 100).toStringAsFixed(1)}٪ من القرآن',
                            icon: Icons.menu_book,
                            progress: statsProvider.memorizedPercentage,
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

                  // Recent Activity
                  ActivityTimeline(
                    activities: activities,
                    onViewAll: () {
                      // Navigate to activity history
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ActivityDetailScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Achievements - use real stats
                  Consumer<StatisticsProvider>(
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
                  ),

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
        totalVerses: 10, 
        progress: 0.0
      )
    );
    return task.totalVerses;
  }
  
  // Build weekly data from user's daily progress
  List<DailyProgressData> _buildWeeklyDataFromUser(SettingsProvider provider) {
    final now = DateTime.now();
    final user = provider.user;
    
    if (user == null) {
      // Return sample data if no user
      return [
        DailyProgressData(name: "السبت", shortName: "س", progress: 0.7),
        DailyProgressData(name: "الأحد", shortName: "ح", progress: 0.9),
        DailyProgressData(name: "الإثنين", shortName: "ن", progress: 0.5),
        DailyProgressData(name: "الثلاثاء", shortName: "ث", progress: 0.8),
        DailyProgressData(name: "الأربعاء", shortName: "ر", progress: 0.6, isToday: true),
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
        orElse: () => DailyProgress(date: day, progress: 0.0, completedVerses: 0, targetVerses: 10)
      );
      
      return DailyProgressData(
        name: dayNames[index % 7],
        shortName: dayShortNames[index % 7],
        progress: dailyProgress.progress,
        isToday: day.year == now.year && day.month == now.month && day.day == now.day,
      );
    });
  }
  
  // Build focus tasks from schedule and user data
  List<FocusTaskData> _buildFocusTasksFromSchedule(ScheduleProvider provider) {
    if (provider.isLoading || provider.weekSchedule.isEmpty) {
      // Return sample data if no schedule
      return [
        FocusTaskData(
          title: "البقرة ٦١-٧٠",
          type: TaskType.newMemorization,
          completedVerses: 0,
          totalVerses: provider.dailyVerseTarget,
          progress: _newMemProgress,
        ),
        FocusTaskData(
          title: "البقرة ٤١-٦٠",
          type: TaskType.recentReview,
          completedVerses: provider.reviewSetSize,
          totalVerses: provider.reviewSetSize,
          progress: _recentReviewProgress,
          isCompleted: true,
        ),
        FocusTaskData(
          title: "البقرة ١-٢٠",
          type: TaskType.oldReview,
          completedVerses: 0,
          totalVerses: 20,
          progress: _oldReviewProgress,
        ),
      ];
    }
    
    final result = <FocusTaskData>[];
    
    // Get today's schedule
    final todaySchedule = provider.weekSchedule.first;
    
    // Process each session type
    for (final session in todaySchedule.sessions) {
      TaskType taskType;
      switch (session.type) {
        case SessionType.newMemorization:
          taskType = TaskType.newMemorization;
          break;
        case SessionType.recentReview:
          taskType = TaskType.recentReview;
          break;
        case SessionType.oldReview:
          taskType = TaskType.oldReview;
          break;
      }
      
      result.add(FocusTaskData(
        title: "${session.surahName} ${session.verseRange}",
        type: taskType,
        completedVerses: session.isCompleted ? (session.endVerse - session.startVerse + 1) : 0,
        totalVerses: session.endVerse - session.startVerse + 1,
        progress: session.isCompleted ? 1.0 : 0.0,
        isCompleted: session.isCompleted,
      ));
    }
    
    // If no sessions were found for any type, add defaults
    if (!result.any((task) => task.type == TaskType.newMemorization)) {
      result.add(FocusTaskData(
        title: "البقرة ١-${provider.dailyVerseTarget}",
        type: TaskType.newMemorization,
        completedVerses: 0,
        totalVerses: provider.dailyVerseTarget,
        progress: 0.0,
      ));
    }
    
    return result;
  }
  
  // Build activities from recent sessions
  List<ActivityItem> _buildActivitiesFromRecentSessions(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final recentSessions = sessionProvider.recentSessions;
    
    if (recentSessions.isEmpty) {
      // Return sample data if no sessions
      return [
        ActivityItem(
          type: ActivityType.memorization,
          surah: "البقرة",
          verseRange: "51-60",
          description: "أكملت حفظ 10 آيات جديدة",
          timeAgo: "منذ 30 دقيقة",
          icon: Icons.bolt,
        ),
        ActivityItem(
          type: ActivityType.review,
          surah: "البقرة",
          verseRange: "41-50",
          description: "راجعت 10 آيات بنجاح",
          timeAgo: "منذ ساعة",
          icon: Icons.refresh,
        ),
        ActivityItem(
          type: ActivityType.challenge,
          surah: "الفاتحة",
          verseRange: "1-7",
          description: "أكملت تحدي المراجعة اليومي",
          timeAgo: "منذ يوم",
          icon: Icons.emoji_events,
        ),
      ];
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
  
  // Build achievements from statistics
  List<AchievementItem> _buildAchievementsFromStats(StatisticsProvider statsProvider) {
    final achievements = <AchievementItem>[];
    
    // Streak achievement
    if (statsProvider.currentStreak > 0) {
      achievements.add(AchievementItem(
        title: "${statsProvider.currentStreak} أيام متتالية",
        icon: Icons.emoji_events,
      ));
    }
    
    // Memorized verses achievement
    if (statsProvider.memorizedVerses > 0) {
      achievements.add(AchievementItem(
        title: "${statsProvider.memorizedVerses} آية محفوظة",
        icon: Icons.menu_book,
      ));
    }
    
    // Total reviews achievement
    if (statsProvider.totalReviews > 0) {
      achievements.add(AchievementItem(
        title: "${statsProvider.totalReviews} مراجعة",
        icon: Icons.refresh,
      ));
    }
    
    // If we have no achievements, add defaults
    if (achievements.isEmpty) {
      achievements.addAll([
        AchievementItem(
          title: "١٠ أيام متتالية",
          icon: Icons.emoji_events,
        ),
        AchievementItem(
          title: "حفظ سورة كاملة",
          icon: Icons.menu_book,
        ),
        AchievementItem(
          title: "٥٠ مراجعة",
          icon: Icons.refresh,
        ),
      ]);
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
                  Consumer<ScheduleProvider>(
                    builder: (context, provider, child) {
                      // Show today's schedule information
                      if (provider.weekSchedule.isNotEmpty) {
                        final todaySchedule = provider.weekSchedule.first;
                        
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
                                      "${session.surahName} ${session.verseRange}",
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
                                            type: session.type,
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
  
  String _getSessionTypeText(SessionType type) {
    switch (type) {
      case SessionType.newMemorization:
        return 'حفظ جديد';
      case SessionType.recentReview:
        return 'مراجعة حديثة';
      case SessionType.oldReview:
        return 'مراجعة سابقة';
    }
  }
  
  String _getSessionButtonText(SessionType type) {
    switch (type) {
      case SessionType.newMemorization:
        return 'بدء الحفظ';
      case SessionType.recentReview:
      case SessionType.oldReview:
        return 'بدء المراجعة';
    }
  }
}
