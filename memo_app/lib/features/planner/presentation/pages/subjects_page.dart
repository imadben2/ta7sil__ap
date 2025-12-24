import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/subject.dart';
import '../bloc/subjects_bloc.dart';
import '../bloc/subjects_event.dart';
import '../bloc/subjects_state.dart';

/// Modern Subjects Page with RTL Arabic support
///
/// Features:
/// - Grid layout for subject cards
/// - Gradient cards with shadows
/// - Modern floating buttons
/// - Progress indicators
/// - RTL Arabic design
class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SubjectsBloc>()..add(const LoadSubjectsEvent()),
      child: const _SubjectsPageContent(),
    );
  }
}

class _SubjectsPageContent extends StatelessWidget {
  const _SubjectsPageContent();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // Modern App Bar
              _buildModernAppBar(context),

              // Page Header
              _buildPageHeader(context),

              // Content
              Expanded(
                child: BlocConsumer<SubjectsBloc, SubjectsState>(
                  listener: (context, state) {
                    if (state is SubjectsError) {
                      _showSnackBar(context, state.message, isError: true);
                    } else if (state is SubjectOperationSuccess) {
                      _showSnackBar(context, state.message, isError: false);
                    }
                  },
                  builder: (context, state) {
                    if (state is SubjectsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                        ),
                      );
                    } else if (state is SubjectsLoaded) {
                      if (state.subjects.isEmpty) {
                        return _buildModernEmptyState(context);
                      }
                      return _buildSubjectsGrid(context, state.subjects);
                    }
                    return _buildModernEmptyState(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home button
          _buildAppBarButton(
            icon: Icons.home_rounded,
            onPressed: () => context.go('/home'),
          ),

          // Title badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'المواد الدراسية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // Add button - commented out
          // _buildAppBarButton(
          //   icon: Icons.add_rounded,
          //   onPressed: () => _showAddSubjectDialog(context),
          // ),
          const SizedBox(width: 48), // Placeholder for spacing
        ],
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF64748B), size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return BlocBuilder<SubjectsBloc, SubjectsState>(
      builder: (context, state) {
        int subjectCount = 0;
        double avgProgress = 0;

        if (state is SubjectsLoaded && state.subjects.isNotEmpty) {
          subjectCount = state.subjects.length;
          avgProgress = state.subjects
                  .map((s) => s.progressPercentage)
                  .reduce((a, b) => a + b) /
              subjectCount;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3B82F6),
                Color(0xFF1D4ED8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  icon: Icons.book_rounded,
                  label: 'عدد المواد',
                  value: subjectCount.toString(),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildHeaderStat(
                  icon: Icons.trending_up_rounded,
                  label: 'متوسط التقدم',
                  value: '${avgProgress.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildModernEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: const Color(0xFF3B82F6).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'لا توجد مواد دراسية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'ابدأ بإضافة مواد دراسية\nلتخطيط وقت دراستك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Add button
            GestureDetector(
              onTap: () => _showAddSubjectDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'إضافة مادة جديدة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Widget _buildSubjectsGrid(BuildContext context, List<Subject> subjects) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Subjects Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                return _buildModernSubjectCard(context, subjects[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSubjectCard(BuildContext context, Subject subject) {
    return GestureDetector(
      onTap: () => _showSubjectDetails(context, subject),
      onLongPress: () => _showSubjectOptions(context, subject),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              subject.color,
              subject.color.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: subject.color.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and coefficient badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          subject.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      // Coefficient badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'معامل ${subject.coefficient}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Subject name
                  Text(
                    subject.nameAr,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subject.name,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Progress section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'التقدم',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            '${subject.progressPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: subject.progressPercentage / 100,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // More options indicator
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubjectOptions(BuildContext context, Subject subject) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Subject header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: subject.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    subject.icon,
                    color: subject.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.nameAr,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        subject.name,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Options
            _buildOptionTile(
              icon: Icons.visibility_rounded,
              label: 'عرض التفاصيل',
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.pop(bottomContext);
                _showSubjectDetails(context, subject);
              },
            ),
            _buildOptionTile(
              icon: Icons.edit_rounded,
              label: 'تعديل المادة',
              color: const Color(0xFFF59E0B),
              onTap: () {
                Navigator.pop(bottomContext);
                _showEditSubjectDialog(context, subject);
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_rounded,
              label: 'حذف المادة',
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.pop(bottomContext);
                _showDeleteConfirmation(context, subject);
              },
            ),

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    // Capture bloc reference before showing dialog to avoid deactivated widget error
    final bloc = context.read<SubjectsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => _ModernSubjectFormDialog(
        blocContext: context,
        onSubmit: (subject) {
          bloc.add(AddSubjectEvent(subject));
        },
      ),
    );
  }

  void _showEditSubjectDialog(BuildContext context, Subject subject) {
    // Capture bloc reference before showing dialog to avoid deactivated widget error
    final bloc = context.read<SubjectsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => _ModernSubjectFormDialog(
        blocContext: context,
        subject: subject,
        onSubmit: (updatedSubject) {
          bloc.add(UpdateSubjectEvent(updatedSubject));
        },
      ),
    );
  }

  void _showSubjectDetails(BuildContext context, Subject subject) {
    // Store parent context to use in nested builders (avoids shadowed context issues)
    final parentContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (scrollContext, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subject header card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          subject.color,
                          subject.color.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: subject.color.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            subject.icon,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.nameAr,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                subject.name,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                subject.coefficient.toString(),
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'معامل',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildDetailStatCard(
                        icon: Icons.trending_up_rounded,
                        label: 'التقدم',
                        value: '${subject.progressPercentage.toStringAsFixed(0)}%',
                        color: const Color(0xFF10B981),
                      ),
                      _buildDetailStatCard(
                        icon: Icons.speed_rounded,
                        label: 'الصعوبة',
                        value: '${subject.difficultyLevel}/10',
                        color: const Color(0xFFF59E0B),
                      ),
                      _buildDetailStatCard(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'الدروس المكتملة',
                        value: '${subject.completedChapters}/${subject.totalChapters}',
                        color: const Color(0xFF3B82F6),
                      ),
                      _buildDetailStatCard(
                        icon: Icons.grade_rounded,
                        label: 'المعدل',
                        value: '${subject.averageScore.toStringAsFixed(1)}%',
                        color: const Color(0xFF8B5CF6),
                      ),
                    ],
                  ),

                  if (subject.lastStudiedAt != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF64748B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'آخر دراسة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${subject.daysSinceLastStudy} يوم مضى',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
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
                          color: const Color(0xFFF59E0B),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _showEditSubjectDialog(parentContext, subject);
                          },
                        ),
                      ),
                      // Delete button - commented out
                      // const SizedBox(width: 12),
                      // Expanded(
                      //   child: _buildActionButton(
                      //     icon: Icons.delete_rounded,
                      //     label: 'حذف',
                      //     color: const Color(0xFFEF4444),
                      //     onPressed: () {
                      //       Navigator.pop(sheetContext);
                      //       _showDeleteConfirmation(parentContext, subject);
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Subject subject) {
    // Capture bloc reference before showing bottom sheet to avoid deactivated widget error
    final bloc = context.read<SubjectsBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'تأكيد الحذف',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'هل أنت متأكد من حذف مادة ${subject.nameAr}؟\nلا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(bottomContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(bottomContext);
                      bloc.add(DeleteSubjectEvent(subject.id));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'حذف',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}

/// Modern Bottom Sheet form for adding/editing subjects
class _ModernSubjectFormDialog extends StatefulWidget {
  final BuildContext blocContext;
  final Subject? subject;
  final Function(Subject) onSubmit;

