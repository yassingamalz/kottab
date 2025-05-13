import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';
import 'package:kottab/utils/date_formatter.dart';
import 'package:kottab/widgets/shared/circle_progress.dart';

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
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _newMemAnimation;
  late Animation<double> _recentReviewAnimation;
  late Animation<double> _oldReviewAnimation;

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
    _newMemAnimation = Tween<double>(
      begin: 0.0,
      end: widget.newMemProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _recentReviewAnimation = Tween<double>(
      begin: 0.0,
      end: widget.recentReviewProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _oldReviewAnimation = Tween<double>(
      begin: 0.0,
      end: widget.oldReviewProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(HeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.newMemProgress != widget.newMemProgress ||
        oldWidget.recentReviewProgress != widget.recentReviewProgress ||
        oldWidget.oldReviewProgress != widget.oldReviewProgress) {
      _initializeAnimations();
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Get overall average progress
  double _getOverallProgress() {
    return (widget.newMemProgress + widget.recentReviewProgress + widget.oldReviewProgress) / 3;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String formattedDate = DateFormatter.formatArabicDate(now);

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
                      ArabicNumbers.formatDayCount(widget.streak),
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
                          progress: _oldReviewAnimation.value,
                          color: AppColors.tertiary,
                          size: 180,
                          strokeWidth: 8,
                        ),
                        
                        // Middle ring - Recent review
                        CircleProgress(
                          progress: _recentReviewAnimation.value,
                          color: AppColors.secondary,
                          size: 150,
                          strokeWidth: 8,
                        ),
                        
                        // Inner ring - New memorization
                        CircleProgress(
                          progress: _newMemAnimation.value,
                          color: AppColors.primary,
                          size: 120,
                          strokeWidth: 8,
                        ),
                        
                        // Center text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ArabicNumbers.formatPercentage(_getOverallProgress()),
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
          
          // Activity summaries
          SizedBox(
            height: 100, // Fixed height to prevent overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // New memorization
                _buildActivitySummary(
                  context,
                  icon: Icons.bolt, 
                  color: AppColors.primary,
                  bgColor: AppColors.primaryLight,
                  value: '${ArabicNumbers.toArabicDigits(widget.completedNewVerses)}/${ArabicNumbers.toArabicDigits(widget.targetNewVerses)}',
                  label: 'حفظ جديد',
                ),
                
                // Recent review
                _buildActivitySummary(
                  context,
                  icon: Icons.refresh, 
                  color: AppColors.secondary,
                  bgColor: AppColors.secondaryLight,
                  value: '${ArabicNumbers.toArabicDigits(widget.completedRecentVerses)}/${ArabicNumbers.toArabicDigits(widget.targetRecentVerses)}',
                  label: 'مراجعة حديثة',
                ),
                
                // Old review
                _buildActivitySummary(
                  context,
                  icon: Icons.replay, 
                  color: AppColors.tertiary,
                  bgColor: AppColors.tertiaryLight,
                  value: '${ArabicNumbers.toArabicDigits(widget.completedOldVerses)}/${ArabicNumbers.toArabicDigits(widget.targetOldVerses)}',
                  label: 'مراجعة سابقة',
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
