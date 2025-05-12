import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';
import 'package:kottab/utils/date_formatter.dart';
import 'package:kottab/widgets/home/hero_section.dart';
import 'package:kottab/widgets/home/weekly_progress.dart';
import 'package:kottab/widgets/home/focus_card.dart';
import 'package:kottab/widgets/home/stat_card.dart';
import 'package:kottab/widgets/home/activity_item.dart';
import 'package:kottab/widgets/home/achievement_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // For animation demo
  double _todayProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Animate progress after widget is built
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _todayProgress = 0.65;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sample data for weekly progress
    final weeklyData = [
      const DailyProgressData(dayName: 'السبت', progress: 0.7),
      const DailyProgressData(dayName: 'الأحد', progress: 0.9),
      const DailyProgressData(dayName: 'الإثنين', progress: 0.5),
      const DailyProgressData(dayName: 'الثلاثاء', progress: 0.8),
      const DailyProgressData(dayName: 'الأربعاء', progress: 0.6),
      const DailyProgressData(dayName: 'الخميس', progress: 0.75),
      const DailyProgressData(dayName: 'الجمعة', progress: 0.65, isToday: true),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section with today's progress
            HeroSection(
              progress: _todayProgress,
              completedVerses: 13,
              targetVerses: 20,
              streak: 12,
              progressChange: 0.2,
            ),

            const SizedBox(height: 12),

            // Weekly progress section
            WeeklyProgress(
              weekData: weeklyData,
            ),

            const SizedBox(height: 12),

            // Today's focus section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with target
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تركيز اليوم',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.track_changes,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '20 آية',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Focus cards
                  Column(
                    children: [
                      FocusCard(
                        type: FocusCardType.newMemorization,
                        surahName: 'البقرة',
                        verseRange: '61-70',
                        progress: 0.7,
                        statusText: '13/20 آية',
                        onTap: () {
                          // TODO: Navigate to memorization
                        },
                      ),

                      const SizedBox(height: 12),

                      FocusCard(
                        type: FocusCardType.recentReview,
                        surahName: 'البقرة',
                        verseRange: '41-60',
                        progress: 0.9,
                        statusText: 'تم إكماله',
                        isCompleted: true,
                        onTap: () {
                          // TODO: Navigate to review
                        },
                      ),

                      const SizedBox(height: 12),

                      FocusCard(
                        type: FocusCardType.oldReview,
                        surahName: 'البقرة',
                        verseRange: '1-20',
                        progress: 0.3,
                        statusText: '6/20 آية',
                        onTap: () {
                          // TODO: Navigate to review
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Continue memorization button
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to active memorization
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'متابعة الحفظ',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Memorized Verses Stats
                  Expanded(
                    child: StatCard(
                      title: 'محفوظ',
                      value: '60',
                      suffix: 'آية',
                      description: '0.9% من القرآن',
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
                      value: '12',
                      suffix: 'يوم',
                      description: 'استمر في العمل!',
                      icon: Icons.trending_up,
                      progress: 0.6,
                      iconColor: AppColors.blue,
                      bgColor: AppColors.blueLight,
                      progressColor: AppColors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Recent Activity
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'النشاط الأخير',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to activity history
                          },
                          child: Text(
                            'عرض الكل',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Activity items
                  ActivityItem(
                    type: ActivityType.memorization,
                    surahName: 'البقرة',
                    verseRange: '51-60',
                    description: 'أكملت حفظ 10 آيات جديدة',
                    time: DateTime.now().subtract(const Duration(minutes: 30)),
                  ),

                  ActivityItem(
                    type: ActivityType.review,
                    surahName: 'البقرة',
                    verseRange: '41-50',
                    description: 'راجعت 10 آيات بنجاح',
                    time: DateTime.now().subtract(const Duration(hours: 1)),
                  ),

                  ActivityItem(
                    type: ActivityType.challenge,
                    surahName: 'الفاتحة',
                    verseRange: '1-7',
                    description: 'أكملت تحدي المراجعة اليومي',
                    time: DateTime.now().subtract(const Duration(days: 1)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Achievements
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإنجازات',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to achievements
                          },
                          child: Text(
                            'عرض الكل',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Achievement items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      AchievementItem(
                        icon: Icons.emoji_events,
                        title: '10 أيام متتالية',
                        color: Colors.amber,
                        bgColor: Color(0xFFFEF3C7),
                      ),
                      AchievementItem(
                        icon: Icons.menu_book,
                        title: 'حفظ سورة كاملة',
                        color: AppColors.primary,
                        bgColor: AppColors.primaryLight,
                      ),
                      AchievementItem(
                        icon: Icons.refresh,
                        title: '50 مراجعة',
                        color: AppColors.blue,
                        bgColor: AppColors.blueLight,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Extra padding at bottom for the FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}