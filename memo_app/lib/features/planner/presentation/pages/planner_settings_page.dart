import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import '../../domain/entities/planner_settings.dart';
import '../widgets/shared/planner_design_constants.dart';

/// Planner Settings Page
///
/// Configuration UI for all planner settings:
/// - Study hours (start/end time)
/// - Sleep schedule
/// - Energy levels (morning/afternoon/evening/night)
/// - Prayer times integration
/// - Exercise periods
///
/// Modern design with gradient header and beautiful cards
class PlannerSettingsPage extends StatelessWidget {
  const PlannerSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.95),
                  const Color(0xFF8B5CF6).withOpacity(0.95),
                ],
              ),
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'إعدادات المخطط',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'جاري تحميل الإعدادات...',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.errorMessage != null) {
              return _buildErrorView(context, state);
            }

            if (state.hasSettings) {
              return _buildSettingsContent(context, state.settings!);
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (!state.hasSettings) return const SizedBox.shrink();

            return FloatingActionButton.extended(
              onPressed: () async {
                // Force reload settings to ensure they're saved
                await context.read<SettingsCubit>().refreshSettings();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'تم حفظ الإعدادات بنجاح',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              backgroundColor: const Color(0xFF6366F1),
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: const Text(
                'حفظ الإعدادات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, SettingsState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: PlannerDesignConstants.modernCardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'حدث خطأ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'حدث خطأ غير متوقع',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<SettingsCubit>().loadSettings(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, PlannerSettings settings) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Hero Header with gradient
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                const Color(0xFF6366F1).withOpacity(0.95),
                const Color(0xFF8B5CF6).withOpacity(0.95),
              ],
            ),
          ),
        ),

        // Content with rounded top corners
        Transform.translate(
          offset: const Offset(0, -30),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Study Hours Section
                      _buildSectionHeader(
                        context,
                        'ساعات الدراسة',
                        Icons.schedule_rounded,
                        const Color(0xFF6366F1),
                        helpText: 'حدد الفترة الزمنية المتاحة للدراسة يومياً.\n\n• وقت البداية: الوقت الذي تبدأ فيه يومك الدراسي\n• وقت النهاية: آخر وقت يمكنك الدراسة فيه\n\nسيتم توزيع جلسات الدراسة تلقائياً ضمن هذه الفترة مع مراعاة أوقات النوم والراحة.',
                      ),
                      const SizedBox(height: 12),
                      _buildStudyHoursCard(context, settings),
                      const SizedBox(height: 20),

                      // Daily Study Goal Section
                      _buildSectionHeader(
                        context,
                        'الهدف اليومي',
                        Icons.flag_rounded,
                        const Color(0xFFF59E0B),
                        helpText: 'حدد عدد ساعات الدراسة الفعلية التي تريد تحقيقها يومياً.\n\n• يجب أن يكون الهدف أقل من أو يساوي الوقت المتاح\n• سيتم توزيع هذه الساعات على المواد حسب الأولوية\n• ننصح بعدم تجاوز 70% من الوقت المتاح لتفادي الإرهاق',
                      ),
                      const SizedBox(height: 12),
                      _buildDailyGoalCard(context, settings),
                      const SizedBox(height: 20),

                      // Session Duration by Coefficient Section (MOVED HERE)
                      _buildSectionHeader(
                        context,
                        'مدة الجلسة حسب المعامل',
                        Icons.calculate_rounded,
                        const Color(0xFF3B82F6),
                        helpText: 'خصص مدة جلسة مناسبة لكل معامل.\n\n• المواد ذات المعامل الأعلى تستحق وقتاً أطول\n• يمكنك التحكم بالدقائق (5 دقائق) والساعات (60 دقيقة)\n• المدة الموصى بها: 30-90 دقيقة للتركيز الأمثل',
                      ),
                      const SizedBox(height: 12),
                      _buildSessionDurationByCoefficientCard(context, settings),
                      const SizedBox(height: 20),

                      // Sleep Schedule Section
                      _buildSectionHeader(
                        context,
                        'جدول النوم',
                        Icons.bedtime_rounded,
                        const Color(0xFF8B5CF6),
                        helpText: 'حدد أوقات نومك لضمان عدم جدولة دروس خلالها.\n\n• وقت النوم: الوقت المعتاد للنوم\n• وقت الاستيقاظ: الوقت المعتاد للاستيقاظ\n\nالنوم الكافي (7-9 ساعات) ضروري للتركيز والاستيعاب الجيد.',
                      ),
                      const SizedBox(height: 12),
                      _buildSleepScheduleCard(context, settings),
                      const SizedBox(height: 20),

                      // Energy Levels Section
                      _buildSectionHeader(
                        context,
                        'مستويات الطاقة',
                        Icons.bolt_rounded,
                        const Color(0xFFF59E0B),
                        helpText: 'حدد مستوى طاقتك خلال فترات اليوم المختلفة.\n\n• الصباح (6-12): عادة ما يكون مستوى الطاقة عالي\n• الظهيرة (12-18): قد ينخفض قليلاً بعد الغداء\n• المساء (18-22): يعتمد على نمط حياتك\n• الليل (22-6): منخفض بسبب الحاجة للنوم\n\nسيتم جدولة المواد الصعبة في أوقات الطاقة العالية.',
                      ),
                      const SizedBox(height: 12),
                      _buildEnergyLevelsCard(context, settings),
                      const SizedBox(height: 20),

                      // Prayer Times Section
                      _buildSectionHeader(
                        context,
                        'مواقيت الصلاة',
                        Icons.mosque_rounded,
                        const Color(0xFF10B981),
                        helpText: 'دمج مواقيت الصلاة في جدولك الدراسي.\n\n• اختر مدينتك للحصول على أوقات دقيقة\n• سيتم حجز وقت للصلاة تلقائياً\n• لن يتم جدولة دروس خلال أوقات الصلاة\n\nهذا يساعدك على الموازنة بين الدراسة والعبادة.',
                      ),
                      const SizedBox(height: 12),
                      _buildPrayerTimesCard(context, settings),
                      const SizedBox(height: 20),

                      // Exercise Section
                      _buildSectionHeader(
                        context,
                        'التمارين الرياضية',
                        Icons.fitness_center_rounded,
                        const Color(0xFF3B82F6),
                        helpText: 'خصص وقتاً للنشاط البدني اليومي.\n\n• التمارين تحسن التركيز والذاكرة\n• حدد المدة المناسبة (30-60 دقيقة موصى بها)\n• سيتم حجز هذا الوقت تلقائياً\n\nالجسم السليم في العقل السليم!',
                      ),
                      const SizedBox(height: 12),
                      _buildExerciseCard(context, settings),
                      const SizedBox(height: 20),

                      // Priority Weights Section
                      _buildSectionHeader(
                        context,
                        'أوزان الأولوية',
                        Icons.tune_rounded,
                        const Color(0xFF6366F1),
                        helpText: 'حدد العوامل الأكثر أهمية في ترتيب المواد.\n\n• قرب الامتحان: أولوية للامتحانات القريبة\n• المعامل: أهمية المادة في المعدل\n• الصعوبة: المواد الصعبة تحتاج وقت أطول\n• آخر مراجعة: المواد المهملة تحصل على أولوية\n• الأداء: تركيز على المواد ذات الأداء الضعيف\n\nالمجموع يجب أن يساوي 100%',
                      ),
                      const SizedBox(height: 12),
                      _buildPriorityWeightsCard(context, settings),
                      const SizedBox(height: 20),

                      // View Mode Section
                      _buildSectionHeader(
                        context,
                        'وضع العرض',
                        Icons.view_module_rounded,
                        const Color(0xFF8B5CF6),
                        helpText: 'اختر طريقة عرض الجدول الدراسي.\n\n• قائمة: عرض الجلسات كقائمة مرتبة\n• شبكة: عرض الجلسات في شبكة منظمة\n• تقويم: عرض الجدول على شكل تقويم شهري\n• خط زمني: عرض الجلسات على خط زمني تفاعلي\n\nاختر الطريقة الأنسب لك!',
                      ),
                      const SizedBox(height: 12),
                      _buildViewModeCard(context, settings),
                      const SizedBox(height: 24),

                      // Reset Button
                      _buildResetButton(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color, {String? helpText}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
            ),
          ),
          if (helpText != null) ...[
            InkWell(
              onTap: () => _showHelpDialog(context, title, helpText, icon, color),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 16,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyHoursCard(BuildContext context, PlannerSettings settings) {
    final availableHours = settings.dailyStudyWindow.inMinutes / 60;

    return Container(
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الوقت المتاح للدراسة: ${availableHours.toStringAsFixed(1)} ساعة يومياً',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeRow(
              context,
              icon: Icons.wb_sunny_rounded,
              iconColor: const Color(0xFFF59E0B),
              label: 'بداية الدراسة',
              time: _formatTime(settings.studyStartHour, 0),
              onTap: () => _showTimePicker(
                context,
                'اختر وقت البداية',
                TimeOfDay(hour: settings.studyStartHour, minute: 0),
                (time) => context.read<SettingsCubit>().updateStudyHours(
                  startTime: time,
                  endTime: TimeOfDay(hour: settings.studyEndHour, minute: 0),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Color(0xFFE5E7EB)),
            ),
            _buildTimeRow(
              context,
              icon: Icons.nightlight_rounded,
              iconColor: const Color(0xFF8B5CF6),
              label: 'نهاية الدراسة',
              time: _formatTime(settings.studyEndHour, 0),
              onTap: () => _showTimePicker(
                context,
                'اختر وقت النهاية',
                TimeOfDay(hour: settings.studyEndHour, minute: 0),
                (time) => context.read<SettingsCubit>().updateStudyHours(
                  startTime: TimeOfDay(
                    hour: settings.studyStartHour,
                    minute: 0,
                  ),
                  endTime: time,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, PlannerSettings settings) {
    final availableHours = settings.dailyStudyWindow.inMinutes / 60;
    // Clamp goalHours to be within valid range (1 to availableHours)
    final maxHours = availableHours < 1 ? 1.0 : availableHours;
    final goalHours = settings.maxStudyHoursPerDay.clamp(1, maxHours.toInt());
    final percentage = (goalHours / maxHours * 100).clamp(0, 100).toInt();

    return Container(
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFFF59E0B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ساعات الدراسة المستهدفة يومياً',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$goalHours من ${maxHours.toStringAsFixed(1)} ساعة متاحة',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF59E0B),
                        const Color(0xFFF59E0B).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$goalHours سا',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 80
                      ? const Color(0xFFEF4444) // Red if too much
                      : percentage > 60
                          ? const Color(0xFFF59E0B) // Amber if good
                          : const Color(0xFF10B981), // Green if light
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Explanation text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 20,
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'سيتم توزيع $goalHours ساعة من الدراسة خلال الفترة المتاحة (${_formatTime(settings.studyStartHour, 0)} - ${_formatTime(settings.studyEndHour, 0)})',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Plus/Minus buttons with slider
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  // Minus button
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: goalHours > 1
                          ? () {
                              context.read<SettingsCubit>().updateMaxStudyHours(
                                    goalHours - 1,
                                  );
                            }
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          color: goalHours > 1
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFD1D5DB),
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Slider
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFFF59E0B),
                          inactiveTrackColor: const Color(0xFFF59E0B).withOpacity(0.2),
                          thumbColor: const Color(0xFFF59E0B),
                          overlayColor: const Color(0xFFF59E0B).withOpacity(0.1),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: goalHours.toDouble(),
                          min: 1,
                          max: maxHours < 2 ? 2.0 : maxHours,
                          divisions: (maxHours < 2 ? 2 : maxHours).toInt() - 1,
                          onChanged: (value) {
                            context.read<SettingsCubit>().updateMaxStudyHours(
                                  value.toInt(),
                                );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Plus button
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: goalHours < maxHours.toInt()
                          ? () {
                              context.read<SettingsCubit>().updateMaxStudyHours(
                                    goalHours + 1,
                                  );
                            }
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: goalHours < maxHours.toInt()
                              ? const Color(0xFF10B981)
                              : const Color(0xFFD1D5DB),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepScheduleCard(
    BuildContext context,
    PlannerSettings settings,
  ) {
    return Container(
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTimeRow(
              context,
              icon: Icons.bedtime_rounded,
              iconColor: const Color(0xFF8B5CF6),
              label: 'وقت النوم',
              time: _formatTime(settings.sleepStartHour, 0),
              onTap: () => _showTimePicker(
                context,
                'اختر وقت النوم',
                TimeOfDay(hour: settings.sleepStartHour, minute: 0),
                (time) => context.read<SettingsCubit>().updateSleepSchedule(
                  startTime: time,
                  endTime: TimeOfDay(hour: settings.sleepEndHour, minute: 0),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Color(0xFFE5E7EB)),
            ),
            _buildTimeRow(
              context,
              icon: Icons.alarm_rounded,
              iconColor: const Color(0xFFF59E0B),
              label: 'وقت الاستيقاظ',
              time: _formatTime(settings.sleepEndHour, 0),
              onTap: () => _showTimePicker(
                context,
                'اختر وقت الاستيقاظ',
                TimeOfDay(hour: settings.sleepEndHour, minute: 0),
                (time) => context.read<SettingsCubit>().updateSleepSchedule(
                  startTime: TimeOfDay(
                    hour: settings.sleepStartHour,
                    minute: 0,
                  ),
                  endTime: time,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyLevelsCard(
    BuildContext context,
    PlannerSettings settings,
  ) {
    return Container(
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'حدد مستوى طاقتك في كل فترة (0-100)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildEnergySlider(
              context,
              'الصباح (6-12)',
              Icons.wb_sunny_rounded,
              const Color(0xFFF59E0B),
              settings.morningEnergyLevel * 10,
              (value) => context.read<SettingsCubit>().updateEnergyLevels(
                morning: (value / 10).round(),
              ),
            ),
            _buildEnergySlider(
              context,
              'الظهيرة (12-18)',
              Icons.wb_cloudy_rounded,
              const Color(0xFF3B82F6),
              settings.afternoonEnergyLevel * 10,
              (value) => context.read<SettingsCubit>().updateEnergyLevels(
                afternoon: (value / 10).round(),
              ),
            ),
            _buildEnergySlider(
              context,
              'المساء (18-22)',
              Icons.nightlight_round,
              const Color(0xFF8B5CF6),
              settings.eveningEnergyLevel * 10,
              (value) => context.read<SettingsCubit>().updateEnergyLevels(
                evening: (value / 10).round(),
              ),
            ),
            _buildEnergySlider(
              context,
              'الليل (22-6)',
              Icons.bedtime_rounded,
              const Color(0xFF6366F1),
              settings.nightEnergyLevel * 10,
              (value) => context.read<SettingsCubit>().updateEnergyLevels(
                night: (value / 10).round(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesCard(BuildContext context, PlannerSettings settings) {
    return Container(
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'دمج مواقيت الصلاة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              subtitle: const Text(
                'تجنب جدولة الدراسة وقت الصلاة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              value: settings.enablePrayerTimes,
              onChanged: (value) =>
                  context.read<SettingsCubit>().togglePrayerTimes(value),
              activeColor: const Color(0xFF10B981),
              secondary: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
            ),
            if (settings.enablePrayerTimes) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Color(0xFFE5E7EB)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                title: const Text(
                  'المدينة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Color(0xFF1F2937),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    settings.cityForPrayer,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
                onTap: () => _showCityDialog(context, settings.cityForPrayer),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, PlannerSettings settings) {
    return Container(
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'فترات التمارين الرياضية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              subtitle: const Text(
                'تخصيص وقت للنشاط البدني',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              value: settings.exerciseEnabled,
              onChanged: (value) =>
                  context.read<SettingsCubit>().toggleExercise(value),
              activeColor: const Color(0xFF3B82F6),
              secondary: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Color(0xFF3B82F6),
                  size: 22,
                ),
              ),
            ),
            if (settings.exerciseEnabled) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Color(0xFFE5E7EB)),
              ),
              _buildNumberRow(
                'المدة (دقيقة)',
                settings.exerciseDurationMinutes,
                (value) => context.read<SettingsCubit>().updateExerciseSettings(
                  durationMinutes: value,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDurationByCoefficientCard(
    BuildContext context,
    PlannerSettings settings,
  ) {
    // Common coefficient values in Algerian education system
    final coefficients = [7, 5, 4, 3, 2, 1];

    return Container(
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'حدد مدة الجلسة المناسبة لكل معامل. المواد ذات المعامل الأعلى تستحق وقتاً أطول',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Coefficient rows
            ...coefficients.map((coef) {
              final duration = settings.getCoefficientDuration(coef);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCoefficientDurationRow(
                  context,
                  coefficient: coef,
                  duration: duration,
                  onChanged: (value) {
                    context.read<SettingsCubit>().updateCoefficientDuration(
                      coefficient: coef,
                      durationMinutes: value,
                    );
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoefficientDurationRow(
    BuildContext context, {
    required int coefficient,
    required int duration,
    required ValueChanged<int> onChanged,
  }) {
    // Color based on coefficient importance
    final color = coefficient >= 5
        ? const Color(0xFFEF4444) // Red for high coefficient
        : coefficient >= 3
            ? const Color(0xFFF59E0B) // Amber for medium
            : const Color(0xFF10B981); // Green for low

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Coefficient badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$coefficient',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'معامل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Duration display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مدة الجلسة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$duration دقيقة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),

              // Adjust buttons (hours and minutes)
              Column(
                children: [
                  // Hours buttons
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: duration > 60
                              ? () => onChanged(duration - 60)
                              : null,
                          icon: const Icon(Icons.remove_rounded, size: 18),
                          color: const Color(0xFFEF4444),
                          splashRadius: 18,
                          tooltip: '-1 ساعة',
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ساعة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: duration < 180
                              ? () => onChanged(duration + 60)
                              : null,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          color: const Color(0xFF10B981),
                          splashRadius: 18,
                          tooltip: '+1 ساعة',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Minutes buttons
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: duration > 15
                              ? () => onChanged(duration - 5)
                              : null,
                          icon: const Icon(Icons.remove_rounded, size: 18),
                          color: const Color(0xFFEF4444),
                          splashRadius: 18,
                          tooltip: '-5 دقائق',
                        ),
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: Text(
                            '$duration',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: duration < 180
                              ? () => onChanged(duration + 5)
                              : null,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          color: const Color(0xFF10B981),
                          splashRadius: 18,
                          tooltip: '+5 دقائق',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: duration.toDouble().clamp(15.0, 180.0),
              min: 15,
              max: 180,
              divisions: 33,
              onChanged: (value) => onChanged(value.toInt()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityWeightsCard(
    BuildContext context,
    PlannerSettings settings,
  ) {
    return Container(
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'عوامل حساب الأولوية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildWeightSlider(
              context,
              'قرب الامتحان',
              Icons.event_rounded,
              const Color(0xFFEF4444),
              settings.examProximityWeight / 100,
              (value) => context.read<SettingsCubit>().updatePriorityWeights(
                examProximity: (value * 100).round(),
              ),
            ),
            _buildWeightSlider(
              context,
              'المعامل',
              Icons.calculate_rounded,
              const Color(0xFF3B82F6),
              settings.coefficientWeight / 100,
              (value) => context.read<SettingsCubit>().updatePriorityWeights(
                coefficient: (value * 100).round(),
              ),
            ),
            _buildWeightSlider(
              context,
              'الصعوبة',
              Icons.psychology_rounded,
              const Color(0xFF8B5CF6),
              settings.difficultyWeight / 100,
              (value) => context.read<SettingsCubit>().updatePriorityWeights(
                difficulty: (value * 100).round(),
              ),
            ),
            _buildWeightSlider(
              context,
              'آخر مراجعة',
              Icons.history_rounded,
              const Color(0xFFF59E0B),
              settings.inactivityWeight / 100,
              (value) => context.read<SettingsCubit>().updatePriorityWeights(
                inactivity: (value * 100).round(),
              ),
            ),
            _buildWeightSlider(
              context,
              'الأداء',
              Icons.trending_up_rounded,
              const Color(0xFF10B981),
              settings.performanceGapWeight / 100,
              (value) => context.read<SettingsCubit>().updatePriorityWeights(
                performanceGap: (value * 100).round(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showResetDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restore_rounded,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'استعادة الإعدادات الافتراضية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widgets
  Widget _buildTimeRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergySlider(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    int value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$value%',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSlider(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 1,
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberRow(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  onPressed: value > 5 ? () => onChanged(value - 5) : null,
                  splashRadius: 20,
                ),
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  onPressed: value < 120 ? () => onChanged(value + 5) : null,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog helpers
  void _showTimePicker(
    BuildContext context,
    String title,
    TimeOfDay initialTime,
    ValueChanged<TimeOfDay> onSelected,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );

    if (time != null) {
      onSelected(time);
    }
  }

  void _showCityDialog(BuildContext context, String currentCity) {
    final cities = [
      'الجزائر',
      'وهران',
      'قسنطينة',
      'عنابة',
      'باتنة',
      'سطيف',
      'تلمسان',
      'بشار',
    ];

    // Capture the cubit before entering the dialog
    final settingsCubit = context.read<SettingsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'اختر المدينة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cities.length,
              itemBuilder: (builderContext, index) {
                final isSelected = cities[index] == currentCity;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      cities[index],
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF1F2937),
                      ),
                    ),
                    value: cities[index],
                    groupValue: currentCity,
                    activeColor: const Color(0xFF6366F1),
                    onChanged: (value) {
                      if (value != null) {
                        settingsCubit.updatePrayerSettings(
                          city: value,
                        );
                        Navigator.pop(dialogContext);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restore_rounded,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'استعادة الإعدادات؟',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: const Text(
            'سيتم إعادة جميع الإعدادات إلى القيم الافتراضية. هل أنت متأكد؟',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
              ),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SettingsCubit>().resetToDefaults();
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'استعادة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeCard(BuildContext context, PlannerSettings settings) {
    // View mode options
    final viewModes = [
      {'id': 'list', 'label': 'قائمة', 'icon': Icons.view_list_rounded},
      {'id': 'grid', 'label': 'شبكة', 'icon': Icons.grid_view_rounded},
      {'id': 'calendar', 'label': 'تقويم', 'icon': Icons.calendar_month_rounded},
      {'id': 'timeline', 'label': 'خط زمني', 'icon': Icons.timeline_rounded},
    ];

    // Get current view mode (default to 'list' if not set)
    final currentViewMode = settings.viewMode ?? 'list';
    final currentMode = viewModes.firstWhere(
      (mode) => mode['id'] == currentViewMode,
      orElse: () => viewModes[0],
    );

    return Container(
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'اختر طريقة عرض الجدول الدراسي المفضلة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown selector
            InkWell(
              onTap: () => _showViewModeDialog(context, currentViewMode, viewModes),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      const Color(0xFF8B5CF6).withOpacity(0.1),
                      const Color(0xFF8B5CF6).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Current mode icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        currentMode['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Label
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'وضع العرض الحالي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentMode['label'] as String,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dropdown arrow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showViewModeDialog(
    BuildContext context,
    String currentViewMode,
    List<Map<String, dynamic>> viewModes,
  ) {
    // Capture the cubit before entering the dialog
    final settingsCubit = context.read<SettingsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.view_module_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'اختر وضع العرض',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: viewModes.map((mode) {
                final isSelected = mode['id'] == currentViewMode;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withOpacity(0.15),
                              const Color(0xFF8B5CF6).withOpacity(0.1),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        settingsCubit.updateViewMode(
                              mode['id'] as String,
                            );
                        Navigator.pop(dialogContext);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF8B5CF6),
                                          Color(0xFF7C3AED),
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                mode['icon'] as IconData,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Label
                            Expanded(
                              child: Text(
                                mode['label'] as String,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF8B5CF6)
                                      : const Color(0xFF1F2937),
                                ),
                              ),
                            ),

                            // Check mark
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8B5CF6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show help dialog for a section
  void _showHelpDialog(BuildContext context, String title, String helpText, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        color,
                        color.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'مساعدة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Help icon with background
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.help_outline_rounded,
                              color: color,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Help text
                        Text(
                          helpText,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            height: 1.8,
                            color: Color(0xFF1F2937),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Impact section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.1),
                                color.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _getImpactText(title),
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'فهمت',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  /// Get impact text based on section title
  String _getImpactText(String title) {
    switch (title) {
      case 'ساعات الدراسة':
        return 'التأثير: يحدد الإطار الزمني الذي سيتم فيه توزيع جميع جلسات الدراسة. تغيير هذه الأوقات سيؤدي إلى إعادة توزيع كامل الجدول.';
      case 'الهدف اليومي':
        return 'التأثير: يحدد مجموع ساعات الدراسة يومياً. زيادة الهدف = المزيد من الجلسات، وتقليله = جلسات أقل وفترات راحة أطول.';
      case 'مدة الجلسة حسب المعامل':
        return 'التأثير: المواد ذات المعامل الأعلى ستحصل على جلسات أطول في الجدول، مما يعطيها أولوية ووقت أكبر للمراجعة.';
      case 'جدول النوم':
        return 'التأثير: يمنع جدولة أي جلسات دراسية خلال ساعات النوم. تغيير الأوقات قد يسمح بجلسات إضافية أو يزيلها.';
      case 'مستويات الطاقة':
        return 'التأثير: المواد الصعبة والمهمة ستُجدول في أوقات الطاقة العالية، والمواد السهلة في أوقات الطاقة المنخفضة.';
      case 'مواقيت الصلاة':
        return 'التأثير: عند التفعيل، يتم حجز وقت للصلاة تلقائياً، ولن تُجدول أي جلسات دراسية خلال أوقات الصلاة.';
      case 'التمارين الرياضية':
        return 'التأثير: عند التفعيل، يتم حجز الوقت المحدد للتمارين يومياً، مما يقلل الوقت المتاح للدراسة بهذا المقدار.';
      case 'أوزان الأولوية':
        return 'التأثير: تحدد ترتيب المواد في الجدول. المواد ذات الأولوية الأعلى تحصل على أوقات أفضل (طاقة عالية، وقت مبكر).';
      case 'وضع العرض':
        return 'التأثير: يغير فقط طريقة عرض الجدول على الشاشة. لا يؤثر على محتوى أو توزيع الجلسات الدراسية.';
      default:
        return 'هذا الإعداد يؤثر على طريقة تنظيم وجدولة دروسك اليومية.';
    }
  }

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
