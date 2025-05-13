import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';

class SessionQualitySelector extends StatelessWidget {
  final double quality;
  final Function(double) onQualityChanged;

  const SessionQualitySelector({
    super.key,
    required this.quality,
    required this.onQualityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'جودة الحفظ/المراجعة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              ArabicNumbers.formatPercentage(quality),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getQualityColor(quality),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quality slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 10,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 24,
            ),
            activeTrackColor: _getQualityColor(quality),
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: _getQualityColor(quality),
            overlayColor: _getQualityColor(quality).withOpacity(0.2),
          ),
          child: Slider(
            value: quality,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: onQualityChanged,
          ),
        ),

        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ضعيف',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'متوسط',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'ممتاز',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quality description
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getQualityColor(quality).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getQualityColor(quality).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getQualityIcon(quality),
                color: _getQualityColor(quality),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getQualityDescription(quality),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getQualityColor(quality),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get color based on quality value
  Color _getQualityColor(double value) {
    if (value >= 0.8) {
      return AppColors.primary;
    } else if (value >= 0.5) {
      return Colors.amber.shade700;
    } else {
      return Colors.red.shade700;
    }
  }

  /// Get icon based on quality value
  IconData _getQualityIcon(double value) {
    if (value >= 0.8) {
      return Icons.sentiment_very_satisfied;
    } else if (value >= 0.5) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }

  /// Get description based on quality value
  String _getQualityDescription(double value) {
    if (value >= 0.8) {
      return 'ممتاز! حفظ/مراجعة متقنة وقوية.';
    } else if (value >= 0.5) {
      return 'حفظ/مراجعة جيدة، تحتاج لبعض التعزيز.';
    } else {
      return 'ضعيف، تحتاج إلى مزيد من المراجعة والتكرار.';
    }
  }
}