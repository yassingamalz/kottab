import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/session_provider.dart';

class SessionTypeSelector extends StatelessWidget {
  final SessionType selectedType;
  final Function(SessionType) onTypeSelected;

  const SessionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الجلسة',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 12),

        // Type selectors
        Row(
          children: [
            // New memorization
            Expanded(
              child: _TypeOption(
                type: SessionType.newMemorization,
                title: 'حفظ جديد',
                icon: Icons.bolt,
                bgColor: AppColors.primaryLight,
                iconColor: AppColors.primary,
                isSelected: selectedType == SessionType.newMemorization,
                onTap: () => onTypeSelected(SessionType.newMemorization),
              ),
            ),

            const SizedBox(width: 8),

            // Recent review
            Expanded(
              child: _TypeOption(
                type: SessionType.recentReview,
                title: 'مراجعة حديثة',
                icon: Icons.refresh,
                bgColor: AppColors.blueLight,
                iconColor: AppColors.blue,
                isSelected: selectedType == SessionType.recentReview,
                onTap: () => onTypeSelected(SessionType.recentReview),
              ),
            ),

            const SizedBox(width: 8),

            // Old review
            Expanded(
              child: _TypeOption(
                type: SessionType.oldReview,
                title: 'مراجعة سابقة',
                icon: Icons.repeat,
                bgColor: AppColors.purpleLight,
                iconColor: AppColors.purple,
                isSelected: selectedType == SessionType.oldReview,
                onTap: () => onTypeSelected(SessionType.oldReview),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A single type option
class _TypeOption extends StatelessWidget {
  final SessionType type;
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.type,
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? bgColor.withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}