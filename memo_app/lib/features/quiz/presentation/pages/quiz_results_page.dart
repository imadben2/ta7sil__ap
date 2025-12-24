import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../bloc/quiz_results/quiz_results_bloc.dart';
import '../bloc/quiz_results/quiz_results_event.dart';
import '../bloc/quiz_results/quiz_results_state.dart';
import '../widgets/result_summary_card.dart';

/// Quiz results page - shows score and summary
class QuizResultsPage extends StatefulWidget {
  final int attemptId;

  const QuizResultsPage({super.key, required this.attemptId});

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    context.read<QuizResultsBloc>().add(
      LoadQuizResults(attemptId: widget.attemptId),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<QuizResultsBloc, QuizResultsState>(
          listener: (context, state) {
            if (state is QuizResultsLoaded) {
              _animationController.forward();
            }
          },
          builder: (context, state) {
            if (state is QuizResultsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is QuizResultsError) {
              return _buildErrorState(state.message);
            }

            if (state is QuizResultsLoaded) {
              return _buildResults(state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildResults(QuizResultsLoaded state) {
    final result = state.result;

    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppDesignTokens.spacingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeTransition(
                  opacity: _animationController,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          ),
                        ),
                    child: ResultSummaryCard(result: result),
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacingXXL),
                _buildQuizInfo(result),
                if (result.weakConcepts.isNotEmpty) ...[
                  SizedBox(height: AppDesignTokens.spacingXXL),
                  _buildWeakConcepts(result.weakConcepts),
                ],
                SizedBox(height: AppDesignTokens.spacingXXL),
                _buildActionButtons(result),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_rounded),
          ),
          Expanded(
            child: Text(
              'نتائج الاختبار',
              style: TextStyle(fontSize: AppDesignTokens.fontSizeH4, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfo(result) {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.quizTitleAr,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeH5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingLG),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'الوقت المستغرق',
            value: _formatTime(result.timeSpentSeconds),
          ),
          SizedBox(height: AppDesignTokens.spacingMD),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'تاريخ الإنهاء',
            value: _formatDate(result.completedAt),
          ),
          if (result.passingScore > 0) ...[
            SizedBox(height: AppDesignTokens.spacingMD),
            _buildInfoRow(
              icon: Icons.verified_rounded,
              label: 'نقطة النجاح',
              value: '${result.passingScore.toInt()}%',
              valueColor: AppColors.successGreen,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        SizedBox(width: AppDesignTokens.spacingMD),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeBody,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppDesignTokens.fontSizeBody,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildWeakConcepts(List<String> concepts) {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.warningYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
        border: Border.all(color: AppColors.warningYellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warningYellow),
              SizedBox(width: AppDesignTokens.spacingMD),
              Text(
                'مفاهيم تحتاج إلى تحسين',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeBody,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warningYellow,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingMD),
          ...concepts.map(
            (concept) => Padding(
              padding: EdgeInsets.only(bottom: AppDesignTokens.spacingXS),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.warningYellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppDesignTokens.spacingMD),
                  Expanded(
                    child: Text(
                      concept,
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSizeBody,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.allowReview)
          ElevatedButton.icon(
            onPressed: () {
              context.push('/quiz/review/${widget.attemptId}');
            },
            icon: const Icon(Icons.rate_review_rounded),
            label: Text(
              'مراجعة الإجابات',
              style: TextStyle(fontSize: AppDesignTokens.fontSizeBody, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingLG),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
              ),
            ),
          ),
        SizedBox(height: AppDesignTokens.spacingMD),
        OutlinedButton.icon(
          onPressed: () {
            if (result.subjectId != null) {
              // Navigate to subject quizzes page
              context.push(
                '/quiz/subject/${result.subjectId}',
                extra: {
                  'subjectName': result.subjectNameAr ?? 'الاختبارات',
                },
              );
            } else {
              // Fallback to quiz list
              context.go('/quiz');
            }
          },
          icon: const Icon(Icons.quiz_rounded),
          label: const Text('تصفح المزيد من الاختبارات'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingLG),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
            ),
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingMD),
        TextButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.home_rounded),
          label: const Text('العودة للرئيسية'),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDesignTokens.spacingXXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppDesignTokens.spacingLG),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: AppDesignTokens.spacingXXL),
            ElevatedButton(
              onPressed: () {
                context.read<QuizResultsBloc>().add(
                  LoadQuizResults(attemptId: widget.attemptId),
                );
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (minutes > 0) {
      return '$minutes دقيقة و $secs ثانية';
    } else {
      return '$secs ثانية';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'اليوم في ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
