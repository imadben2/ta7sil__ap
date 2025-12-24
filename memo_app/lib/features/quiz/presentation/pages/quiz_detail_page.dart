import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../bloc/quiz_detail/quiz_detail_bloc.dart';
import '../bloc/quiz_detail/quiz_detail_event.dart';
import '../bloc/quiz_detail/quiz_detail_state.dart';
import '../widgets/quiz_stats_card.dart';

/// Quiz detail page - shows quiz info before starting
class QuizDetailPage extends StatefulWidget {
  final int quizId;

  const QuizDetailPage({super.key, required this.quizId});

  @override
  State<QuizDetailPage> createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<QuizDetailBloc>().add(LoadQuizDetails(quizId: widget.quizId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<QuizDetailBloc, QuizDetailState>(
          listener: (context, state) {
            if (state is QuizStarted) {
              context.push('/quiz/attempt/${state.attempt.id}');
            } else if (state is QuizStartError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<QuizDetailBloc, QuizDetailState>(
            builder: (context, state) {
              if (state is QuizDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is QuizDetailError) {
                return _buildErrorState(state.message);
              }

              if (state is QuizDetailLoaded || state is QuizStarting) {
                final quiz = state is QuizDetailLoaded
                    ? state.quiz
                    : (state as QuizStarting).quiz;

                return Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(AppDesignTokens.spacingXL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildQuizHeader(quiz),
                            SizedBox(height: AppDesignTokens.spacingXXL),
                            QuizStatsCard(quiz: quiz),
                            if (quiz.descriptionAr?.isNotEmpty ?? false) ...[
                              SizedBox(height: AppDesignTokens.spacingXXL),
                              _buildDescription(quiz.descriptionAr!),
                            ],
                            // Show last attempt section if user has previous attempts
                            if (quiz.userStats != null && quiz.userStats!.lastAttemptId != null) ...[
                              SizedBox(height: AppDesignTokens.spacingXXL),
                              _buildLastAttemptSection(quiz),
                            ],
                          ],
                        ),
                      ),
                    ),
                    _buildBottomBar(state is QuizStarting),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              'تفاصيل الاختبار',
              style: TextStyle(fontSize: AppDesignTokens.fontSizeH4, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorHex) {
    return Color(
      int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
    );
  }

  Widget _buildQuizHeader(quiz) {
    final color = _parseColor(quiz.difficultyColor);
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingXXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacingMD,
                  vertical: AppDesignTokens.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                ),
                child: Text(
                  quiz.quizTypeAr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppDesignTokens.spacingSM),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacingMD,
                  vertical: AppDesignTokens.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                ),
                child: Text(
                  quiz.difficultyLevelAr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingLG),
          Text(
            quiz.titleAr,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeH3,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          if (quiz.subject != null) ...[
            SizedBox(height: AppDesignTokens.spacingMD),
            Text(
              quiz.subject!.subjectNameAr,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeBody,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
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
            'الوصف',
            style: TextStyle(fontSize: AppDesignTokens.fontSizeH5, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppDesignTokens.spacingMD),
          Text(description, style: TextStyle(fontSize: AppDesignTokens.fontSizeBody, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildLastAttemptSection(quiz) {
    final userStats = quiz.userStats!;
    final bestScore = userStats.bestScore;

    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: AppDesignTokens.spacingSM),
              Text(
                'المحاولات السابقة',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeH5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingLG),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'عدد المحاولات',
                  '${userStats.attemptsCount}',
                  Icons.replay_rounded,
                ),
              ),
              if (bestScore != null)
                Expanded(
                  child: _buildStatItem(
                    'أفضل نتيجة',
                    '${bestScore.toStringAsFixed(0)}%',
                    Icons.emoji_events_rounded,
                    color: bestScore >= 50 ? AppColors.successGreen : AppColors.error,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingLG),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.push('/quiz/review/${userStats.lastAttemptId}');
              },
              icon: const Icon(Icons.visibility_rounded),
              label: const Text('عرض آخر محاولة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingMD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                ),
                side: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? AppColors.textSecondary,
        ),
        SizedBox(width: AppDesignTokens.spacingXS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeCaption,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeBody,
                fontWeight: FontWeight.bold,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(bool isStarting) {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isStarting
            ? null
            : () {
                context.read<QuizDetailBloc>().add(const StartQuiz());
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingLG),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          ),
        ),
        child: isStarting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'ابدأ الاختبار',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeH5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDesignTokens.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppDesignTokens.spacingLG),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: AppDesignTokens.spacingXXL),
            ElevatedButton(
              onPressed: () {
                context.read<QuizDetailBloc>().add(
                  LoadQuizDetails(quizId: widget.quizId),
                );
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
