import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/centralized_subject.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/subject.dart';
import '../bloc/subjects_bloc.dart';
import '../bloc/subjects_event.dart';
import '../bloc/subjects_state.dart';
import '../bloc/exams_bloc.dart';
import '../bloc/exams_event.dart';
import '../bloc/exams_state.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/settings_cubit.dart';
import 'add_exam_screen.dart';
import '../screens/schedule_wizard_screen.dart';

/// Modern Exams Page - جدول الامتحانات
class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Design constants - Using AppColors for consistency
  static const _primaryColor = AppColors.primary;
  static const _secondaryColor = AppColors.primaryLight;
  static const _bgColor = AppColors.slateBackground;
  static const _cardBg = AppColors.surface;
  static const _textPrimary = AppColors.slate900;
  static const _textSecondary = AppColors.slate600;

  /// Convert number to string (keeping Western numerals for better visibility)
  String _toArabicNumerals(dynamic number) {
    return number.toString();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    // Load exams when page initializes
    context.read<ExamsBloc>().add(const LoadExamsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Exam> _getUpcomingExams(List<Exam> exams) {
    return exams.where((exam) => exam.isUpcoming).toList()
      ..sort((a, b) => a.daysUntilExam.compareTo(b.daysUntilExam));
  }

  List<Exam> _getPastExams(List<Exam> exams) {
    return exams.where((exam) => !exam.isUpcoming).toList()
      ..sort((a, b) => b.examDate.compareTo(a.examDate));
  }

  List<Exam> _getAllExamsSorted(List<Exam> exams) {
    return exams..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamsBloc, ExamsState>(
      builder: (context, state) {
        List<Exam> exams = [];
        if (state is ExamsLoaded) {
          exams = state.exams;
        }

        final upcomingExams = _getUpcomingExams(exams);
        final pastExams = _getPastExams(exams);
        final allExams = _getAllExamsSorted(exams);

        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Scaffold(
            backgroundColor: _bgColor,
            body: SafeArea(
              child: Column(
                children: [
                  _buildModernHeader(upcomingExams: upcomingExams, pastExams: pastExams),
                  _buildTabBar(upcomingExams: upcomingExams, pastExams: pastExams),
                  Expanded(
                    child: state is ExamsLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : state is ExamsError
                            ? _buildErrorState(state.message)
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildExamsList(upcomingExams, isUpcoming: true),
                                  _buildExamsList(allExams),
                                  _buildExamsList(pastExams, isPast: true),
                                ],
                              ),
                  ),
                ],
              ),
            ),
            floatingActionButton: _buildModernFAB(),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ExamsBloc>().add(const LoadExamsEvent());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader({
    required List<Exam> upcomingExams,
    required List<Exam> pastExams,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor,
            _secondaryColor,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with navigation and title
          Row(
            children: [
              // Home button
              _buildHeaderIconButton(
                icon: Icons.home_rounded,
                onTap: () => context.go('/home'),
              ),
              const Spacer(),
              // Title
              const Text(
                'جدول الامتحانات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // Stats indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event_note_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _toArabicNumerals(upcomingExams.length),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.upcoming_rounded,
                  label: 'قادمة',
                  value: _toArabicNumerals(upcomingExams.length),
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'عاجلة',
                  value: _toArabicNumerals(upcomingExams.where((e) => e.daysUntilExam <= 7).length),
                  color: const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.check_circle_rounded,
                  label: 'منتهية',
                  value: _toArabicNumerals(pastExams.length),
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar({
    required List<Exam> upcomingExams,
    required List<Exam> pastExams,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, _secondaryColor],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: _textSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: 'القادمة (${_toArabicNumerals(upcomingExams.length)})'),
          const Tab(text: 'الكل'),
          Tab(text: 'السابقة (${_toArabicNumerals(pastExams.length)})'),
        ],
      ),
    );
  }

  Widget _buildExamsList(
    List<Exam> exams, {
    bool isUpcoming = false,
    bool isPast = false,
  }) {
    if (exams.isEmpty) {
      return _buildEmptyState(
        isUpcoming
            ? 'لا توجد امتحانات قادمة'
            : isPast
                ? 'لا توجد امتحانات سابقة'
                : 'لا توجد امتحانات',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        final examNumber = index + 1; // 1-based numbering
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildModernExamCard(exam, examNumber: examNumber),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primaryColor.withValues(alpha: 0.1),
                    _secondaryColor.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_note_rounded,
                size: 64,
                color: _primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'أضف امتحاناتك لمساعدتك في التخطيط الدراسي',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildAddExamButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddExamButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAddExamDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'إضافة امتحان',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernExamCard(Exam exam, {required int examNumber}) {
    final isUrgent = exam.daysUntilExam <= 7 && exam.isUpcoming;
    final urgencyColor = _getUrgencyColor(exam);
    final subjectColor = _getSubjectColor(exam.subjectName);

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isUrgent
            ? Border.all(
                color: urgencyColor.withValues(alpha: 0.5),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isUrgent
                ? urgencyColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isUrgent ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showExamDetails(exam),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exam number badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _toArabicNumerals(examNumber),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Subject color indicator bar
                    Container(
                      width: 5,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            subjectColor,
                            subjectColor.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Exam info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.subjectName,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getExamTypeIcon(exam.examType),
                                size: 14,
                                color: _textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getExamTypeLabel(exam.examType),
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Date badge
                    _buildModernDateBadge(exam),
                  ],
                ),
                const SizedBox(height: 14),
                // Info chips row
                Row(
                  children: [
                    _buildModernInfoChip(
                      icon: Icons.timer_outlined,
                      label: '${_toArabicNumerals(exam.durationMinutes)} دقيقة',
                      color: _primaryColor,
                    ),
                    const SizedBox(width: 10),
                    _buildModernInfoChip(
                      icon: Icons.flag_rounded,
                      label: _getImportanceLabel(exam.importanceLevel),
                      color: _getImportanceColor(exam.importanceLevel),
                    ),
                    if (isUrgent) ...[
                      const Spacer(),
                      _buildUrgentBadge(),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDateBadge(Exam exam) {
    final dateStr = DateFormat('d MMMM', 'ar').format(exam.examDate);
    final isUpcoming = exam.isUpcoming;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: isUpcoming
            ? LinearGradient(
                colors: [_primaryColor, _secondaryColor],
              )
            : null,
        color: isUpcoming ? null : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isUpcoming
            ? [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            dateStr,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUpcoming ? Colors.white : _textSecondary,
            ),
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 2),
            Text(
              'بعد ${_toArabicNumerals(exam.daysUntilExam)} يوم',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            'عاجل',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAddExamDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(Exam exam) {
    if (!exam.isUpcoming) return const Color(0xFF6B7280);
    if (exam.daysUntilExam <= 3) return const Color(0xFFEF4444);
    if (exam.daysUntilExam <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Color _getSubjectColor(String subjectName) {
    if (subjectName.contains('رياض') || subjectName.contains('Math')) {
      return const Color(0xFF6366F1);
    }
    if (subjectName.contains('فيزياء') || subjectName.contains('Physics')) {
      return const Color(0xFF3B82F6);
    }
    if (subjectName.contains('عربي') || subjectName.contains('Arabic')) {
      return const Color(0xFF10B981);
    }
    if (subjectName.contains('إسلام') || subjectName.contains('Islamic')) {
      return const Color(0xFF059669);
    }
    if (subjectName.contains('فرنسي') || subjectName.contains('French')) {
      return const Color(0xFFEC4899);
    }
    if (subjectName.contains('إنجليزي') || subjectName.contains('English')) {
      return const Color(0xFF8B5CF6);
    }
    return const Color(0xFF64748B);
  }

  Color _getImportanceColor(ImportanceLevel level) {
    switch (level) {
      case ImportanceLevel.critical:
        return const Color(0xFFEF4444);
      case ImportanceLevel.high:
        return const Color(0xFFF59E0B);
      case ImportanceLevel.medium:
        return const Color(0xFF3B82F6);
      case ImportanceLevel.low:
        return const Color(0xFF6B7280);
    }
  }

  String _getImportanceLabel(ImportanceLevel level) {
    switch (level) {
      case ImportanceLevel.critical:
        return 'حرج جداً';
      case ImportanceLevel.high:
        return 'مهم';
      case ImportanceLevel.medium:
        return 'متوسط';
      case ImportanceLevel.low:
        return 'عادي';
    }
  }

  IconData _getExamTypeIcon(ExamType type) {
    switch (type) {
      case ExamType.quiz:
        return Icons.quiz_rounded;
      case ExamType.test:
        return Icons.assignment_rounded;
      case ExamType.exam:
        return Icons.description_rounded;
      case ExamType.finalExam:
        return Icons.emoji_events_rounded;
    }
  }

  String _getExamTypeLabel(ExamType type) {
    switch (type) {
      case ExamType.quiz:
        return 'اختبار قصير';
      case ExamType.test:
        return 'فرض';
      case ExamType.exam:
        return 'امتحان';
      case ExamType.finalExam:
        return 'امتحان نهائي';
    }
  }

  void _showAddExamDialog(BuildContext context) async {
    // Capture references before async operations
    final subjectsBloc = context.read<SubjectsBloc>();
    final examsBloc = context.read<ExamsBloc>();

    // Use OverlayEntry for loading indicator to avoid Navigator conflicts with go_router
    OverlayEntry? loadingOverlay;

    void showLoading() {
      loadingOverlay = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black54,
          child: const Center(
            child: CircularProgressIndicator(color: _primaryColor),
          ),
        ),
      );
      Overlay.of(context).insert(loadingOverlay!);
    }

    void hideLoading() {
      loadingOverlay?.remove();
      loadingOverlay = null;
    }

    // Show loading
    showLoading();

    // Load subjects from planner
    subjectsBloc.add(const LoadSubjectsEvent());

    // Wait for subjects to load (with timeout)
    List<Subject> subjects = [];
    try {
      final state = await subjectsBloc.stream.firstWhere(
        (state) => state is SubjectsLoaded || state is SubjectsError,
      ).timeout(const Duration(seconds: 10));

      if (state is SubjectsLoaded) {
        subjects = state.subjects;
      }
    } catch (e) {
      // Timeout or error - check current state
      final currentState = subjectsBloc.state;
      if (currentState is SubjectsLoaded) {
        subjects = currentState.subjects;
      }
    }

    // If planner subjects are empty, try centralized subjects from API
    if (subjects.isEmpty && context.mounted) {
      subjectsBloc.add(const LoadCentralizedSubjectsEvent());

      try {
        final state = await subjectsBloc.stream.firstWhere(
          (state) =>
              state is CentralizedSubjectsLoaded ||
              state is CentralizedSubjectsError,
        ).timeout(const Duration(seconds: 10));

        if (state is CentralizedSubjectsLoaded) {
          // Convert CentralizedSubject to Subject
          subjects = state.centralizedSubjects
              .map((cs) => _convertCentralizedToSubject(cs))
              .toList();
        }
      } catch (e) {
        // Check current state
        final currentState = subjectsBloc.state;
        if (currentState is CentralizedSubjectsLoaded) {
          subjects = currentState.centralizedSubjects
              .map((cs) => _convertCentralizedToSubject(cs))
              .toList();
        }
      }
    }

    // Hide loading indicator
    hideLoading();

    if (!context.mounted) return;

    if (subjects.isEmpty) {
      _showModernSnackBar(
        context,
        'يرجى إضافة مواد دراسية أولاً',
        const Color(0xFFF59E0B),
        Icons.warning_amber_rounded,
      );
      return;
    }

    // Navigate to add exam screen using go_router compatible navigation
    final result = await Navigator.of(context).push<Exam>(
      MaterialPageRoute(
        builder: (routeContext) => AddExamScreen(subjects: subjects),
      ),
    );

    if (result != null && context.mounted) {
      examsBloc.add(AddExamEvent(result));
    }
  }

  /// Convert CentralizedSubject to planner Subject for exam creation
  Subject _convertCentralizedToSubject(CentralizedSubject cs) {
    return Subject(
      id: cs.id.toString(),
      name: cs.nameAr,
      nameAr: cs.nameAr,
      coefficient: cs.coefficient.toInt(),
      difficultyLevel: 5, // Default difficulty
      colorHex: cs.color ?? '#3B82F6',
      iconName: cs.icon ?? 'book',
      progressPercentage: 0,
      totalChapters: 0,
      completedChapters: 0,
      averageScore: 0,
      isActive: cs.isActive,
      category: SubjectCategoryExtension.inferFromName(cs.nameAr),
    );
  }

  void _showModernSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showExamDetails(Exam exam) {
    final urgencyColor = _getUrgencyColor(exam);
    final subjectColor = _getSubjectColor(exam.subjectName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      subjectColor.withValues(alpha: 0.1),
                      subjectColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            subjectColor,
                            subjectColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: subjectColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getExamTypeIcon(exam.examType),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.subjectName,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getExamTypeLabel(exam.examType),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (exam.isUpcoming && exam.daysUntilExam <= 7)
                      _buildUrgentBadge(),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDetailCard(
                      icon: Icons.calendar_today_rounded,
                      title: 'التاريخ',
                      value: DateFormat('EEEE، d MMMM yyyy', 'ar')
                          .format(exam.examDate),
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.timer_outlined,
                            title: 'المدة',
                            value: '${_toArabicNumerals(exam.durationMinutes)} دقيقة',
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.flag_rounded,
                            title: 'الأهمية',
                            value: _getImportanceLabel(exam.importanceLevel),
                            color: _getImportanceColor(exam.importanceLevel),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.event_available_rounded,
                            title: 'التحضير',
                            value: '${_toArabicNumerals(exam.preparationDaysBefore)} يوم',
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.hourglass_bottom_rounded,
                            title: exam.isUpcoming ? 'متبقي' : 'انتهى منذ',
                            value: exam.isUpcoming
                                ? '${_toArabicNumerals(exam.daysUntilExam)} يوم'
                                : '${_toArabicNumerals(-exam.daysUntilExam)} يوم',
                            color: urgencyColor,
                          ),
                        ),
                      ],
                    ),
                    if (exam.chaptersCovered != null &&
                        exam.chaptersCovered!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.menu_book_rounded,
                                    size: 18,
                                    color: _primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'الدروس المغطاة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...exam.chaptersCovered!.map(
                              (chapter) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      chapter,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        color: _textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.edit_rounded,
                            label: 'تعديل',
                            isPrimary: true,
                            onTap: () async {
                              Navigator.pop(context);
                              await _editExam(exam);
                            },
                          ),
                        ),
                        // TODO: Re-enable when schedule generation is ready
                        // const SizedBox(width: 12),
                        // Expanded(
                        //   flex: 2,
                        //   child: _buildActionButton(
                        //     icon: Icons.play_arrow_rounded,
                        //     label: 'بدء التحضير',
                        //     isPrimary: true,
                        //     onTap: () {
                        //       Navigator.pop(context);
                        //       // Navigate to schedule wizard with pre-selected subject and exam date
                        //       _startExamPreparation(exam);
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                    // Bottom safe area padding
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, _secondaryColor],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: _textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Start exam preparation by navigating to schedule wizard
  /// with the exam's subject pre-selected and end date set to exam date
  Future<void> _startExamPreparation(Exam exam) async {
    // Navigate to schedule wizard with pre-selected subject and exam date
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<PlannerBloc>()),
            BlocProvider(create: (_) => sl<SubjectsBloc>()),
            BlocProvider(create: (_) => sl<SettingsCubit>()),
          ],
          child: ScheduleWizardScreen(
            preSelectedSubjectIds: [exam.subjectId],
            examDate: exam.examDate,
          ),
        ),
      ),
    );

    // If schedule was generated successfully, show confirmation
    if (result == true && mounted) {
      _showModernSnackBar(
        context,
        'تم إنشاء جدول التحضير للامتحان بنجاح! 📚',
        const Color(0xFF10B981),
        Icons.check_circle_rounded,
      );

      // Navigate to planner to see the generated schedule
      context.go('/planner');
    }
  }

  Future<void> _editExam(Exam exam) async {
    context.read<SubjectsBloc>().add(const LoadSubjectsEvent());
    final subjectsState = context.read<SubjectsBloc>().state;
    List<Subject> subjects = [];

    if (subjectsState is SubjectsLoaded) {
      subjects = subjectsState.subjects;
    }

    if (subjects.isEmpty) {
      _showModernSnackBar(
        context,
        'لا توجد مواد متاحة',
        const Color(0xFFF59E0B),
        Icons.warning_amber_rounded,
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExamScreen(subjects: subjects, exam: exam),
      ),
    );

    if (result != null && result is Exam) {
      context.read<ExamsBloc>().add(UpdateExamEvent(result));
      // Reload will be triggered automatically by bloc
    }
  }
}
