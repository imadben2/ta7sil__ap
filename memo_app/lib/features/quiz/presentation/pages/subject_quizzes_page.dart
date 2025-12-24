import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../domain/entities/quiz_entity.dart';
import '../widgets/quiz_card.dart';

/// Page showing all quizzes for a specific subject
class SubjectQuizzesPage extends StatelessWidget {
  final SubjectInfo subject;
  final List<QuizEntity> quizzes;

  const SubjectQuizzesPage({
    super.key,
    required this.subject,
    required this.quizzes,
  });

  Color get _subjectColor {
    if (subject.color != null && subject.color!.isNotEmpty) {
      try {
        final colorString = subject.color!.replaceFirst('#', '');
        return Color(int.parse(colorString, radix: 16) + 0xFF000000);
      } catch (_) {}
    }
    return AppColors.primary;
  }

  IconData get _subjectIcon {
    switch (subject.icon) {
      case 'calculate':
        return Icons.calculate_rounded;
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
      default:
        return Icons.book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern gradient app bar with subject info
          _buildSliverAppBar(context),
          // Content
          SliverToBoxAdapter(
            child: quizzes.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildStatsRow(context),
                      const SizedBox(height: 20),
                      _buildQuizzesList(context),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: _subjectColor,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
        ),
      ),
      actions: [
        // Leaderboard button in top left (RTL layout)
        Container(
          margin: const EdgeInsets.only(left: 16, right: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToLeaderboard(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      color: const Color(0xFFFFB800),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'الترتيب',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _subjectColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _subjectColor,
                _subjectColor.withValues(alpha: 0.85),
                _subjectColor.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -50,
                top: -30,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Subject info
              Positioned(
                bottom: 24,
                right: 20,
                left: 20,
                child: Row(
                  children: [
                    // Subject icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _subjectIcon,
                        color: _subjectColor,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            subject.nameAr,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.quiz_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${quizzes.length} اختبار',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildModernStatCard(
              icon: Icons.assignment_rounded,
              label: 'اختبار متاح',
              value: '${quizzes.length}',
              color: _subjectColor,
              gradient: [_subjectColor.withValues(alpha: 0.1), _subjectColor.withValues(alpha: 0.05)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildModernStatCard(
              icon: Icons.check_circle_rounded,
              label: 'مكتملة',
              value: '${_getCompletedCount()}',
              color: const Color(0xFF10B981),
              gradient: [const Color(0xFF10B981).withValues(alpha: 0.1), const Color(0xFF10B981).withValues(alpha: 0.05)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildModernStatCard(
              icon: Icons.trending_up_rounded,
              label: 'أفضل نتيجة',
              value: '${_getBestScore()}%',
              color: const Color(0xFFF59E0B),
              gradient: [const Color(0xFFF59E0B).withValues(alpha: 0.1), const Color(0xFFF59E0B).withValues(alpha: 0.05)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getCompletedCount() {
    return quizzes
        .where((quiz) => quiz.userStats != null && quiz.userStats!.attempts > 0)
        .length;
  }

  int _getBestScore() {
    if (quizzes.isEmpty) return 0;
    int best = 0;
    for (var quiz in quizzes) {
      final score = quiz.userStats?.bestScore;
      if (score != null && score > best) {
        best = score.toInt();
      }
    }
    return best;
  }

  void _navigateToLeaderboard(BuildContext context) {
    context.push(
      '/leaderboard/${subject.id}',
      extra: {
        'subjectName': subject.nameAr,
        'subjectColor': subject.color,
      },
    );
  }

  Widget _buildQuizzesList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _subjectColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.format_list_bulleted_rounded,
                    color: _subjectColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'قائمة الاختبارات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _subjectColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${quizzes.length}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Quiz list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return _buildModernQuizCard(context, quiz, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernQuizCard(BuildContext context, QuizEntity quiz, int index) {
    final isCompleted = quiz.userStats != null && quiz.userStats!.attempts > 0;
    final score = quiz.userStats?.bestScore ?? 0;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (!isCompleted) {
      statusColor = const Color(0xFF6366F1);
      statusIcon = Icons.play_circle_rounded;
      statusText = 'ابدأ الآن';
    } else if (score >= 80) {
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.verified_rounded;
      statusText = 'ممتاز';
    } else if (score >= 60) {
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.check_circle_rounded;
      statusText = 'جيد';
    } else {
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.replay_circle_filled_rounded;
      statusText = 'حاول مجدداً';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/quiz/${quiz.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? statusColor.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row - full width
              Row(
                children: [
                  // Score circle or play button
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isCompleted
                            ? [statusColor.withValues(alpha: 0.15), statusColor.withValues(alpha: 0.05)]
                            : [_subjectColor.withValues(alpha: 0.1), _subjectColor.withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCompleted ? statusColor.withValues(alpha: 0.3) : _subjectColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: isCompleted
                        ? Center(
                            child: Text(
                              '${score.toInt()}%',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.play_arrow_rounded,
                            color: _subjectColor,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Quiz title - takes remaining space
                  Expanded(
                    child: Text(
                      quiz.titleAr,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Bottom row - info chips and status
              Row(
                children: [
                  _buildQuizInfoChip(
                    Icons.help_outline_rounded,
                    '${quiz.totalQuestions} سؤال',
                    const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  _buildQuizInfoChip(
                    Icons.timer_outlined,
                    '${quiz.estimatedDurationMinutes} د',
                    const Color(0xFF64748B),
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _subjectColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.quiz_outlined,
                size: 60,
                color: _subjectColor.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingLG),
            Text(
              'لا توجد اختبارات لهذه المادة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: AppDesignTokens.fontSizeH5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingSM),
            Text(
              'ستتوفر اختبارات جديدة قريباً',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textHint,
                fontSize: AppDesignTokens.fontSizeBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
