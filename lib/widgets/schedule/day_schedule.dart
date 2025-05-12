import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/date_formatter.dart';
import 'package:kottab/widgets/schedule/session_card.dart';
import '../../providers/schedule_provider.dart' as ScheduleProvider;

class DaySchedule extends StatelessWidget {
  final ScheduleProvider.DaySchedule day;

  const DaySchedule({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormatter.formatArabicDate(day.date);
    final shortFormattedDate = '${day.date.day} ${DateFormatter.getArabicMonthName(day.date.month)}';
    final dayName = DateFormatter.getArabicDayName(day.date.weekday);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: day.isToday ? AppColors.primaryLight.withOpacity(0.2) : null,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header with date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Day name with indicator
              Row(
                children: [
                  // Today indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: day.isToday ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Day name
                  Text(
                    day.isToday ? 'اليوم' : dayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: day.isToday ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),

              // Date
              Text(
                shortFormattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sessions grid
          if (day.sessions.isNotEmpty)
            Row(
              children: day.sessions.map((session) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SessionCard(session: session),
                ),
              )).toList(),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'لا توجد جلسات مجدولة',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}