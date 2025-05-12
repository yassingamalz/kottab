import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../widgets/schedule/settings_item.dart';
import '../providers/schedule_provider.dart' as scheduleData;
import '../widgets/schedule/day_schedule.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<scheduleData.ScheduleProvider>(context, listen: false).refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<scheduleData.ScheduleProvider>(
        builder: (context, scheduleProvider, child) {
          if (scheduleProvider.isLoading) {
            return _buildLoadingState();
          }

          return _buildScheduleContent(scheduleProvider);
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

  /// Build schedule content
  Widget _buildScheduleContent(scheduleData.ScheduleProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Weekly Schedule Section
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      'الجدول الأسبوعي',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Days
                  ...provider.weekSchedule.map((day) => DaySchedule(day: day)).toList(),
                ],
              ),
            ),

            // Algorithm Settings Section
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      'إعدادات الخوارزمية',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  // Settings
                  SettingsItem(
                    title: 'آيات جديدة يوميًا',
                    description: 'عدد الآيات الجديدة للحفظ',
                    value: provider.dailyVerseTarget,
                    maxValue: 30,
                    onChanged: (value) {
                      provider.updateSetting('dailyVerseTarget', value);
                    },
                  ),

                  SettingsItem(
                    title: 'حجم مجموعة المراجعة',
                    description: 'نطاق مراجعة الحفظ الحديث',
                    value: provider.reviewSetSize,
                    minValue: 5,
                    maxValue: 50,
                    onChanged: (value) {
                      provider.updateSetting('reviewSetSize', value);
                    },
                  ),

                  SettingsItem(
                    title: 'دورة المجموعة القديمة',
                    description: 'أيام بين مراجعة المجموعات القديمة',
                    value: provider.oldReviewCycle,
                    minValue: 1,
                    maxValue: 30,
                    onChanged: (value) {
                      provider.updateSetting('oldReviewCycle', value);
                    },
                  ),
                ],
              ),
            ),

            // Algorithm explanation
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blueLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'كيف تعمل خوارزمية المراجعة؟',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'تستخدم الخوارزمية نظام التكرار المتباعد للمساعدة في تثبيت الحفظ. يتم مراجعة الآيات الجديدة بشكل متكرر في البداية، ثم تقل وتيرة المراجعة تدريجياً مع تحسن الحفظ.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.blue.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}