import 'package:flutter/material.dart';
import 'package:kottab/widgets/help/faq_item.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأسئلة الشائعة'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            // General questions
            _CategoryHeader(title: 'أسئلة عامة'),

            FAQItem(
              question: 'ما هو تطبيق كتاب؟',
              answer: 'كتاب هو تطبيق مصمم لمساعدة المسلمين في حفظ القرآن الكريم بطريقة منظمة وفعالة. يستخدم التطبيق نظام المراجعة المتباعدة لتعزيز الحفظ على المدى الطويل.',
            ),

            FAQItem(
              question: 'هل التطبيق مجاني؟',
              answer: 'نعم، تطبيق كتاب مجاني بالكامل، ويمكن استخدام جميع الميزات دون الحاجة لدفع أي رسوم.',
            ),

            // Memorization questions
            _CategoryHeader(title: 'أسئلة حول الحفظ والمراجعة'),

            FAQItem(
              question: 'كيف يعمل نظام المراجعة المتباعدة؟',
              answer: 'يعتمد نظام المراجعة المتباعدة على تكرار المراجعة بفترات متزايدة تدريجيًا. كلما زادت جودة حفظك للآيات، زادت الفترة بين المراجعات. هذا يساعد على تثبيت الحفظ في الذاكرة طويلة المدى.',
            ),

            FAQItem(
              question: 'ما هو العدد المثالي للآيات التي يمكن حفظها يوميًا؟',
              answer: 'يختلف العدد المثالي من شخص لآخر. للمبتدئين، ننصح بالبدء بـ 5 آيات يوميًا والتركيز على جودة الحفظ والمراجعة. يمكنك زيادة العدد تدريجيًا مع اكتساب الخبرة.',
            ),

            FAQItem(
              question: 'كيف أسجل مراجعتي للآيات؟',
              answer: 'يمكنك تسجيل المراجعة من خلال الضغط على زر "+" في الشاشة الرئيسية واختيار نوع الجلسة "مراجعة". ثم اختر السورة والآيات وقيّم جودة المراجعة.',
            ),

            // Technical questions
            _CategoryHeader(title: 'أسئلة تقنية'),

            FAQItem(
              question: 'هل يمكنني نقل بياناتي إلى جهاز آخر؟',
              answer: 'نعم، يمكنك تصدير بياناتك من إعدادات التطبيق، ثم استيرادها في الجهاز الآخر. قريبًا سنضيف ميزة مزامنة البيانات عبر الإنترنت.',
            ),

            FAQItem(
              question: 'هل التطبيق يعمل بدون إنترنت؟',
              answer: 'نعم، يمكنك استخدام جميع الميزات الأساسية للتطبيق بدون اتصال بالإنترنت.',
            ),

            FAQItem(
              question: 'كيف يمكنني الإبلاغ عن مشكلة أو اقتراح ميزة؟',
              answer: 'يمكنك التواصل معنا عبر البريد الإلكتروني support@kottabapp.com أو من خلال قسم "تواصل معنا" في صفحة المساعدة.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Category header for FAQ
class _CategoryHeader extends StatelessWidget {
  final String title;

  const _CategoryHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}