import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../bloc/quiz_list/quiz_list_bloc.dart';
import '../bloc/quiz_list/quiz_list_event.dart';
import '../bloc/quiz_list/quiz_list_state.dart';
import '../widgets/subject_quiz_card.dart';

/// Quiz list page showing subjects - tap to see quizzes for that subject
class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<QuizListBloc>().add(const LoadQuizzes());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<QuizListBloc, QuizListState>(
                builder: (context, state) {
                  if (state is QuizListLoading) {
                    return _buildLoadingState();
                  }

                  if (state is QuizListError && state.cachedQuizzes == null) {
                    return _buildErrorState(state.message);
                  }

                  if (state is QuizListGroupedLoaded) {
                    return _buildSubjectsList(state);
                  }

                  if (state is RecommendationsLoaded) {
                    return _buildRecommendations(state.recommendations);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
          ),
          SizedBox(width: AppDesignTokens.spacingMD),
          Expanded(
            child: Text(
              'الاختبارات',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeH3,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: _showRecommendations,
            icon: const Icon(Icons.lightbulb_outline_rounded),
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: AppDesignTokens.spacingLG),
          Text(
            'جاري تحميل الاختبارات...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppDesignTokens.fontSizeBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(QuizListGroupedLoaded state) {
    final subjects = state.groupedQuizzes.keys.toList();

    if (subjects.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<QuizListBloc>().add(const RefreshQuizzes());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final subject = subjects[index];
                  final quizzes = state.groupedQuizzes[subject] ?? [];

                  return SubjectQuizCard(
                    subject: subject,
                    quizCount: quizzes.length,
                    onTap: () {
                      // Navigate to subject quizzes page
                      context.push('/quiz/subject/${subject.id}', extra: {
                        'subject': subject,
                        'quizzes': quizzes,
                      });
                    },
                  );
                },
                childCount: subjects.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildRecommendations(List quizzes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(AppDesignTokens.spacingXL),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  context.read<QuizListBloc>().add(const LoadQuizzes());
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              SizedBox(width: AppDesignTokens.spacingMD),
              Expanded(
                child: Text(
                  'الاختبارات المقترحة',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSizeH3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding:
                EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXL),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Padding(
                padding: EdgeInsets.only(bottom: AppDesignTokens.spacingMD),
                child: _buildQuizCard(quiz),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuizCard(dynamic quiz) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/quiz/${quiz.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz.titleAr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (quiz.subject != null) ...[
                const SizedBox(height: 8),
                Text(
                  quiz.subject!.nameAr,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDesignTokens.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 80, color: AppColors.textHint),
            SizedBox(height: AppDesignTokens.spacingLG),
            Text(
              'لا توجد اختبارات متاحة',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeH5,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingSM),
            const Text(
              'جرب تغيير الفلاتر',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDesignTokens.spacingXXL),
            ElevatedButton.icon(
              onPressed: () {
                context.read<QuizListBloc>().add(const ClearFilters());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('مسح الفلاتر'),
            ),
          ],
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
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: AppDesignTokens.spacingLG),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: AppDesignTokens.spacingXXL),
            ElevatedButton(
              onPressed: () {
                context.read<QuizListBloc>().add(const LoadQuizzes());
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecommendations() {
    context.read<QuizListBloc>().add(const LoadRecommendations());
  }
}
