import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/screens/help/about_screen.dart';
import 'package:kottab/screens/help/faq_screen.dart';
import 'package:kottab/screens/help/tutorial_screen.dart';
import 'package:kottab/widgets/help/help_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مساعدة ودعم'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'كيف يمكننا مساعدتك؟',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'اختر أحد الخيارات أدناه للحصول على المساعدة',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Help options
              Row(
                children: [
                  // Tutorial
                  Expanded(
                    child: HelpCard(
                      title: 'شاهد التعليمات',
                      description: 'تعرف على كيفية استخدام التطبيق',
                      icon: Icons.slideshow,
                      iconColor: AppColors.blue,
                      bgColor: AppColors.blueLight,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const TutorialScreen()),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // FAQ
                  Expanded(
                    child: HelpCard(
                      title: 'الأسئلة الشائعة',
                      description: 'إجابات للأسئلة المتكررة',
                      icon: Icons.question_answer,
                      iconColor: AppColors.purple,
                      bgColor: AppColors.purpleLight,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const FAQScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  // Contact us
                  Expanded(
                    child: HelpCard(
                      title: 'تواصل معنا',
                      description: 'تواصل مع فريق الدعم',
                      icon: Icons.mail,
                      iconColor: Colors.amber.shade700,
                      bgColor: Colors.amber.shade100,
                      onTap: () {
                        _showContactDialog(context);
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // About
                  Expanded(
                    child: HelpCard(
                      title: 'عن التطبيق',
                      description: 'معلومات عن التطبيق والإصدار',
                      icon: Icons.info,
                      iconColor: AppColors.primary,
                      bgColor: AppColors.primaryLight,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AboutScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Tips section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'نصائح سريعة',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Quick tips
                    _buildTip(
                      context,
                      title: 'التتابع اليومي',
                      description: 'حافظ على تتابع يومي للحصول على أفضل النتائج في الحفظ.',
                    ),

                    const SizedBox(height: 12),

                    _buildTip(
                      context,
                      title: 'المراجعة المنتظمة',
                      description: 'راجع محفوظاتك القديمة بانتظام لتثبيت الحفظ.',
                    ),

                    const SizedBox(height: 12),

                    _buildTip(
                      context,
                      title: 'استخدم الإشعارات',
                      description: 'فعّل الإشعارات للتذكير بالحفظ والمراجعة.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a tip widget
  Widget _buildTip(
      BuildContext context, {
        required String title,
        required String description,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Show contact us dialog
  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تواصل معنا'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mail,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'يمكنك التواصل معنا عبر:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('البريد الإلكتروني'),
              subtitle: const Text('support@kottabapp.com'),
              onTap: () {
                // TODO: Open email client
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('مراسلة مباشرة'),
              subtitle: const Text('ارسل لنا رسالة مباشرة'),
              onTap: () {
                // TODO: Open chat support
                Navigator.of(context).pop();
                _showFeatureComingSoonDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  /// Show feature coming soon dialog
  void _showFeatureComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قادم قريباً'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.engineering,
              color: AppColors.primary,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'هذه الميزة قادمة في الإصدارات القادمة. ترقبوا المزيد!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}