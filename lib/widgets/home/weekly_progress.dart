import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';
import 'package:kottab/widgets/shared/see_all_button.dart';

class WeeklyProgress extends StatelessWidget {
  final List<DailyProgressData> weekData;
  final VoidCallback? onViewAll;

  const WeeklyProgress({
    super.key,
    required this.weekData,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "See All" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تقدم الأسبوع',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SeeAllButton(onPressed: onViewAll),
            ],
          ),

          const SizedBox(height: 16),

          // Weekly progress rings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekData.map((data) => _buildDayProgressRing(context, data)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayProgressRing(BuildContext context, DailyProgressData data) {
    return Column(
      children: [
        // Day progress ring
        Stack(
          alignment: Alignment.center,
          children: [
            // Ring
            SizedBox(
              width: 40,
              height: 40,
              child: CustomPaint(
                painter: _CircleProgressPainter(
                  progress: data.progress,
                  color: data.isToday ? AppColors.primary : Colors.blueGrey.shade300,
                  backgroundColor: Colors.grey.shade100,
                  strokeWidth: 3,
                ),
              ),
            ),

            // Today indicator dot
            if (data.isToday)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 4),

        // Day abbreviation
        Text(
          data.shortName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: data.isToday ? FontWeight.bold : FontWeight.normal,
            color: data.isToday ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Paint for background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Paint for progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class DailyProgressData {
  final String name;
  final String shortName;
  final double progress;
  final bool isToday;

  const DailyProgressData({
    required this.name,
    required this.shortName,
    required this.progress,
    this.isToday = false,
  });
}
