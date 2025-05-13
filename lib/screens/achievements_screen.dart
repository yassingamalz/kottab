import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإنجازات'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إنجازاتك',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'استمر في الحفظ والمراجعة لفتح المزيد من الإنجازات',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Achievement categories
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryTab(
                      context,
                      label: 'الكل',
                      isSelected: true,
                    ),
                    _buildCategoryTab(
                      context,
                      label: 'التتابع',
                      isSelected: false,
                    ),
                    _buildCategoryTab(
                      context,
                      label: 'الحفظ',
                      isSelected: false,
                    ),
                    _buildCategoryTab(
                      context,
                      label: 'المراجعة',
                      isSelected: false,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Unlocked achievements
              const Text(
                'الإنجازات المفتوحة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildAchievementItem(
                    context,
                    title: '١٠ أيام متتالية',
                    icon: Icons.emoji_events,
                    color: Colors.amber.shade700,
                  ),
                  _buildAchievementItem(
                    context,
                    title: 'حفظ سورة كاملة',
                    icon: Icons.menu_book,
                    color: AppColors.primary,
                  ),
                  _buildAchievementItem(
                    context,
                    title: '٥٠ مراجعة',
                    icon: Icons.refresh,
                    color: AppColors.blue,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Locked achievements
              const Text(
                'الإنجازات القادمة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildAchievementItem(
                    context,
                    title: '٣٠ يوم متتالي',
                    icon: Icons.emoji_events,
                    color: Colors.grey,
                    isLocked: true,
                  ),
                  _buildAchievementItem(
                    context,
                    title: 'حفظ ٥ سور',
                    icon: Icons.menu_book,
                    color: Colors.grey,
                    isLocked: true,
                  ),
                  _buildAchievementItem(
                    context,
                    title: '١٠٠ مراجعة',
                    icon: Icons.refresh,
                    color: Colors.grey,
                    isLocked: true,
                  ),
                  _buildAchievementItem(
                    context,
                    title: '١٠٠ آية محفوظة',
                    icon: Icons.bookmark,
                    color: Colors.grey,
                    isLocked: true,
                  ),
                  _buildAchievementItem(
                    context,
                    title: 'تحدي أسبوعي',
                    icon: Icons.star,
                    color: Colors.grey,
                    isLocked: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build category tab
  Widget _buildCategoryTab(
    BuildContext context, {
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        // Would handle category selection
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  // Build achievement item
  Widget _buildAchievementItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    bool isLocked = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade100 : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              if (isLocked)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isLocked ? Colors.grey : AppColors.textPrimary,
                fontWeight: isLocked ? FontWeight.normal : FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
