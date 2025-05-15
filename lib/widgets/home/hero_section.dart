import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';
import 'package:kottab/utils/date_formatter.dart';
import 'package:kottab/widgets/shared/circle_progress.dart';
import 'package:provider/provider.dart';
import 'package:kottab/providers/statistics_provider.dart';
import 'package:kottab/providers/settings_provider.dart';
import 'package:kottab/models/user_model.dart';

class HeroSection extends StatefulWidget {
  final double newMemProgress;
  final double recentReviewProgress;
  final double oldReviewProgress;
  final int completedNewVerses;
  final int targetNewVerses;
  final int completedRecentVerses;
  final int targetRecentVerses;
  final int completedOldVerses;
  final int targetOldVerses;
  final int streak;
  final double memorizedPercentage;

  const HeroSection({
    super.key,
    required this.newMemProgress,
    required this.recentReviewProgress,
    required this.oldReviewProgress,
    required this.completedNewVerses,
    required this.targetNewVerses,
    required this.completedRecentVerses,
    required this.targetRecentVerses,
    required this.completedOldVerses,
    required this.targetOldVerses,
    required this.streak,
    this.memorizedPercentage = 0.0,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _newMemAnimation;
  late Animation<double> _recentReviewAnimation;
  late Animation<double> _oldReviewAnimation;
  late Animation<double> _overallProgressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _initializeAnimations();
    _animationController.forward();
  }

  void _initializeAnimations() {
    // Initialize animations with correct progress values
    _newMemAnimation = Tween<double>(
      begin: 0.0,
      end: widget.newMemProgress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _recentReviewAnimation = Tween<double>( 
      begin: 0.0,
      end: widget.recentReviewProgress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _oldReviewAnimation = Tween<double>(
      begin: 0.0,
      end: widget.oldReviewProgress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Add dedicated animation for overall progress
    _overallProgressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.memorizedPercentage.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(HeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If any of the progress values have changed, update and restart animations
    if (oldWidget.newMemProgress != widget.newMemProgress ||
        oldWidget.recentReviewProgress != widget.recentReviewProgress ||
        oldWidget.oldReviewProgress != widget.oldReviewProgress ||
        oldWidget.memorizedPercentage != widget.memorizedPercentage) {
        
      print("HeroSection: Progress changed, updating animations");
      print("Memorized percentage: ${widget.memorizedPercentage}");
      
      _initializeAnimations();
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<StatisticsProvider, SettingsProvider>(
      builder: (context, statsProvider, settingsProvider, child) {
        final now = DateTime.now();
        final String formattedDate = DateFormatter.formatArabicDate(now);
        
        // Get the user data to display today's progress
        final user = settingsProvider.user;
        final int streak = user?.streak ?? widget.streak;
        
        // Get today's progress if available
        final todayProgress = user?.todayProgress;
        
        // Calculate daily progress percentage for display in the central circle
        double dailyProgressPercent = 0.0;
        String dailyProgressText = '٠٪';
        
        if (todayProgress != null) {
          // If we've completed our target verses, show 100%
          if (todayProgress.completedVerses >= todayProgress.targetVerses) {
            dailyProgressPercent = 1.0; // 100%
            dailyProgressText = ArabicNumbers.formatPercentage(1.0);
            print("HERO: Using complete progress: ${todayProgress.completedVerses}/${todayProgress.targetVerses} (100%)");
          } else {
            // Otherwise show actual progress toward target
            dailyProgressPercent = todayProgress.progress.clamp(0.0, 1.0);
            dailyProgressText = ArabicNumbers.formatPercentage(dailyProgressPercent);
            print("HERO: Using today's progress: ${todayProgress.completedVerses}/${todayProgress.targetVerses} (${dailyProgressPercent * 100}%)");
          }
        } else {
          print("HERO: No daily progress found, using default values");
        }

        // Get the actual progress directly from the statistics provider for overall stats
        final actualProgress = statsProvider.memorizedPercentage;
        
        // Calculate more realistic progress values based on actual memorization status
        // For visual differentiation, create slight variations using the actual progress
        final newProgress = dailyProgressPercent;
        final recentProgress = dailyProgressPercent > 0.9 ? 1.0 : dailyProgressPercent * 0.95; 
        final oldProgress = dailyProgressPercent > 0.8 ? 1.0 : dailyProgressPercent * 0.9;
        
        // Debug output to help diagnose issues
        print("HeroSection: Building with daily progress: ${dailyProgressPercent * 100}%");

        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and streak counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحبًا بك',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
                        Text(
                          ArabicNumbers.formatDayCount(streak),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'يوم متتالي',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Google Fit style progress circles
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return SizedBox(
                        height: 200, // Fixed height to contain all circles
                        width: 200, // Fixed width to contain all circles
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ring - Old review
                            CircleProgress(
                              progress: dailyProgressPercent > 0.0 ? oldProgress : 0.0,
                              color: AppColors.tertiary,
                              size: 180,
                              strokeWidth: 8,
                            ),
                            
                            // Middle ring - Recent review
                            CircleProgress(
                              progress: dailyProgressPercent > 0.0 ? recentProgress : 0.0,
                              color: AppColors.secondary,
                              size: 150,
                              strokeWidth: 8,
                            ),
                            
                            // Inner ring - New memorization
                            CircleProgress(
                              progress: dailyProgressPercent > 0.0 ? newProgress : 0.0,
                              color: AppColors.primary,
                              size: 120,
                              strokeWidth: 8,
                            ),
                            
                            // Center text - ONLY show percentage here
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dailyProgressText, // Shows percentage like ٧٠٪
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'الإنجاز',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Activity summaries - Always show as X/Y format
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // New memorization
                  Container(
                    width: 95, // Fixed width for each stat column
                    height: 80, // Fixed height
                    child: _buildActivitySummary(
                      context,
                      icon: Icons.bolt, 
                      color: AppColors.primary,
                      bgColor: AppColors.primaryLight,
                      // ALWAYS show as verse counts in "X/Y" format 
                      value: _getCountDisplay(widget.completedNewVerses, widget.targetNewVerses),
                      label: 'حفظ جديد',
                    ),
                  ),
                  
                  // Recent review
                  Container(
                    width: 95, // Fixed width for each stat column
                    height: 80, // Fixed height
                    child: _buildActivitySummary(
                      context,
                      icon: Icons.refresh, 
                      color: AppColors.secondary,
                      bgColor: AppColors.secondaryLight,
                      // ALWAYS show as verse counts in "X/Y" format
                      value: _getCountDisplay(widget.completedRecentVerses, widget.targetRecentVerses),
                      label: 'مراجعة حديثة',
                    ),
                  ),
                  
                  // Old review
                  Container(
                    width: 95, // Fixed width for each stat column
                    height: 80, // Fixed height
                    child: _buildActivitySummary(
                      context,
                      icon: Icons.replay, 
                      color: AppColors.tertiary,
                      bgColor: AppColors.tertiaryLight,
                      // ALWAYS show as verse counts in "X/Y" format
                      value: _getCountDisplay(widget.completedOldVerses, widget.targetOldVerses),
                      label: 'مراجعة سابقة',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper method to format verse count display
  String _getCountDisplay(int completed, int target) {
    // If no target, show as 0/0
    if (target == 0) {
      return '٠/٠';
    }
    
    // If completed is greater than target, cap it at target (100% completion)
    int displayCompleted = completed > target ? target : completed;
    
    // Return in format "X/Y" using Arabic numerals
    return '${ArabicNumbers.toArabicDigits(displayCompleted)}/${ArabicNumbers.toArabicDigits(target)}';
  }
  
  Widget _buildActivitySummary(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Ensure the column uses minimum required space
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        // Use a SizedBox with fixed width to prevent overflow
        SizedBox(
          width: 80,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        // Use a SizedBox with fixed width to prevent overflow
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