  const _ModernSubjectFormDialog({
    required this.blocContext,
    this.subject,
    required this.onSubmit,
  });

  @override
  State<_ModernSubjectFormDialog> createState() =>
      _ModernSubjectFormDialogState();
}

class _ModernSubjectFormDialogState extends State<_ModernSubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameArController;
  late TextEditingController _difficultyController;
  late TextEditingController _lastYearAverageController;

  String _selectedIcon = 'book';
  Color _selectedColor = const Color(0xFF3B82F6);

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'book', 'icon': Icons.menu_book_rounded},
    {'name': 'calculate', 'icon': Icons.calculate_rounded},
    {'name': 'science', 'icon': Icons.science_rounded},
    {'name': 'mosque', 'icon': Icons.mosque_rounded},
    {'name': 'language', 'icon': Icons.language_rounded},
    {'name': 'public', 'icon': Icons.public_rounded},
    {'name': 'psychology', 'icon': Icons.psychology_rounded},
    {'name': 'history', 'icon': Icons.history_edu_rounded},
  ];

  final List<Color> _availableColors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFF10B981), // Emerald
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFEC4899), // Pink
    const Color(0xFF84CC16), // Lime
    const Color(0xFF64748B), // Slate
  ];

  @override
  void initState() {
    super.initState();
    final subject = widget.subject;
    _nameArController = TextEditingController(text: subject?.nameAr ?? '');
    _difficultyController = TextEditingController(
      text: subject?.difficultyLevel.toString() ?? '5',
    );
    _lastYearAverageController = TextEditingController(
      text: subject?.lastYearAverage?.toStringAsFixed(2) ?? '',
    );

    if (subject != null) {
      _selectedIcon = subject.iconName;
      _selectedColor = subject.color;
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _difficultyController.dispose();
    _lastYearAverageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.subject != null;
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      _selectedColor,
                      _selectedColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_rounded : Icons.add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'تعديل المادة' : 'مادة جديدة',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            isEdit ? 'تحديث بيانات المادة' : 'أضف مادة دراسية',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject name field - commented out (not editable by user)
                        // _buildModernTextField(
                        //   controller: _nameArController,
                        //   label: 'اسم المادة',
                        //   hint: 'مثال: الرياضيات',
                        //   icon: Icons.subject_rounded,
                        //   validator: (value) {
                        //     if (value == null || value.trim().isEmpty) {
                        //       return 'يرجى إدخال اسم المادة';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        // const SizedBox(height: 16),

                        // Difficulty and Last Year Average row
                        Row(
                          children: [
                            Expanded(
                              child: _buildCompactField(
                                controller: _difficultyController,
                                label: 'درجة الصعوبة',
                                hint: '0-10',
                                icon: Icons.trending_up_rounded,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'مطلوب';
                                  }
                                  final number = int.tryParse(value);
                                  if (number == null || number < 0 || number > 10) {
                                    return '0-10';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCompactField(
                                controller: _lastYearAverageController,
                                label: 'معدل السنة الماضية',
                                hint: '0-20',
                                icon: Icons.history_rounded,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    final number = double.tryParse(value);
                                    if (number == null || number < 0 || number > 20) {
                                      return '0-20';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 20),

                        // Icon selector - commented out (not editable by user)
                        // _buildSectionHeader('رمز المادة', Icons.category_rounded),
                        // const SizedBox(height: 10),
                        // Container(
                        //   padding: const EdgeInsets.all(12),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFFF8FAFC),
                        //     borderRadius: BorderRadius.circular(16),
                        //     border: Border.all(color: const Color(0xFFE2E8F0)),
                        //   ),
                        //   child: Wrap(
                        //     spacing: 10,
                        //     runSpacing: 10,
                        //     alignment: WrapAlignment.center,
                        //     children: _availableIcons.map((iconData) {
                        //       final isSelected = _selectedIcon == iconData['name'];
                        //       return GestureDetector(
                        //         onTap: () => setState(() => _selectedIcon = iconData['name'] as String),
                        //         child: AnimatedContainer(
                        //           duration: const Duration(milliseconds: 200),
                        //           width: 48,
                        //           height: 48,
                        //           decoration: BoxDecoration(
                        //             gradient: isSelected
                        //                 ? LinearGradient(
                        //                     colors: [_selectedColor, _selectedColor.withOpacity(0.7)],
                        //                   )
                        //                 : null,
                        //             color: isSelected ? null : Colors.white,
                        //             borderRadius: BorderRadius.circular(12),
                        //             border: Border.all(
                        //               color: isSelected ? _selectedColor : const Color(0xFFE2E8F0),
                        //               width: isSelected ? 0 : 1,
                        //             ),
                        //             boxShadow: isSelected
                        //                 ? [
                        //                     BoxShadow(
                        //                       color: _selectedColor.withOpacity(0.3),
                        //                       blurRadius: 8,
                        //                       offset: const Offset(0, 2),
                        //                     ),
                        //                   ]
                        //                 : null,
                        //           ),
                        //           child: Icon(
                        //             iconData['icon'] as IconData,
                        //             color: isSelected ? Colors.white : const Color(0xFF64748B),
                        //             size: 22,
                        //           ),
                        //         ),
                        //       );
                        //     }).toList(),
                        //   ),
                        // ),
                        // const SizedBox(height: 20),

                        // Color selector - commented out (not editable by user)
                        // _buildSectionHeader('لون المادة', Icons.palette_rounded),
                        // const SizedBox(height: 10),
                        // Container(
                        //   padding: const EdgeInsets.all(12),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFFF8FAFC),
                        //     borderRadius: BorderRadius.circular(16),
                        //     border: Border.all(color: const Color(0xFFE2E8F0)),
                        //   ),
                        //   child: Wrap(
                        //     spacing: 10,
                        //     runSpacing: 10,
                        //     alignment: WrapAlignment.center,
                        //     children: _availableColors.map((color) {
                        //       final isSelected = _selectedColor == color;
                        //       return GestureDetector(
                        //         onTap: () => setState(() => _selectedColor = color),
                        //         child: AnimatedContainer(
                        //           duration: const Duration(milliseconds: 200),
                        //           width: 42,
                        //           height: 42,
                        //           decoration: BoxDecoration(
                        //             color: color,
                        //             borderRadius: BorderRadius.circular(12),
                        //             border: Border.all(
                        //               color: isSelected ? Colors.white : Colors.transparent,
                        //               width: 3,
                        //             ),
                        //             boxShadow: [
                        //               BoxShadow(
                        //                 color: color.withOpacity(isSelected ? 0.5 : 0.2),
                        //                 blurRadius: isSelected ? 12 : 4,
                        //                 spreadRadius: isSelected ? 2 : 0,
                        //               ),
                        //             ],
                        //           ),
                        //           child: isSelected
                        //               ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        //               : null,
                        //         ),
                        //       );
                        //     }).toList(),
                        //   ),
                        // ),
                        const SizedBox(height: 24),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: Text(
                                  'إلغاء',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isEdit ? Icons.save_rounded : Icons.add_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEdit ? 'حفظ التعديلات' : 'إضافة',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _selectedColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDirection = TextDirection.rtl,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: _selectedColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'Cairo', color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _selectedColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildCompactField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _selectedColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'Cairo', color: Colors.grey[400], fontSize: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _selectedColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Parse last year average (optional)
    double? lastYearAverage;
    if (_lastYearAverageController.text.trim().isNotEmpty) {
      lastYearAverage = double.tryParse(_lastYearAverageController.text.trim());
    }

    // Use existing subject data for non-editable fields
    final existingSubject = widget.subject;

    final subject = Subject(
      id: existingSubject?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: existingSubject?.name ?? '',
      nameAr: existingSubject?.nameAr ?? '',
      coefficient: existingSubject?.coefficient ?? 1,
      difficultyLevel: int.parse(_difficultyController.text),
      colorHex: existingSubject?.colorHex ?? '#3B82F6',
      iconName: existingSubject?.iconName ?? 'book',
      progressPercentage: existingSubject?.progressPercentage ?? 0.0,
      totalChapters: existingSubject?.totalChapters ?? 0,
      completedChapters: existingSubject?.completedChapters ?? 0,
      averageScore: existingSubject?.averageScore ?? 0.0,
      lastStudiedAt: existingSubject?.lastStudiedAt,
      lastYearAverage: lastYearAverage,
    );

    // Pop the dialog first before calling the callback
    Navigator.pop(context);

    // Then call the callback which uses the outer context
    widget.onSubmit(subject);
  }
}
