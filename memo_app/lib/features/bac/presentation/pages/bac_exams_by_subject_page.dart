import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/bac_bloc.dart';
import '../bloc/bac_event.dart';
import '../bloc/bac_state.dart';
import '../../domain/entities/bac_subject_entity.dart';

/// Page showing BAC exams for a specific subject and year
/// Flow: Subject selected → Year selected → Show exams for that subject/year
class BacExamsBySubjectPage extends StatefulWidget {
  final int subjectId;
  final String subjectSlug;
  final String subjectName;
  final String yearSlug;
  final String yearName;
  final Color? subjectColor;

  const BacExamsBySubjectPage({
    super.key,
    required this.subjectId,
    required this.subjectSlug,
    required this.subjectName,
    required this.yearSlug,
    required this.yearName,
    this.subjectColor,
  });

  @override
  State<BacExamsBySubjectPage> createState() => _BacExamsBySubjectPageState();
}

class _BacExamsBySubjectPageState extends State<BacExamsBySubjectPage> {
  bool _hasAutoNavigated = false;

  @override
  void initState() {
    super.initState();
    // Load exams for this subject and year
    context.read<BacBloc>().add(LoadExamsBySubjectAndYearEvent(
      subjectId: widget.subjectId,
      subjectSlug: widget.subjectSlug,
      yearSlug: widget.yearSlug,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.subjectColor ?? AppColors.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${widget.subjectName} - ${widget.yearName}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocBuilder<BacBloc, BacState>(
        builder: (context, state) {
          if (state is BacLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BacError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BacBloc>().add(LoadExamsBySubjectAndYearEvent(
                        subjectId: widget.subjectId,
                        subjectSlug: widget.subjectSlug,
                        yearSlug: widget.yearSlug,
                      ));
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is BacExamsBySubjectLoaded) {
            // If only one exam, skip directly to detail page
            if (state.exams.length == 1 && !_hasAutoNavigated) {
              _hasAutoNavigated = true;
              // Use addPostFrameCallback to navigate after build completes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  // Pop current page first, then push detail page
                  // This way back button from detail page goes to year selection
                  context.pop();
                  context.push('/bac-subject-detail', extra: state.exams.first);
                }
              });
              // Show loading while navigating
              return const Center(child: CircularProgressIndicator());
            }
            return _buildExamsList(state.exams, color);
          }

          return const Center(child: Text('لا توجد بيانات'));
        },
      ),
    );
  }

  Widget _buildExamsList(List<BacSubjectEntity> exams, Color color) {
    if (exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد امتحانات متاحة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لهذه المادة في سنة ${widget.yearName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return _buildExamCard(exam, color, index);
      },
    );
  }

  Widget _buildExamCard(BacSubjectEntity exam, Color color, int index) {
    final gradients = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
      [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      [const Color(0xFFF59E0B), const Color(0xFFD97706)],
    ];

    final gradient = gradients[index % gradients.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Navigate to subject detail page
            await context.push('/bac-subject-detail', extra: exam);
            // Reload exams when returning
            if (mounted) {
              context.read<BacBloc>().add(LoadExamsBySubjectAndYearEvent(
                subjectId: widget.subjectId,
                subjectSlug: widget.subjectSlug,
                yearSlug: widget.yearSlug,
              ));
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
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
                        exam.nameAr,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exam.durationLabel,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exam.coefficientLabel,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
