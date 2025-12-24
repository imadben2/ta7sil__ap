import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../quiz/presentation/bloc/quiz_list/quiz_list_bloc.dart';
import '../../../quiz/presentation/bloc/quiz_list/quiz_list_event.dart';
import '../../../quiz/presentation/bloc/quiz_list/quiz_list_state.dart';
import '../../../quiz/domain/entities/quiz_entity.dart';

/// Quiz List view - كويز category
/// Shows subjects in a grid layout (like BAC page), tap to see quizzes for that subject
class QuizListView extends StatefulWidget {
  const QuizListView({super.key});

  @override
  State<QuizListView> createState() => _QuizListViewState();
}

class _QuizListViewState extends State<QuizListView> {
  late QuizListBloc _quizBloc;

  @override
  void initState() {
    super.initState();
    _quizBloc = sl<QuizListBloc>()..add(const LoadQuizzes());
  }

  @override
  void dispose() {
    _quizBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _quizBloc,
      child: RefreshIndicator(
        onRefresh: () async {
          _quizBloc.add(const LoadQuizzes());
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader()),

            // Stats Cards
            SliverToBoxAdapter(child: _buildStatsCards()),

            // Section Title
            SliverToBoxAdapter(child: _buildSectionTitle('اختر المادة')),

            // Subjects Grid
            SliverToBoxAdapter(child: _buildSubjectsGrid()),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الاختبارات',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'اختبر معلوماتك وتتبع تقدمك',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return BlocBuilder<QuizListBloc, QuizListState>(
      builder: (context, state) {
        int totalQuizzes = 0;
        int completedQuizzes = 0;
        double avgScore = 0;

        if (state is QuizListGroupedLoaded) {
          totalQuizzes = state.totalQuizCount;
          int totalCompleted = 0;
          double totalScore = 0;
          int scoredQuizzes = 0;
          for (final quizzes in state.groupedQuizzes.values) {
            for (final quiz in quizzes) {
              if (quiz.userStats != null && quiz.userStats!.attemptsCount > 0) {
                totalCompleted++;
                if (quiz.userStats!.bestScore != null) {
                  totalScore += quiz.userStats!.bestScore!;
                  scoredQuizzes++;
                }
              }
            }
          }
          completedQuizzes = totalCompleted;
          avgScore = scoredQuizzes > 0 ? totalScore / scoredQuizzes : 0;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.assignment,
                  value: '$totalQuizzes',
                  label: 'اختبار متاح',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  value: '$completedQuizzes',
                  label: 'مكتمل',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  value: '${avgScore.toStringAsFixed(0)}%',
                  label: 'متوسط النتيجة',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSubjectsGrid() {
    return BlocBuilder<QuizListBloc, QuizListState>(
      builder: (context, state) {
        if (state is QuizListLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is QuizListError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _quizBloc.add(const LoadQuizzes());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is QuizListGroupedLoaded) {
          final subjects = state.groupedQuizzes.keys.toList();

          if (subjects.isEmpty) {
            return _buildEmptyState();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final quizzes = state.groupedQuizzes[subject] ?? [];
                return _buildSubjectCard(context, subject, quizzes);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    SubjectInfo subject,
    List<QuizEntity> quizzes,
  ) {
    final hasQuizzes = quizzes.isNotEmpty;
    final subjectColor = _parseColor(subject.color);

    return GestureDetector(
      onTap: hasQuizzes
          ? () {
              context.push('/quiz/subject/${subject.id}', extra: {
                'subject': subject,
                'quizzes': quizzes,
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: subjectColor.withOpacity(hasQuizzes ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Subject Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(hasQuizzes ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getSubjectIcon(subject.icon),
                color: hasQuizzes ? subjectColor : Colors.grey[400],
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            // Subject Name
            Text(
              subject.nameAr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: hasQuizzes ? subjectColor : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Quiz Count Badge
            if (hasQuizzes) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: subjectColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${quizzes.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: subjectColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد اختبارات متاحة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إضافة اختبارات جديدة قريباً',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        final colorString = colorHex.replaceFirst('#', '');
        return Color(int.parse(colorString, radix: 16) + 0xFF000000);
      } catch (_) {}
    }
    return AppColors.primary;
  }

  IconData _getSubjectIcon(String? icon) {
    switch (icon) {
      case 'calculator':
      case 'calculate':
        return Icons.calculate_rounded;
      case 'atom':
      case 'science':
        return Icons.science_rounded;
      case 'language':
        return Icons.language_rounded;
      case 'mosque':
        return Icons.mosque_rounded;
      case 'public':
        return Icons.public_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'history':
      case 'history_edu':
        return Icons.history_edu_rounded;
      case 'biotech':
        return Icons.biotech_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'translate':
        return Icons.translate_rounded;
      case 'functions':
        return Icons.functions_rounded;
      case 'text_fields':
        return Icons.text_fields_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}
