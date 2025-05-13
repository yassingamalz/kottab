import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('عن التطبيق'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // App logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App name and version
                  Text(
                    'كتاب',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'رفيقك في حفظ القرآن',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'الإصدار 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // About text
                  _buildAboutSection(
                    context,
                    title: 'نبذة عن التطبيق',
                    content: 'تطبيق كتاب هو أداة مصممة لمساعدة المسلمين في حفظ القرآن الكريم بطريقة منظمة وفعالة. يستخدم التطبيق نظام المراجعة المتباعدة الذي يعتمد على أحدث النظريات العلمية في مجال الذاكرة والتعلم.',
                  ),

                  const SizedBox(height: 24),

                  _buildAboutSection(
                    context,
                    title: 'فلسفة التطبيق',
                    content: 'يؤمن فريق كتاب بأن حفظ القرآن الكريم يجب أن يكون متاحًا للجميع بطريقة سهلة ومنظمة. لذلك، صممنا تطبيقًا يجمع بين البساطة في الاستخدام والفعالية في النتائج، مما يساعد المستخدمين على بناء عادة يومية للحفظ والمراجعة.',
                  ),

                  const SizedBox(height: 24),

                  _buildAboutSection(
                    context,
                    title: 'فريق التطوير',
                    content: 'تم تطوير التطبيق بواسطة فريق من المبرمجين والمصممين المهتمين بخدمة القرآن الكريم وتيسير حفظه. نسعى دائمًا لتحسين التطبيق وإضافة ميزات جديدة بناءً على اقتراحات المستخدمين.',
                  ),

                  const SizedBox(height: 40),

                  // Links
                  _buildLinkButton(
                    context,
                    title: 'الموقع الإلكتروني',
                    icon: Icons.language,
                    onPressed: () {
                      // TODO: Open website
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildLinkButton(
                    context,
                    title: 'سياسة الخصوصية',
                    icon: Icons.privacy_tip,
                    onPressed: () {
                      // TODO: Show privacy policy
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildLinkButton(
                    context,
                    title: 'شروط الاستخدام',
                    icon: Icons.description,
                    onPressed: () {
                      // TODO: Show terms of service
                    },
                  ),

                  const SizedBox(height: 40),

                  // Copyright
                  Text(
                    '© 2025 كتاب. جميع الحقوق محفوظة.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build about section with title and content
  Widget _buildAboutSection(
      BuildContext context, {
        required String title,
        required String content,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  /// Build link button
  Widget _buildLinkButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }
}