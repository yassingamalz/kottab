import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/session_provider.dart';
import 'package:kottab/providers/statistics_provider.dart';
import 'package:kottab/providers/quran_provider.dart';
import 'package:kottab/providers/settings_provider.dart';
import 'package:kottab/providers/schedule_provider.dart' as ScheduleProvider;
import 'package:kottab/widgets/sessions/session_type_selector.dart';
import 'package:kottab/widgets/sessions/verse_range_selector.dart';
import 'package:kottab/widgets/sessions/session_quality_selector.dart';
import 'package:kottab/widgets/shared/custom_snackbar.dart';

class AddSessionModal extends StatefulWidget {
  const AddSessionModal({super.key});

  @override
  State<AddSessionModal> createState() => _AddSessionModalState();
}

class _AddSessionModalState extends State<AddSessionModal> {
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Handle save button press
  Future<void> _handleSave(BuildContext context, SessionProvider provider) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await provider.saveCurrentSession();

      if (!mounted) return;

      if (success) {
        // Force refresh all providers after session is saved
        final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        final quranProvider = Provider.of<QuranProvider>(context, listen: false);
        final scheduleProvider = Provider.of<ScheduleProvider.ScheduleProvider>(context, listen: false);
        
        // Refresh all data
        statsProvider.refreshData();
        settingsProvider.refreshData();
        quranProvider.refreshData();
        scheduleProvider.refreshData();
        
        // Close the modal
        Navigator.of(context).pop();
        
        // Show success message
        showCustomSnackBar(
          context: context,
          message: 'تم تسجيل الجلسة بنجاح!',
          type: SnackBarType.success,
        );
        
        // Force a rebuild of the providers after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            // This extra notifyListeners call helps ensure UI updates
            provider.notifyListeners();
            statsProvider.notifyListeners();
          }
        });
      } else {
        showCustomSnackBar(
          context: context,
          message: 'حدث خطأ أثناء تسجيل الجلسة. يرجى المحاولة مرة أخرى.',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;

      showCustomSnackBar(
        context: context,
        message: 'حدث خطأ أثناء تسجيل الجلسة. يرجى المحاولة مرة أخرى.',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, child) {
        // Get the current session being edited
        final session = sessionProvider.currentSession;

        if (session == null) {
          return const SizedBox.shrink();
        }

        // Update notes controller
        if (!_isSubmitting) {
          _notesController.text = session.notes;
        }

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تسجيل جلسة حفظ/مراجعة',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      sessionProvider.clearCurrentSession();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Divider(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Session type selector
                      SessionTypeSelector(
                        selectedType: session.type,
                        onTypeSelected: (type) {
                          sessionProvider.updateSessionType(type);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Verse range selector
                      VerseRangeSelector(
                        surahs: sessionProvider.surahs,
                        selectedSurahId: session.surahId,
                        startVerse: session.startVerse,
                        endVerse: session.endVerse,
                        onSurahChanged: (surahId) {
                          sessionProvider.updateSessionSurah(surahId);
                        },
                        onRangeChanged: (start, end) {
                          sessionProvider.updateSessionVerseRange(start, end);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Quality selector
                      SessionQualitySelector(
                        quality: session.quality,
                        onQualityChanged: (quality) {
                          sessionProvider.updateSessionQuality(quality);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Notes
                      Text(
                        'ملاحظات (اختياري)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'أضف ملاحظات حول الجلسة...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          sessionProvider.updateSessionNotes(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSubmitting
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                sessionProvider.clearCurrentSession();
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'إلغاء',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _isSubmitting
                            ? null
                            : () => _handleSave(context, sessionProvider),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'حفظ',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
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
      },
    );
  }
}
