import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String description;
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const SettingsItem({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    this.minValue = 1,
    this.maxValue = 50,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Value selector
          Row(
            children: [
              // Decrease button
              Material(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: value > minValue
                      ? () => onChanged(value - 1)
                      : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.remove,
                        color: value > minValue
                            ? const Color(0xFF64748B)
                            : const Color(0xFFCBD5E1),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),

              // Value display
              Container(
                width: 40,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    ArabicNumbers.toArabicDigits(value),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),

              // Increase button
              Material(
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: value < maxValue
                      ? () => onChanged(value + 1)
                      : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: value < maxValue
                          ? const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFCBD5E1), Color(0xFFCBD5E1)],
                              begin: Alignment.center,
                              end: Alignment.center,
                            ),
                      boxShadow: value < maxValue
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
