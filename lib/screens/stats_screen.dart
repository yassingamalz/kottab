import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/statistics_provider.dart';
import 'package:kottab/utils/arabic_numbers.dart';
import 'package:kottab/widgets/stats/progress_circle.dart';
import 'package:kottab/widgets/stats/weekly_pattern.dart';
import 'package:kottab/widgets/stats/stats_section.dart';
import 'package:kottab/widgets/stats/milestone_card.dart';

import '../config/app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatisticsProvider>(context, listen: false).refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<StatisticsProvider>(
        builder: (context, statsProvider, child) {
          if (statsProvider.isLoading) {
            return _buildLoadingState();
          }

          return _buildStatsContent(statsProvider);
        },
      ),
    );
  }

  /// Build loading state UI
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Build statistics content
  Widget _buildStatsContent(StatisticsProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress Overview Section
            StatsSection(
              title: 'نظرة عامة على التقدم',
              child: Column(
                children: [
                  // Progress circle
                  Center(
                    child: ProgressCircle(
                      percentage: provider.memorizedPercentage,
                      centerText: ArabicNumbers.formatPercentage(provider.memorizedPercentage),
                      subtitle: 'مكتمل',
                      size: 160,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats grid
                  Row(
                    children: [
                      // Memorized verses
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الآيات المحفوظة',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ArabicNumbers.toArabicDigits(provider.memorizedVerses)} / ${ArabicNumbers.toArabicDigits(6236)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Current streak
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التتابع الحالي',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ArabicNumbers.toArabicDigits(provider.currentStreak)} يوم',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Milestones Section
            StatsSection(
              title: 'الإنجازات',
              headerColor: Colors.amber.shade700,
              child: Column(
                children: [
                  // Milestone cards
                  MilestoneCard(
                    icon: Icons.emoji_events,
                    iconColor: Colors.amber,
                    bgColor: Colors.amber.shade100,
                    title: 'أطول تتابع',
                    value: '${ArabicNumbers.toArabicDigits(provider.longestStreak)} يوم',
                  ),

                  const SizedBox(height: 12),

                  MilestoneCard(
                    icon: Icons.calendar_today,
                    iconColor: AppColors.blue,
                    bgColor: AppColors.blueLight,
                    title: 'أيام النشاط',
                    value: '${ArabicNumbers.toArabicDigits(provider.daysActive)} يوم',
                  ),

                  const SizedBox(height: 12),

                  MilestoneCard(
                    icon: Icons.check_circle,
                    iconColor: AppColors.primary,
                    bgColor: AppColors.primaryLight,
                    title: 'إجمالي المراجعات',
                    value: ArabicNumbers.toArabicDigits(provider.totalReviews),
                  ),
                ],
              ),
            ),

            // Review Statistics Section
            StatsSection(
              title: 'إحصائيات المراجعة',
              headerColor: AppColors.blue,
              child: Column(
                children: [
                  // Most reviewed set
                  if (provider.mostReviewedSet.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أكثر مجموعة مراجعة',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.emoji_events,
                                      color: Colors.amber.shade700,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    provider.mostReviewedSet,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${ArabicNumbers.toArabicDigits(provider.mostReviewedSetCount)} مراجعة',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.amber.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Weekly pattern
                  WeeklyPattern(
                    weekData: provider.weeklyPattern,
                    maxValue: provider.maxDailyReviews,
                  ),

                  const SizedBox(height: 16),

                  // Average quality
                  Row(
                    children: [
                      Text(
                        'متوسط جودة المراجعة:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ArabicNumbers.formatPercentage(provider.averageQuality),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getQualityColor(provider.averageQuality),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get color based on quality score
  Color _getQualityColor(double quality) {
    if (quality >= 0.8) {
      return AppColors.primary;
    } else if (quality >= 0.6) {
      return Colors.amber.shade700;
    } else {
      return Colors.red.shade700;
    }
  }
}