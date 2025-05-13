import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/screens/help/tutorial_screen.dart';
import 'package:kottab/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:kottab/providers/settings_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _hasCompletedTutorial = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Set tutorial as completed
  void _setTutorialComplete() {
    setState(() {
      _hasCompletedTutorial = true;
    });
  }

  /// Complete onboarding and navigate to main app
  void _completeOnboarding() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    // Update user name if provided
    if (_nameController.text.isNotEmpty) {
      await settingsProvider.setUserName(_nameController.text);
    }

    // Save onboarding completed status
    // In a real app, you would save this to SharedPreferences

    // Navigate to main screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCompletedTutorial) {
      // Show tutorial first
      return TutorialScreen(
        isOnboarding: true,
        // Override normal completion to mark tutorial as completed
        // and then show the profile setup
      );
    }

    // After tutorial, show profile setup
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile setup header
                const SizedBox(height: 40),

                Center(
                  child: Text(
                    'أكمل ملفك الشخصي',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: Text(
                    'أضف اسمك لتخصيص تجربتك',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // User avatar (placeholder)
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Name field
                TextField(
                  controller: _nameController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'ملاحظة: يمكنك تخطي هذه الخطوة وإضافة اسمك لاحقًا من الإعدادات.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const Spacer(),

                // Complete button
                ElevatedButton(
                  onPressed: _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'بدء الاستخدام',
                    style: TextStyle(
                      fontSize: 18,
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