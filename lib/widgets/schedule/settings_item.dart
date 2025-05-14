import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';

class SettingsItem extends StatefulWidget {
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
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  late int _value;
  bool _isChanging = false;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(SettingsItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update from parent if we're not in the middle of changing values
    if (!_isChanging && oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

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
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.description,
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
                  onTap: _value > widget.minValue
                      ? () => _changeValue(_value - 1)
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
                        color: _value > widget.minValue
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
                    ArabicNumbers.toArabicDigits(_value),
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
                  onTap: _value < widget.maxValue
                      ? () => _changeValue(_value + 1)
                      : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: _value < widget.maxValue
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
                      boxShadow: _value < widget.maxValue
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

  void _changeValue(int newValue) {
    // Set flag that we're changing values
    _isChanging = true;
    
    setState(() {
      _value = newValue;
    });
    
    // Use debounce to avoid multiple rapid updates
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onChanged(_value);
        // End the change after notification
        _isChanging = false;
      }
    });
  }
}
