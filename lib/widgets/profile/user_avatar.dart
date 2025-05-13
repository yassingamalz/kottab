import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final Color backgroundColor;
  final String? avatarUrl;

  const UserAvatar({
    super.key,
    this.radius = 24,
    this.backgroundColor = AppColors.primaryLight,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: avatarUrl != null
          ? null // If we have an avatar URL, the CircleAvatar will use backgroundImage
          : Icon(
        Icons.person,
        size: radius * 1.2,
        color: AppColors.primary,
      ),
    );
  }
}