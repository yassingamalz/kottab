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
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xFF10B981)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
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

                  // Days container with modern styling
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: provider.weekSchedule.map((day) => 
                        DaySchedule(day: day)
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Algorithm Settings Section
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
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
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                    ),
                    child: Text(
                      'إعدادات الخوارزمية',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
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
                gradient: LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0x333B82F6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F3B82F6),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(0x333B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'i',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'كيف تعمل خوارزمية المراجعة؟',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'تستخدم الخوارزمية نظام التكرار المتباعد للمساعدة في تثبيت الحفظ. يتم مراجعة الآيات الجديدة بشكل متكرر في البداية، ثم تقل وتيرة المراجعة تدريجيًا مع تحسن الحفظ.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF1E3A8A),
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
