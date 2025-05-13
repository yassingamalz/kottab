import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/models/surah_model.dart';
import 'package:kottab/utils/arabic_numbers.dart';

class VerseRangeSelector extends StatefulWidget {
  final List<Surah> surahs;
  final int selectedSurahId;
  final int startVerse;
  final int endVerse;
  final Function(int) onSurahChanged;
  final Function(int, int) onRangeChanged;

  const VerseRangeSelector({
    super.key,
    required this.surahs,
    required this.selectedSurahId,
    required this.startVerse,
    required this.endVerse,
    required this.onSurahChanged,
    required this.onRangeChanged,
  });

  @override
  State<VerseRangeSelector> createState() => _VerseRangeSelectorState();
}

class _VerseRangeSelectorState extends State<VerseRangeSelector> {
  late int _selectedSurahId;
  late int _startVerse;
  late int _endVerse;
  late Surah _selectedSurah;

  @override
  void initState() {
    super.initState();
    _selectedSurahId = widget.selectedSurahId;
    _startVerse = widget.startVerse;
    _endVerse = widget.endVerse;
    _selectedSurah = _findSelectedSurah();
  }

  @override
  void didUpdateWidget(VerseRangeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSurahId != widget.selectedSurahId ||
        oldWidget.startVerse != widget.startVerse ||
        oldWidget.endVerse != widget.endVerse) {
      _selectedSurahId = widget.selectedSurahId;
      _startVerse = widget.startVerse;
      _endVerse = widget.endVerse;
      _selectedSurah = _findSelectedSurah();
    }
  }

  /// Find the selected surah from the list
  Surah _findSelectedSurah() {
    return widget.surahs.firstWhere(
          (surah) => surah.id == _selectedSurahId,
      orElse: () => widget.surahs.first,
    );
  }

  /// Handle surah change
  void _handleSurahChange(int? value) {
    if (value == null) return;

    setState(() {
      _selectedSurahId = value;
      _selectedSurah = _findSelectedSurah();

      // Reset verse range
      _startVerse = 1;
      _endVerse = _calculateDefaultEndVerse();
    });

    widget.onSurahChanged(_selectedSurahId);
    widget.onRangeChanged(_startVerse, _endVerse);
  }

  /// Handle start verse change
  void _handleStartVerseChange(int? value) {
    if (value == null) return;

    setState(() {
      _startVerse = value;

      // Ensure end verse is >= start verse
      if (_endVerse < _startVerse) {
        _endVerse = _startVerse;
      }
    });

    widget.onRangeChanged(_startVerse, _endVerse);
  }

  /// Handle end verse change
  void _handleEndVerseChange(int? value) {
    if (value == null) return;

    setState(() {
      _endVerse = value;
    });

    widget.onRangeChanged(_startVerse, _endVerse);
  }

  /// Calculate default end verse based on start verse and surah
  int _calculateDefaultEndVerse() {
    int end = _startVerse + 4; // Default to start + 4 (5 verses)

    // Ensure we don't exceed the surah's verse count
    if (end > _selectedSurah.verseCount) {
      end = _selectedSurah.verseCount;
    }

    return end;
  }

  /// Generate items for the surah dropdown
  List<DropdownMenuItem<int>> _generateSurahItems() {
    return widget.surahs.map((surah) {
      return DropdownMenuItem<int>(
        value: surah.id,
        child: Text('${surah.id}. ${surah.arabicName}'),
      );
    }).toList();
  }

  /// Generate items for the start verse dropdown
  List<DropdownMenuItem<int>> _generateStartVerseItems() {
    return List.generate(_selectedSurah.verseCount, (index) {
      final verse = index + 1;
      return DropdownMenuItem<int>(
        value: verse,
        child: Text(ArabicNumbers.toArabicDigits(verse)),
      );
    });
  }

  /// Generate items for the end verse dropdown
  List<DropdownMenuItem<int>> _generateEndVerseItems() {
    return List.generate(
      _selectedSurah.verseCount - _startVerse + 1,
          (index) {
        final verse = _startVerse + index;
        return DropdownMenuItem<int>(
          value: verse,
          child: Text(ArabicNumbers.toArabicDigits(verse)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نطاق الآيات',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 16),

        // Surah selector
        DropdownButtonFormField<int>(
          value: _selectedSurahId,
          decoration: InputDecoration(
            labelText: 'السورة',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _generateSurahItems(),
          onChanged: _handleSurahChange,
        ),

        const SizedBox(height: 16),

        // Verse range selectors
        Row(
          children: [
            // Start verse
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'من الآية',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _startVerse,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _generateStartVerseItems(),
                    onChanged: _handleStartVerseChange,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // End verse
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إلى الآية',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _endVerse,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _generateEndVerseItems(),
                    onChanged: _handleEndVerseChange,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عدد الآيات:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                ArabicNumbers.toArabicDigits(_endVerse - _startVerse + 1),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}