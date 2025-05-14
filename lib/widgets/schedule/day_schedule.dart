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
        color: day.isToday 
            ? const Color(0xFFF0FDF9)
            : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: day.isToday ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
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
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: day.isToday 
                        ? AppColors.primary
                        : const Color(0xFFE2E8F0),
                      boxShadow: day.isToday ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Day name
                  Text(
                    day.isToday ? 'اليوم' : dayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: day.isToday 
                        ? AppColors.primary
                        : const Color(0xFF0F172A),
                      fontWeight: day.isToday ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Date
              Text(
                shortFormattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sessions grid
          if (day.sessions.isNotEmpty)
            Column(
              children: day.sessions.map((session) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SessionCard(session: session),
              )).toList(),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'لا توجد جلسات مجدولة',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
