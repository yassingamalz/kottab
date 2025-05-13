import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';

class WeeklyDetailScreen extends StatelessWidget {
  const WeeklyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل تقدم الأسبوع'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'أداء الأسبوع',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Weekly chart visualization
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      final isToday = index == 4; // Example: Wednesday is today
                      final height = 100.0 + (index % 3) * 30.0; // Varied heights
                      
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            height: height,
                            decoration: BoxDecoration(
                              color: isToday ? AppColors.primary : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getDayAbbreviation(index),
                            style: TextStyle(
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Weekly stats
              const Text(
                'إحصائيات الأسبوع',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildStatCard(
                context, 
                title: 'مجموع الآيات المحفوظة', 
                value: '٧٥', 
                icon: Icons.menu_book,
                color: AppColors.primary,
              ),
              
              const SizedBox(height: 12),
              
              _buildStatCard(
                context, 
                title: 'عدد جلسات المراجعة', 
                value: '١٢', 
                icon: Icons.refresh,
                color: AppColors.blue,
              ),
              
              const SizedBox(height: 12),
              
              _buildStatCard(
                context, 
                title: 'نسبة الإنجاز', 
                value: '٨٥٪', 
                icon: Icons.trending_up,
                color: Colors.amber.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Get day abbreviation
  String _getDayAbbreviation(int index) {
    switch (index) {
      case 0: return 'س';
      case 1: return 'ح';
      case 2: return 'ن';
      case 3: return 'ث';
      case 4: return 'ر';
      case 5: return 'خ';
      case 6: return 'ج';
      default: return '';
    }
  }
  
  // Build stat card
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
