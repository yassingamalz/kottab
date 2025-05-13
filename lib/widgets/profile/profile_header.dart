import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/models/user_model.dart';
import 'package:kottab/widgets/profile/user_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      color: AppColors.primary,
      child: Column(
        children: [
          // User avatar and edit button
          Row(
            children: [
              // Avatar
              const UserAvatar(
                radius: 32,
                backgroundColor: Colors.white,
              ),

              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User name
                    Text(
                      user?.name.isNotEmpty == true
                          ? user!.name
                          : 'ضيف',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Streak
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user?.streak ?? 0} يوم متتالي',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Edit button
              IconButton(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit, color: Colors.white),
                tooltip: 'تعديل الملف الشخصي',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Memorized verses
              _buildStat(
                context,
                value: user?.totalMemorizedVerses ?? 0,
                label: 'آية محفوظة',
              ),

              // Progress percentage
              _buildStat(
                context,
                value: ((user?.quranProgress ?? 0) * 100).round(),
                label: '% من القرآن',
                isPercentage: true,
              ),

              // Days active
              _buildStat(
                context,
                value: user?.dailyProgress.length ?? 0,
                label: 'يوم نشط',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a stat item
  Widget _buildStat(
      BuildContext context, {
        required int value,
        required String label,
        bool isPercentage = false,
      }) {
    return Column(
      children: [
        Text(
          isPercentage ? '$value%' : value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}