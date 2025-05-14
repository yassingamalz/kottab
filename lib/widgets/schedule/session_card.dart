import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/schedule_provider.dart';

import '../../config/app_theme.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/schedule_provider.dart' as ScheduleProvider;

class SessionCard extends StatelessWidget {
  final ScheduleProvider.ScheduledSession session;

  const SessionCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    // Configure colors and styling based on session type
    late final Color bgColor;
    late final Color textColor;
    late final Color borderColor;
    late final String typeText;
    late final IconData icon;
    late final LinearGradient gradient;

    switch (session.type) {
      case ScheduleProvider.SessionType.newMemorization:
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF10B981);
        borderColor = const Color(0xFF10B981);
        typeText = 'جديد';
        icon = Icons.bolt;
        gradient = const LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        );
        break;
      case ScheduleProvider.SessionType.recentReview:
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF3B82F6);
        borderColor = const Color(0xFF3B82F6);
        typeText = 'مراجعة ١';
        icon = Icons.refresh;
        gradient = const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        );
        break;
      case ScheduleProvider.SessionType.oldReview:
        bgColor = const Color(0xFFF5F3FF);
        textColor = const Color(0xFF8B5CF6);
        borderColor = const Color(0xFF8B5CF6);
        typeText = 'مراجعة ٢';
        icon = Icons.replay;
        gradient = const LinearGradient(
          colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        );
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border(
          right: BorderSide(
            color: borderColor,
            width: 4,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            // Handle session tap
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Session type label
                    Row(
                      children: [
                        Icon(
                          icon,
                          color: textColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          typeText,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Surah and verse range
                    Row(
                      children: [
                        Text(
                          'سورة ${session.surahId}:',
                          style: TextStyle(
                            color: const Color(0xFF334155),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${session.verseRange}',
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Completed badge
                if (session.isCompleted)
                  Positioned(
                    top: -10,
                    left: -10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
