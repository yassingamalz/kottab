import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';
import 'package:provider/provider.dart';
import 'package:kottab/providers/session_provider.dart' as session_provider;
import 'package:kottab/providers/schedule_provider.dart' as schedule_provider;
import 'package:kottab/widgets/sessions/add_session_modal.dart';

class TodayFocus extends StatefulWidget {
  final List<FocusTaskData> tasks;
  final VoidCallback? onContinue;

  const TodayFocus({
    super.key,
    required this.tasks,
    this.onContinue,
  });

  @override
  State<TodayFocus> createState() => _TodayFocusState();
}

class _TodayFocusState extends State<TodayFocus> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  
  // Create multiple animations for each task
  Map<int, Animation<double>> _progressAnimations = {};
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Initialize animations for each task
    _initializeAnimations();
    
    // Start the animation
    _animController.forward();
  }
  
  void _initializeAnimations() {
    for (int i = 0; i < widget.tasks.length; i++) {
      _progressAnimations[i] = Tween<double>(
        begin: 0.0,
        end: widget.tasks[i].progress,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(
            0.1 * i, // Stagger the animations
            0.1 * i + 0.8,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    }
  }
  
  @override
  void didUpdateWidget(TodayFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if tasks or progress values have changed
    bool needsUpdate = oldWidget.tasks.length != widget.tasks.length;
    if (!needsUpdate) {
      for (int i = 0; i < widget.tasks.length; i++) {
        if (i >= oldWidget.tasks.length || 
            oldWidget.tasks[i].progress != widget.tasks[i].progress ||
            oldWidget.tasks[i].isCompleted != widget.tasks[i].isCompleted) {
          needsUpdate = true;
          break;
        }
      }
    }
    
    if (needsUpdate) {
      // Reset animations
      _progressAnimations.clear();
      _initializeAnimations();
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<session_provider.SessionProvider, schedule_provider.ScheduleProvider>(
      builder: (context, sessionProvider, scheduleProvider, child) {
        // Get daily verse target from settings
        final int dailyTarget = scheduleProvider.dailyVerseTarget;
        
        // FIX: Check if all tasks are completed based on individual task state
        final bool allTasksCompleted = widget.tasks.every((task) => 
          task.isCompleted || task.completedVerses >= task.totalVerses);

        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with target info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تركيز اليوم',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ArabicNumbers.toArabicDigits(dailyTarget)} آية',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // FIX: Improved completion message with next day's preview
              if (allTasksCompleted)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'أحسنت! لقد أكملت جميع مهام اليوم',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'عد غدًا للمزيد من التقدم في حفظ القرآن الكريم',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // Preview of tomorrow's tasks if available
                      if (scheduleProvider.weekSchedule.length > 1) 
                        _buildTomorrowPreview(context, scheduleProvider.weekSchedule[1]),
                    ],
                  ),
                )
              else
                // Task cards with animated progress
                ...List.generate(widget.tasks.length, (index) {
                  return AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTaskCard(
                          context, 
                          widget.tasks[index],
                          _progressAnimations[index]?.value ?? 0.0,
                        ),
                      );
                    },
                  );
                }),

              const SizedBox(height: 16),

              // Continue button
              ElevatedButton(
                onPressed: () {
                  if (widget.onContinue != null) {
                    widget.onContinue!();
                  } else {
                    // If no handler provided, show add session modal
                    _showAddSession(context, sessionProvider);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      allTasksCompleted ? 'عرض التفاصيل' : 'متابعة الحفظ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // FIX: New method to build tomorrow's preview
  Widget _buildTomorrowPreview(BuildContext context, schedule_provider.DaySchedule tomorrowSchedule) {
    if (tomorrowSchedule.sessions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        
        Text(
          'مهام الغد:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Show the first session as preview
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryLight),
          ),
          child: Row(
            children: [
              Icon(
                _getSessionTypeIcon(tomorrowSchedule.sessions[0].type),
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${tomorrowSchedule.sessions[0].surahName} ${tomorrowSchedule.sessions[0].verseRange}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Helper for session type icons
  IconData _getSessionTypeIcon(schedule_provider.SessionType type) {
    switch (type) {
      case schedule_provider.SessionType.newMemorization:
        return Icons.bolt;
      case schedule_provider.SessionType.recentReview:
        return Icons.refresh;
      case schedule_provider.SessionType.oldReview:
        return Icons.replay;
    }
  }

  Widget _buildTaskCard(BuildContext context, FocusTaskData task, double animatedProgress) {
    Color borderColor;
    Color progressColor;
    Color iconBgColor;
    Color iconColor;
    IconData icon;

    // Set colors and icons based on task type
    switch (task.type) {
      case TaskType.newMemorization:
        borderColor = AppColors.primaryLight;
        progressColor = AppColors.primary;
        iconBgColor = AppColors.primaryLight;
        iconColor = AppColors.primary;
        icon = Icons.bolt;
        break;
      case TaskType.recentReview:
        borderColor = AppColors.secondaryLight;
        progressColor = AppColors.secondary;
        iconBgColor = AppColors.secondaryLight;
        iconColor = AppColors.secondary;
        icon = Icons.refresh;
        break;
      case TaskType.oldReview:
        borderColor = AppColors.tertiaryLight;
        progressColor = AppColors.tertiary;
        iconBgColor = AppColors.tertiaryLight;
        iconColor = AppColors.tertiary;
        icon = Icons.replay;
        break;
    }

    // FIX: Determine if task is completed based on verse count
    final isTaskComplete = task.isCompleted || task.completedVerses >= task.totalVerses;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Background progress indicator - animated
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: isTaskComplete ? 1.0 : animatedProgress, // Always 100% for completed tasks
                child: Container(
                  decoration: BoxDecoration(
                    color: isTaskComplete ? iconBgColor.withOpacity(0.4) : iconBgColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          // Card content
          Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTaskTypeText(task.type),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),

              // Status
              isTaskComplete
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'تم إكماله',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      '${ArabicNumbers.toArabicDigits(task.completedVerses)}/${ArabicNumbers.toArabicDigits(task.totalVerses)} آية',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getTaskTypeText(TaskType type) {
    switch (type) {
      case TaskType.newMemorization:
        return 'حفظ جديد';
      case TaskType.recentReview:
        return 'مراجعة حديثة';
      case TaskType.oldReview:
        return 'مراجعة سابقة';
    }
  }
  
  /// Show add session modal
  void _showAddSession(BuildContext context, session_provider.SessionProvider sessionProvider) {
    // Only if we have tasks to work with
    if (widget.tasks.isEmpty) return;
    
    // Start with the first task
    final task = widget.tasks.first;
    
    // Initialize session with this task's parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start a new session based on task type
      sessionProvider.startNewSession(
        surahId: int.tryParse(task.title.split(' ').first) ?? 1,
        type: _convertTaskTypeToSessionType(task.type),
      );
      
      // Show the session modal
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        builder: (context) => const AddSessionModal(),
      );
    });
  }
  
  /// Convert task type to session type
  session_provider.SessionType _convertTaskTypeToSessionType(TaskType taskType) {
    switch (taskType) {
      case TaskType.newMemorization:
        return session_provider.SessionType.newMemorization;
      case TaskType.recentReview:
        return session_provider.SessionType.recentReview;
      case TaskType.oldReview:
        return session_provider.SessionType.oldReview;
    }
  }
}

enum TaskType {
  newMemorization,
  recentReview,
  oldReview,
}

class FocusTaskData {
  final String title;
  final TaskType type;
  final int completedVerses;
  final int totalVerses;
  final double progress;
  final bool isCompleted;

  const FocusTaskData({
    required this.title,
    required this.type,
    required this.completedVerses,
    required this.totalVerses,
    required this.progress,
    this.isCompleted = false,
  });
}
