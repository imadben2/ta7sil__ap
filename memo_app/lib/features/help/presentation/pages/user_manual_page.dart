import 'package:flutter/material.dart';

/// صفحة دليل المستخدم
/// User Manual Page - Complete guide in Arabic
class UserManualPage extends StatelessWidget {
  const UserManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'دليل المستخدم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Sections
          _buildSection(
            icon: Icons.home_rounded,
            iconColor: const Color(0xFF7C3AED),
            title: '1. الصفحة الرئيسية',
            content: '''الصفحة الرئيسية هي نقطة انطلاقك اليومية.

ماذا ستجد هنا:
• إحصائياتك: النقاط، عدد أيام المتابعة، وقت الدراسة
• جلسات اليوم: الحصص المجدولة لهذا اليوم
• موادك الدراسية: أهم المواد حسب المعامل
• الدورات والاختبارات الموصى بها

نصيحة: اسحب للأسفل لتحديث البيانات.''',
          ),

          _buildSection(
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFF10B981),
            title: '2. المخطط الذكي',
            content: '''ميزة فريدة تنشئ لك جدول دراسي مخصص تلقائياً!

كيفية الاستخدام:
1. اذهب إلى "المخطط" من القائمة السفلية
2. أضف موادك من تبويب "المواد"
3. أضف تواريخ امتحاناتك من تبويب "الاختبارات"
4. اضغط على "إنشاء جدول ذكي"
5. سيُنشئ التطبيق جدولاً يراعي صعوبة كل مادة وموعد امتحانها

إدارة الجلسات:
• اضغط على أي جلسة لرؤية تفاصيلها
• اضغط "ابدأ" لبدء جلسة الدراسة
• يمكنك إيقاف الجلسة مؤقتاً أو إنهاءها
• الجلسات المكتملة تُكسبك نقاطاً!

التحليلات:
• نسبة إنجاز الجلسات
• الوقت المستثمر في كل مادة
• تطور أدائك مع الوقت''',
          ),

          _buildSection(
            icon: Icons.library_books_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: '3. مكتبة المحتوى',
            content: '''مكتبة شاملة تحتوي على الدروس والملخصات.

كيفية التصفح:
1. اختر المادة التي تريدها
2. ستظهر الوحدات والفصول
3. اضغط على أي فصل لرؤية المحتوى
4. شاهد الفيديوهات أو اقرأ الملخصات

المفضلة:
• اضغط على القلب لحفظ أي محتوى في المفضلة
• الوصول للمفضلة من أيقونة المفضلة في الأعلى''',
          ),

          _buildSection(
            icon: Icons.quiz_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: '4. الاختبارات',
            content: '''اختبر معلوماتك مع مئات الأسئلة!

أنواع الاختبارات:
• تدريب: بدون وقت، للتعلم
• موقوت: مع عداد زمني، للتحدي
• محاكاة: تجربة امتحان حقيقية

مستويات الصعوبة:
• سهل (أخضر)
• متوسط (أصفر)
• صعب (أحمر)

بعد الاختبار:
• راجع إجاباتك
• اطلع على الشرح لكل سؤال
• تابع تطور درجاتك''',
          ),

          _buildSection(
            icon: Icons.school_rounded,
            iconColor: const Color(0xFFEF4444),
            title: '5. أرشيف البكالوريا',
            content: '''مواضيع السنوات الماضية بين يديك!

التصفح:
• حسب السنة (2024، 2023، ...)
• حسب المادة
• حسب الدورة (عادية/استدراكية)

المحاكاة:
1. اختر موضوعاً
2. اضغط "بدء المحاكاة"
3. حل في الوقت المحدد
4. قيّم إجاباتك
5. قارن مع المعدل الوطني''',
          ),

          _buildSection(
            icon: Icons.style_rounded,
            iconColor: const Color(0xFFEC4899),
            title: '6. البطاقات التعليمية',
            content: '''أداة قوية للحفظ باستخدام التكرار المتباعد.

ما هو التكرار المتباعد؟
تقنية علمية تُعيد عرض المعلومات في أوقات مدروسة لتثبيتها في الذاكرة طويلة المدى.

كيفية الاستخدام:
1. اختر مجموعة بطاقات
2. اضغط "ابدأ المراجعة"
3. لكل بطاقة:
   - اقرأ السؤال
   - حاول تذكر الإجابة
   - اقلب البطاقة
   - قيّم نفسك (سهل/متوسط/صعب)
4. البطاقات الصعبة ستظهر أكثر

الإحصائيات:
• عدد البطاقات المُتقنة
• البطاقات المستحقة للمراجعة
• نسبة الإتقان لكل مجموعة''',
          ),

          _buildSection(
            icon: Icons.play_circle_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: '7. الدورات المدفوعة',
            content: '''دورات فيديو احترافية مع أفضل الأساتذة.

محتوى كل دورة:
• فيديوهات مشروحة بالتفصيل
• ملفات PDF للتحميل
• اختبارات بعد كل درس
• شهادة إتمام

كيفية الاشتراك:
1. اختر الدورة
2. اضغط "اشتراك"
3. اختر طريقة الدفع
4. أرسل إيصال الدفع
5. انتظر التفعيل (خلال 24 ساعة)

تتبع التقدم:
• شريط تقدم لكل دورة
• علامة صح للدروس المكتملة''',
          ),

          _buildSection(
            icon: Icons.event_note_rounded,
            iconColor: const Color(0xFF14B8A6),
            title: '8. برنامج 98 يوم',
            content: '''برنامج مراجعة مكثف للتحضير النهائي للبكالوريا.

البرنامج يشمل:
• جدول يومي لمدة 98 يوم
• مواضيع محددة لكل يوم
• ملفات PDF للتحميل
• تتبع الإنجاز اليومي

المكافآت:
• أكمل أسبوعاً كاملاً واحصل على مكافأة
• تنافس مع الآخرين على لوحة المتصدرين''',
          ),

          _buildSection(
            icon: Icons.person_rounded,
            iconColor: const Color(0xFF6366F1),
            title: '9. الملف الشخصي',
            content: '''الإعدادات المتاحة:
• تعديل الاسم والصورة
• تغيير الشعبة والسنة
• إعدادات الإشعارات
• الوضع الليلي/النهاري
• تغيير كلمة المرور
• ترتيب التبويبات

إدارة الأجهزة:
• عرض الأجهزة المتصلة
• تسجيل الخروج من جهاز آخر''',
          ),

          _buildTipsSection(),

          _buildContactSection(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'مرحباً بك في تطبيق تحصيل!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'التطبيق الذكي للتحضير للبكالوريا',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          children: [
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    final tips = [
      'ابدأ يومك بالتطبيق: راجع جدول اليوم صباحاً',
      'أكمل الجلسات: لا تتخطى الجلسات المجدولة',
      'راجع بالبطاقات: 15 دقيقة يومياً تصنع فرقاً',
      'حل الاختبارات: اختبر نفسك بانتظام',
      'تابع التحليلات: راقب تقدمك أسبوعياً',
      'فعّل الإشعارات: ليذكرك التطبيق بالجلسات',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFEF3C7),
            const Color(0xFFFDE68A).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '10. نصائح ذهبية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF92400E),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFF06B6D4),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'هل تحتاج مساعدة؟',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'تواصل معنا عبر:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildContactChip(
                icon: Icons.email_outlined,
                label: 'support@ta7sil.app',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildContactChip(
                icon: Icons.camera_alt_outlined,
                label: '@ta7sil_app',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
