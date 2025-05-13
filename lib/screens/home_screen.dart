import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/widgets/home/achievement_row.dart';
import 'package:kottab/widgets/home/activity_timeline.dart';
import 'package:kottab/widgets/home/hero_section.dart';
import 'package:kottab/widgets/home/stat_card.dart';
import 'package:kottab/widgets/home/today_focus.dart';
import 'package:kottab/widgets/home/weekly_progress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // For animation demo
  double _newMemProgress = 0.0;
  double _recentReviewProgress = 0.0;
  double _oldReviewProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Animate progress after widget is built
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _newMemProgress = 0.65;
          _recentReviewProgress = 0.9;
          _oldReviewProgress = 0.3;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sample data for weekly progress
    final weeklyData = [
      DailyProgressData(name: "السبت", shortName: "س", progress: 0.7),
      DailyProgressData(name: "الأحد", shortName: "ح", progress: 0.9),
      DailyProgressData(name: "الإثنين", shortName: "ن", progress: 0.5),
      DailyProgressData(name: "الثلاثاء", shortName: "ث", progress: 0.8),
      DailyProgressData(name: "الأربعاء", shortName: "ر", progress: 0.6, isToday: true),
      DailyProgressData(name: "الخميس", shortName: "خ", progress: 0.75),
      DailyProgressData(name: "الجمعة", shortName: "ج", progress: 0.65),
    ];

    // Sample data for focus tasks
    final focusTasks = [
      FocusTaskData(
        title: "البقرة ٦١-٧٠",
        type: TaskType.newMemorization,
        completedVerses: 13,
        totalVerses: 20,
        progress: _newMemProgress,
      ),
      FocusTaskData(
        title: "البقرة ٤١-٦٠",
        type: TaskType.recentReview,
        completedVerses: 20,
        totalVerses: 20,
        progress: _recentReviewProgress,
        isCompleted: true,
      ),
      FocusTaskData(
        title: "البقرة ١-٢٠",
        type: TaskType.oldReview,
        completedVerses: 6,
        totalVerses: 20,
        progress: _oldReviewProgress,
      ),
    ];

    // Sample data for activities
    final activities = [
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

    // Sample data for achievements
    final achievements = [
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
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section with Google Fit style circles
            HeroSection(
              newMemProgress: _newMemProgress,
              recentReviewProgress: _recentReviewProgress,
              oldReviewProgress: _oldReviewProgress,
              completedNewVerses: 13,
              targetNewVerses: 20,
              completedRecentVerses: 18,
              targetRecentVerses: 20,
              completedOldVerses: 6,
              targetOldVerses: 20,
              streak: 12,
            ),

            const SizedBox(height: 8),

            // Weekly progress
            WeeklyProgress(
              weekData: weeklyData,
              onViewAll: () {
                // TODO: Navigate to detailed weekly progress
              },
            ),

            const SizedBox(height: 8),

            // Today's focus
            TodayFocus(
              tasks: focusTasks,
              onContinue: () {
                // TODO: Navigate to active memorization
              },
            ),

            const SizedBox(height: 8),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Memorized Verses Stats
                  Expanded(
                    child: StatCard(
                      title: 'محفوظ',
                      value: '٦٠',
                      suffix: 'آية',
                      description: '٠.٩٪ من القرآن',
                      icon: Icons.menu_book,
                      progress: 0.01,
                      iconColor: AppColors.primary,
                      bgColor: AppColors.primaryLight,
                      progressColor: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Streak Stats
                  Expanded(
                    child: StatCard(
                      title: 'التتابع',
                      value: '١٢',
                      suffix: 'يوم',
                      description: 'استمر في العمل!',
                      icon: Icons.trending_up,
                      progress: 0.6,
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
                // TODO: Navigate to activity history
              },
            ),

            const SizedBox(height: 8),

            // Achievements
            AchievementRow(
              achievements: achievements,
              onViewAll: () {
                // TODO: Navigate to achievements
              },
            ),

            // Extra padding at bottom for the FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
