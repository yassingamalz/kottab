import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/widgets/tutorial/tutorial_page.dart';

class TutorialScreen extends StatefulWidget {
  final bool isOnboarding;

  const TutorialScreen({
    super.key,
    this.isOnboarding = false,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Go to the next page
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Skip tutorial
  void _skipTutorial() {
    _finishTutorial();
  }

  /// Complete tutorial
  void _completeTutorial() {
    _finishTutorial();
  }

  /// Finish tutorial (either by completing or skipping)
  void _finishTutorial() {
    if (widget.isOnboarding) {
      // TODO: Navigate to main screen and mark onboarding as completed
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Tutorial pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    // Welcome page
                    TutorialPage(
                      title: 'مرحبًا بك في كتّاب',
                      description: 'رفيقك في رحلة حفظ القرآن الكريم',
                      image: _buildTutorialImage(1),
                      onNext: _nextPage,
                      onSkip: _skipTutorial,
                    ),

                    // Memorization tracking
                    TutorialPage(
                      title: 'تتبع حفظك',
                      description: 'سجّل تقدمك في الحفظ واستعرض إحصائياتك بسهولة',
                      image: _buildTutorialImage(2),
                      onNext: _nextPage,
                      onSkip: _skipTutorial,
                    ),

                    // Spaced repetition
                    TutorialPage(
                      title: 'المراجعة المتباعدة',
                      description: 'نظام ذكي يساعدك على جدولة المراجعات بناءً على أدائك',
                      image: _buildTutorialImage(3),
                      onNext: _nextPage,
                      onSkip: _skipTutorial,
                    ),

                    // Daily streak
                    TutorialPage(
                      title: 'الاستمرارية اليومية',
                      description: 'حافظ على تتابع يومي وشاهد إنجازاتك تتراكم',
                      image: _buildTutorialImage(4),
                      isLastPage: true,
                      onNext: _nextPage,
                      onSkip: _skipTutorial,
                      onComplete: _completeTutorial,
                    ),
                  ],
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a tutorial image placeholder
  /// In a real app, these would be actual illustrations
  Widget _buildTutorialImage(int index) {
    IconData iconData;
    Color color;

    switch (index) {
      case 1:
        iconData = Icons.menu_book;
        color = AppColors.primary;
        break;
      case 2:
        iconData = Icons.bar_chart;
        color = AppColors.blue;
        break;
      case 3:
        iconData = Icons.replay;
        color = AppColors.purple;
        break;
      case 4:
        iconData = Icons.local_fire_department;
        color = Colors.amber;
        break;
      default:
        iconData = Icons.help;
        color = AppColors.primary;
    }

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 120,
        color: color,
      ),
    );
  }
}