import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';

class SeeAllButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const SeeAllButton({
    super.key,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed ?? () {},
      style: TextButton.styleFrom(
        foregroundColor: color ?? AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'مشاهدة الكل',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right, // Changed from chevron_left to chevron_right for correct RTL display
            size: 16,
            color: color ?? AppColors.primary,
          ),
        ],
      ),
    );
  }
}
